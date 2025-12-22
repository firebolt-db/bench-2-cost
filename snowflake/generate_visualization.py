#!/usr/bin/env python3
"""
Generate an interactive HTML visualization for benchmark cost-performance comparison.
Similar to ClickHouse's interactive benchmark explorer.
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any

def load_result_file(filepath: Path) -> Dict[str, Any]:
    """Load a single result JSON file."""
    with open(filepath, 'r') as f:
        return json.load(f)

def get_best_runtime(result: List[List[float]]) -> float:
    """Get total runtime using best of 3 runs for each query."""
    total = 0
    for query_runs in result:
        if query_runs:
            total += min(query_runs)
    return total

def get_total_cost(costs: List[Dict], tier: str) -> float:
    """Get total compute cost for a specific tier."""
    for cost_tier in costs:
        tier_name = cost_tier.get('tier', '').lower()
        if tier.lower() in tier_name or tier_name in tier.lower():
            compute_costs = cost_tier.get('compute_costs', [])
            total = 0
            for query_costs in compute_costs:
                if query_costs:
                    total += min(query_costs)
            return total
    return 0

def extract_data_point(result_data: Dict, scale: str, vendor: str, config: str) -> Dict:
    """Extract a data point for the visualization."""
    runtime = get_best_runtime(result_data.get('result', []))
    
    costs = result_data.get('costs', [])
    tiers = []
    
    for cost_tier in costs:
        tier_name = cost_tier.get('tier', 'unknown')
        compute_costs = cost_tier.get('compute_costs', [])
        total_cost = sum(min(qc) for qc in compute_costs if qc)
        storage_cost = cost_tier.get('storage_cost', 0)
        
        # Handle storage_costs array if it exists
        if 'storage_costs' in cost_tier:
            for sc in cost_tier['storage_costs']:
                if sc.get('term') == 'active' or 'estimated_cost' in sc:
                    storage_cost = sc.get('estimated_cost', storage_cost)
                    break
        
        tiers.append({
            'name': tier_name,
            'compute_cost': total_cost,
            'storage_cost': storage_cost
        })
    
    return {
        'vendor': vendor,
        'config': config,
        'scale': scale,
        'runtime': runtime,
        'tiers': tiers,
        'system': result_data.get('system', vendor),
        'machine': result_data.get('machine', ''),
        'cluster_size': result_data.get('cluster_size', 1),
        'data_size': result_data.get('data_size', 0),
    }

def collect_all_results(base_dir: Path) -> List[Dict]:
    """Collect all enriched results from all vendors and scales."""
    results = []
    
    vendors = {
        'firebolt': 'Firebolt',
        'clickhouse-cloud': 'ClickHouse Cloud',
        'snowflake': 'Snowflake',
        'databricks': 'Databricks',
        'bigquery': 'BigQuery',
        'redshift-serverless': 'Redshift Serverless'
    }
    
    scales = ['1B', '10B', '100B']
    
    for vendor_dir, vendor_name in vendors.items():
        vendor_path = base_dir / vendor_dir
        if not vendor_path.exists():
            continue
            
        for scale in scales:
            results_dir = vendor_path / f'results_{scale}'
            if not results_dir.exists():
                continue
                
            for result_file in results_dir.glob('*.json'):
                try:
                    result_data = load_result_file(result_file)
                    config = result_file.stem
                    data_point = extract_data_point(result_data, scale, vendor_name, config)
                    results.append(data_point)
                except Exception as e:
                    print(f"Error loading {result_file}: {e}")
    
    return results

def generate_html(results: List[Dict], output_path: Path):
    """Generate the interactive HTML visualization."""
    
    # Group results by vendor and scale
    vendors = sorted(set(r['vendor'] for r in results))
    scales = ['1B', '10B', '100B']
    
    # Vendor colors
    vendor_colors = {
        'ClickHouse Cloud': '#FADB14',
        'Firebolt': '#f82f35',
        'Snowflake': '#29B5E8',
        'Databricks': '#ffbfb8',
        'BigQuery': '#4285F4',
        'Redshift Serverless': '#F77600'
    }
    
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bench2Cost Interactive Benchmark Explorer</title>
    <script src="https://cdn.plot.ly/plotly-2.27.0.min.js"></script>
    <style>
        :root {{
            --bg-primary: #0D1117;
            --bg-secondary: #161B22;
            --bg-card: #21262D;
            --text-primary: #E6EDF3;
            --text-secondary: #8B949E;
            --border-color: #30363D;
            --accent: #58A6FF;
        }}
        
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 2rem;
        }}
        
        .container {{
            max-width: 1400px;
            margin: 0 auto;
        }}
        
        h1 {{
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #FF6B35, #F7931E);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }}
        
        .subtitle {{
            color: var(--text-secondary);
            margin-bottom: 2rem;
            font-size: 1.1rem;
        }}
        
        .controls {{
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
            padding: 1.5rem;
            background: var(--bg-secondary);
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }}
        
        .control-group {{
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }}
        
        .control-group label {{
            font-size: 0.875rem;
            color: var(--text-secondary);
            font-weight: 500;
        }}
        
        select {{
            padding: 0.5rem 1rem;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background: var(--bg-card);
            color: var(--text-primary);
            font-size: 0.875rem;
            cursor: pointer;
            min-width: 150px;
        }}
        
        select:hover {{
            border-color: var(--accent);
        }}
        
        .toggle-group {{
            display: flex;
            background: var(--bg-card);
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid var(--border-color);
        }}
        
        .toggle-btn {{
            padding: 0.5rem 1rem;
            border: none;
            background: transparent;
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            transition: all 0.2s;
        }}
        
        .toggle-btn.active {{
            background: var(--accent);
            color: var(--bg-primary);
        }}
        
        .toggle-btn:hover:not(.active) {{
            background: var(--bg-secondary);
            color: var(--text-primary);
        }}
        
        .vendor-cards {{
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }}
        
        .vendor-card {{
            display: flex;
            flex-direction: column;
            padding: 1rem;
            background: var(--bg-card);
            border-radius: 8px;
            border: 2px solid var(--border-color);
            min-width: 180px;
            position: relative;
        }}
        
        .vendor-card.active {{
            border-color: var(--accent);
        }}
        
        .vendor-card-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.75rem;
        }}
        
        .vendor-name {{
            font-weight: 600;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }}
        
        .vendor-dot {{
            width: 10px;
            height: 10px;
            border-radius: 50%;
        }}
        
        .remove-btn {{
            background: none;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 1.2rem;
            padding: 0;
            line-height: 1;
        }}
        
        .remove-btn:hover {{
            color: #F85149;
        }}
        
        .vendor-card select {{
            min-width: auto;
            width: 100%;
            margin-top: 0.25rem;
        }}
        
        .vendor-card label {{
            font-size: 0.75rem;
            color: var(--text-secondary);
        }}
        
        .chart-container {{
            background: var(--bg-secondary);
            border-radius: 12px;
            border: 1px solid var(--border-color);
            padding: 1rem;
            margin-bottom: 1.5rem;
        }}
        
        #chart {{
            width: 100%;
            height: 600px;
        }}
        
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }}
        
        .stat-card {{
            background: var(--bg-card);
            border-radius: 8px;
            padding: 1.25rem;
            border: 1px solid var(--border-color);
        }}
        
        .stat-card h3 {{
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-bottom: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        
        .stat-value {{
            font-size: 1.5rem;
            font-weight: 600;
        }}
        
        .stat-vendor {{
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-top: 0.25rem;
        }}
        
        .add-vendor-btn {{
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            border: 2px dashed var(--border-color);
            background: transparent;
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }}
        
        .add-vendor-btn:hover {{
            border-color: var(--accent);
            color: var(--text-primary);
        }}
        
        .chart-mode-group {{
            margin-left: auto;
        }}
        
        .legend-item {{
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Bench2Cost Interactive Benchmark Explorer</h1>
        <p class="subtitle">Compare cloud data warehouse cost-performance across different scales and configurations</p>
        
        <div class="controls">
            <div class="control-group">
                <select id="addVendor">
                    <option value="">+ Add Vendor</option>
                    {' '.join(f'<option value="{v}">{v}</option>' for v in vendors)}
                </select>
            </div>
            
            <div class="control-group">
                <label>Scale:</label>
                <div class="toggle-group" id="scaleToggle">
                    <button class="toggle-btn" data-value="1B">1B</button>
                    <button class="toggle-btn" data-value="10B">10B</button>
                    <button class="toggle-btn active" data-value="100B">100B</button>
                </div>
            </div>
            
            <div class="control-group chart-mode-group">
                <label>View:</label>
                <div class="toggle-group" id="viewToggle">
                    <button class="toggle-btn active" data-value="scatter">Scatter</button>
                    <button class="toggle-btn" data-value="bar">Bar</button>
                    <button class="toggle-btn" data-value="cost-perf">$/Perf</button>
                </div>
            </div>
            
            <div class="control-group">
                <label>Axis:</label>
                <div class="toggle-group" id="logScaleToggle">
                    <button class="toggle-btn" data-value="linear">Linear</button>
                    <button class="toggle-btn active" data-value="log">Log</button>
                </div>
            </div>
        </div>
        
        <div class="vendor-cards" id="vendorCards">
            <!-- Vendor cards will be dynamically added here -->
        </div>
        
        <div class="chart-container">
            <div id="chart"></div>
        </div>
        
        <div class="stats-grid" id="statsGrid">
            <!-- Stats will be dynamically added here -->
        </div>
    </div>
    
    <script>
        // Benchmark data
        const benchmarkData = {json.dumps(results, indent=2)};
        
        // Vendor colors
        const vendorColors = {json.dumps(vendor_colors)};
        
        // State
        let selectedScale = '100B';
        let selectedView = 'scatter';
        let useLogScale = true;
        let activeVendors = [];
        
        // Default configurations per scale
        const scaleDefaults = {{
            '1B': {{
                'Firebolt': {{ config: 'bench2cost_l_co_9n', tier: 'Enterprise' }},
                'ClickHouse Cloud': {{ config: 'aws.9.236.parallel_replicas', tier: 'Enterprise' }},
                'Snowflake': {{ config: '4xl_enriched', tier: 'enterprise' }},
                'Databricks': {{ config: 'clickbench_4X-Large_enriched', tier: 'premium' }},
                'BigQuery': {{ config: null, tier: 'Enterprise' }},
                'Redshift Serverless': {{ config: null, tier: 'Standard' }}
            }},
            '10B': {{
                'Firebolt': {{ config: 'bench2cost_l_co_20n', tier: 'Enterprise' }},
                'ClickHouse Cloud': {{ config: 'aws.20.236.parallel_replicas', tier: 'Enterprise' }},
                'Snowflake': {{ config: '4xl_enriched', tier: 'enterprise' }},
                'Databricks': {{ config: 'clickbench_4X-Large_enriched', tier: 'premium' }},
                'BigQuery': {{ config: null, tier: 'Enterprise' }},
                'Redshift Serverless': {{ config: null, tier: 'Standard' }}
            }},
            '100B': {{
                'Firebolt': {{ config: 'bench2cost_l_co_20n', tier: 'Enterprise' }},
                'ClickHouse Cloud': {{ config: 'aws.20.236.parallel_replicas', tier: 'Enterprise' }},
                'Snowflake': {{ config: '4xl_enriched', tier: 'enterprise' }},
                'Databricks': {{ config: 'clickbench_4X-Large_enriched', tier: 'premium' }},
                'BigQuery': {{ config: null, tier: 'Enterprise' }},
                'Redshift Serverless': {{ config: null, tier: 'Standard' }}
            }}
        }};
        
        // Initialize with all vendors using scale-specific defaults
        function initializeDefaults() {{
            const defaultVendors = ['Firebolt', 'ClickHouse Cloud', 'Snowflake', 'Databricks', 'BigQuery', 'Redshift Serverless'];
            defaultVendors.forEach(vendor => {{
                const configs = getConfigsForVendor(vendor, selectedScale);
                if (configs.length > 0) {{
                    const defaults = scaleDefaults[selectedScale]?.[vendor] || {{}};
                    const config = defaults.config || configs[configs.length - 1];
                    const tier = defaults.tier || null;
                    addVendorCard(vendor, config, tier);
                }}
            }});
        }}
        
        // Get config size for sorting (larger = bigger number)
        function getConfigSize(config) {{
            const configLower = config.toLowerCase();
            
            // Handle node counts with suffix (e.g., "bench2cost_l_co_3n", "bench2cost_l_co_20n")
            const nodeSuffixMatch = configLower.match(/(\d+)n$/);
            if (nodeSuffixMatch) {{
                return parseInt(nodeSuffixMatch[1]) * 100;
            }}
            
            // Handle ClickHouse configs (e.g., "aws.3.236.parallel_replicas", "aws.20.236.parallel_replicas")
            const clickhouseMatch = configLower.match(/aws\.(\d+)\./);
            if (clickhouseMatch) {{
                return parseInt(clickhouseMatch[1]) * 100;
            }}
            
            // Handle node counts at start (e.g., "3n", "9n", "20n", "3.236 (PR)")
            const nodeStartMatch = configLower.match(/^(\d+)/);
            if (nodeStartMatch) {{
                return parseInt(nodeStartMatch[1]) * 100;
            }}
            
            // Handle warehouse sizes - check from largest to smallest to avoid 'large' matching before '4xl'
            const sizeOrder = [
                ['4xl', 8], ['4x-large', 8], ['4xlarge', 8],
                ['3xl', 7], ['3x-large', 7], ['3xlarge', 7],
                ['2xl', 6], ['2x-large', 6], ['2xlarge', 6],
                ['xl', 5], ['xlarge', 5], ['x-large', 5],
                ['large', 4],
                ['medium', 3],
                ['small', 2],
                ['xs', 1], ['extra-small', 1]
            ];
            
            for (const [key, value] of sizeOrder) {{
                if (configLower.includes(key)) {{
                    return value;
                }}
            }}
            
            return 0;
        }}
        
        // Get available configurations for a vendor at a given scale (sorted by size)
        function getConfigsForVendor(vendor, scale) {{
            return benchmarkData
                .filter(d => d.vendor === vendor && d.scale === scale)
                .map(d => d.config)
                // Filter out Firebolt 1-node config
                .filter(c => !c.match(/bench2cost_l_co_1n/))
                .sort((a, b) => getConfigSize(a) - getConfigSize(b));
        }}
        
        // Get tiers for a vendor/config/scale combination
        function getTiersForConfig(vendor, config, scale) {{
            const data = benchmarkData.find(d => 
                d.vendor === vendor && d.config === config && d.scale === scale
            );
            return data ? data.tiers.map(t => t.name) : [];
        }}
        
        // Add a vendor card
        function addVendorCard(vendor, config = null, tier = null) {{
            const configs = getConfigsForVendor(vendor, selectedScale);
            if (configs.length === 0) return;
            
            config = config || configs[0];
            const tiers = getTiersForConfig(vendor, config, selectedScale);
            tier = tier || (tiers.length > 0 ? tiers[0] : null);
            
            const vendorId = `vendor-${{Date.now()}}`;
            const color = vendorColors[vendor] || '#888';
            
            activeVendors.push({{
                id: vendorId,
                vendor: vendor,
                config: config,
                tier: tier
            }});
            
            // Check if this is a serverless system with only one config
            const isServerless = configs.length === 1 && 
                (vendor === 'BigQuery' || vendor === 'Redshift Serverless');
            
            const card = document.createElement('div');
            card.className = 'vendor-card active';
            card.id = vendorId;
            card.innerHTML = `
                <div class="vendor-card-header">
                    <span class="vendor-name">
                        <span class="vendor-dot" style="background: ${{color}}"></span>
                        ${{vendor}}
                    </span>
                    <button class="remove-btn" onclick="removeVendorCard('${{vendorId}}')">&times;</button>
                </div>
                ${{isServerless ? '<span style="color: #8B949E; font-size: 0.8rem;">Serverless</span>' : '<label>Config</label><select onchange="updateVendorConfig(\\'' + vendorId + '\\', this.value)">' + configs.map(c => '<option value="' + c + '"' + (c === config ? ' selected' : '') + '>' + formatConfigName(c) + '</option>').join('') + '</select>'}}
                <label style="margin-top: 0.5rem">Tier</label>
                <select onchange="updateVendorTier('${{vendorId}}', this.value)">
                    ${{tiers.map(t => `<option value="${{t}}" ${{t === tier ? 'selected' : ''}}>${{t}}</option>`).join('')}}
                </select>
            `;
            
            document.getElementById('vendorCards').appendChild(card);
            updateChart();
        }}
        
        // Format config name for display
        function formatConfigName(config) {{
            // Handle Firebolt configs: bench2cost_l_co_3n -> Large CO 3 nodes
            const fireboltMatch = config.match(/bench2cost_l_co_(\d+)n/);
            if (fireboltMatch) {{
                return `Large CO ${{fireboltMatch[1]}} nodes`;
            }}
            
            // Handle ClickHouse configs: aws.3.236.parallel_replicas -> 3 nodes
            const clickhouseMatch = config.match(/aws\.(\d+)\..*parallel_replicas/);
            if (clickhouseMatch) {{
                return `${{clickhouseMatch[1]}} nodes`;
            }}
            
            return config
                .replace('bench2cost_l_co_', '')
                .replace('_enriched', '')
                .replace('aws.', '')
                .replace('.parallel_replicas', ' (PR)')
                .replace('clickbench_', '')
                .replace('result_', '');
        }}
        
        // Remove a vendor card
        function removeVendorCard(vendorId) {{
            activeVendors = activeVendors.filter(v => v.id !== vendorId);
            document.getElementById(vendorId)?.remove();
            updateChart();
        }}
        
        // Update vendor config
        function updateVendorConfig(vendorId, config) {{
            const vendorData = activeVendors.find(v => v.id === vendorId);
            if (vendorData) {{
                vendorData.config = config;
                const tiers = getTiersForConfig(vendorData.vendor, config, selectedScale);
                vendorData.tier = tiers.length > 0 ? tiers[0] : null;
                
                // Update tier dropdown
                const card = document.getElementById(vendorId);
                const tierSelect = card.querySelectorAll('select')[1];
                tierSelect.innerHTML = tiers.map(t => 
                    `<option value="${{t}}">${{t}}</option>`
                ).join('');
            }}
            updateChart();
        }}
        
        // Update vendor tier
        function updateVendorTier(vendorId, tier) {{
            const vendorData = activeVendors.find(v => v.id === vendorId);
            if (vendorData) {{
                vendorData.tier = tier;
            }}
            updateChart();
        }}
        
        // Get data point for vendor/config/tier/scale
        function getDataPoint(vendor, config, tier, scale) {{
            const data = benchmarkData.find(d => 
                d.vendor === vendor && d.config === config && d.scale === scale
            );
            if (!data) return null;
            
            const tierData = data.tiers.find(t => t.name === tier);
            if (!tierData) return null;
            
            return {{
                vendor: vendor,
                config: config,
                tier: tier,
                runtime: data.runtime,
                cost: tierData.compute_cost,
                system: data.system,
                machine: data.machine,
                cluster_size: data.cluster_size
            }};
        }}
        
        // Update the chart
        function updateChart() {{
            const dataPoints = activeVendors
                .map(v => getDataPoint(v.vendor, v.config, v.tier, selectedScale))
                .filter(d => d !== null);
            
            if (dataPoints.length === 0) {{
                Plotly.purge('chart');
                return;
            }}
            
            if (selectedView === 'scatter') {{
                renderScatterPlot(dataPoints);
            }} else if (selectedView === 'bar') {{
                renderBarChart(dataPoints);
            }} else {{
                renderCostPerfChart(dataPoints);
            }}
            
            updateStats(dataPoints);
        }}
        
        // Render scatter plot
        function renderScatterPlot(dataPoints) {{
            const traces = dataPoints.map(d => ({{
                x: [d.runtime],
                y: [d.cost],
                mode: 'markers+text',
                type: 'scatter',
                name: `${{d.vendor}} (${{formatConfigName(d.config)}})`,
                text: [`${{d.vendor}} ${{d.tier}}`],
                textposition: 'top center',
                textfont: {{
                    color: '#E6EDF3',
                    size: 11
                }},
                marker: {{
                    size: 16,
                    color: vendorColors[d.vendor] || '#888',
                    line: {{
                        color: '#E6EDF3',
                        width: 1
                    }}
                }},
                hovertemplate: `<b>${{d.vendor}}</b><br>` +
                    `Config: ${{formatConfigName(d.config)}}<br>` +
                    `Tier: ${{d.tier}}<br>` +
                    `Runtime: %{{x:.2f}}s<br>` +
                    `Cost: $%{{y:.4f}}<extra></extra>`
            }}));
            
            const layout = {{
                title: {{
                    text: `Total Runtime vs Total Cost (${{selectedScale}} rows)`,
                    font: {{ color: '#E6EDF3', size: 16 }}
                }},
                xaxis: {{
                    title: useLogScale ? 'Total Runtime (seconds, log) → right is better' : 'Total Runtime (seconds) → right is better',
                    type: useLogScale ? 'log' : 'linear',
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }},
                    titlefont: {{ color: '#8B949E' }},
                    autorange: 'reversed'
                }},
                yaxis: {{
                    title: useLogScale ? 'Total Cost (USD, log) → up is better' : 'Total Cost (USD) → up is better',
                    type: useLogScale ? 'log' : 'linear',
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }},
                    titlefont: {{ color: '#8B949E' }},
                    autorange: 'reversed'
                }},
                paper_bgcolor: '#161B22',
                plot_bgcolor: '#161B22',
                showlegend: false,
                margin: {{ t: 50, b: 80, l: 80, r: 30 }}
            }};
            
            Plotly.newPlot('chart', traces, layout, {{ responsive: true }});
        }}
        
        // Render bar chart
        function renderBarChart(dataPoints) {{
            // Sort by cost-performance score (best performer first - will appear at top)
            const scored = dataPoints.map(d => ({{
                ...d,
                score: d.runtime * d.cost
            }}));
            // Sort ascending by score (best first)
            const sortedByScore = [...scored].sort((a, b) => a.score - b.score);
            
            const labels = sortedByScore.map(d => `${{d.vendor}} ${{formatConfigName(d.config)}}`);
            
            // Cost trace (yellow) - plotted on top x-axis
            const costTrace = {{
                y: labels,
                x: sortedByScore.map(d => d.cost),
                type: 'bar',
                orientation: 'h',
                name: 'Compute Cost ($)',
                marker: {{
                    color: '#F7E655'  // Yellow color like ClickHouse chart
                }},
                hovertemplate: '<b>%{{y}}</b><br>Cost: $%{{x:.2f}}<extra></extra>',
                xaxis: 'x2',
                yaxis: 'y',
                offsetgroup: 1
            }};
            
            // Performance/Runtime trace (gray) - plotted on bottom x-axis  
            const runtimeTrace = {{
                y: labels,
                x: sortedByScore.map(d => d.runtime),
                type: 'bar',
                orientation: 'h',
                name: 'Performance (s)',
                marker: {{
                    color: '#888888'  // Gray color like ClickHouse chart
                }},
                hovertemplate: '<b>%{{y}}</b><br>Runtime: %{{x:.2f}}s<extra></extra>',
                xaxis: 'x',
                yaxis: 'y',
                offsetgroup: 2
            }};
            
            const layout = {{
                paper_bgcolor: '#161B22',
                plot_bgcolor: '#161B22',
                showlegend: true,
                legend: {{
                    font: {{ color: '#E6EDF3' }},
                    orientation: 'h',
                    x: 0.5,
                    xanchor: 'center',
                    y: 1.15,
                    bgcolor: 'rgba(0,0,0,0)'
                }},
                margin: {{ t: 80, b: 60, l: 200, r: 20 }},
                barmode: 'group',
                bargap: 0.3,
                bargroupgap: 0.1,
                // Top x-axis for Cost
                xaxis2: {{
                    title: {{ text: 'Cost ($)', font: {{ color: '#8B949E', size: 12 }} }},
                    side: 'top',
                    overlaying: 'x',
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }},
                    zeroline: false,
                    showgrid: true
                }},
                // Bottom x-axis for Time
                xaxis: {{
                    title: {{ text: 'Time (s)', font: {{ color: '#8B949E', size: 12 }} }},
                    side: 'bottom',
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }},
                    zeroline: false,
                    showgrid: true
                }},
                yaxis: {{
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#E6EDF3', size: 11 }},
                    automargin: true,
                    categoryorder: 'array',
                    categoryarray: [...labels].reverse()  // Reverse so best performer (first in sorted) appears at top
                }}
            }};
            
            Plotly.newPlot('chart', [costTrace, runtimeTrace], layout, {{ responsive: true }});
        }}
        
        // Render cost-performance chart
        function renderCostPerfChart(dataPoints) {{
            // Cost-performance score = runtime × cost (lower is better)
            const scored = dataPoints.map(d => ({{
                ...d,
                score: d.runtime * d.cost
            }}));
            
            const minScore = Math.min(...scored.map(d => d.score));
            scored.forEach(d => {{
                d.relative = d.score / minScore;
            }});
            
            const sorted = scored.sort((a, b) => a.relative - b.relative);
            
            const trace = {{
                x: sorted.map(d => `${{d.vendor}}<br>${{formatConfigName(d.config)}}`),
                y: sorted.map(d => d.relative),
                type: 'bar',
                marker: {{
                    color: sorted.map(d => vendorColors[d.vendor] || '#888')
                }},
                text: sorted.map(d => `${{d.relative.toFixed(1)}}×`),
                textposition: 'outside',
                textfont: {{ color: '#E6EDF3' }},
                hovertemplate: '<b>%{{x}}</b><br>Cost-Perf Score: %{{y:.2f}}× baseline<extra></extra>'
            }};
            
            const layout = {{
                title: {{
                    text: `Cost-Performance Ranking (${{selectedScale}} rows) — lower is better`,
                    font: {{ color: '#E6EDF3', size: 16 }}
                }},
                xaxis: {{
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }}
                }},
                yaxis: {{
                    title: 'Relative Cost-Performance (1× = best)',
                    gridcolor: '#30363D',
                    linecolor: '#30363D',
                    tickfont: {{ color: '#8B949E' }},
                    titlefont: {{ color: '#8B949E' }}
                }},
                paper_bgcolor: '#161B22',
                plot_bgcolor: '#161B22',
                showlegend: false,
                margin: {{ t: 50, b: 120, l: 80, r: 30 }}
            }};
            
            Plotly.newPlot('chart', [trace], layout, {{ responsive: true }});
        }}
        
        // Update stats
        function updateStats(dataPoints) {{
            const statsGrid = document.getElementById('statsGrid');
            
            if (dataPoints.length === 0) {{
                statsGrid.innerHTML = '';
                return;
            }}
            
            const fastestByRuntime = dataPoints.reduce((a, b) => a.runtime < b.runtime ? a : b);
            const cheapest = dataPoints.reduce((a, b) => a.cost < b.cost ? a : b);
            const bestCostPerf = dataPoints.reduce((a, b) => 
                (a.runtime * a.cost) < (b.runtime * b.cost) ? a : b
            );
            
            statsGrid.innerHTML = `
                <div class="stat-card">
                    <h3>Fastest Runtime</h3>
                    <div class="stat-value" style="color: ${{vendorColors[fastestByRuntime.vendor]}}">${{fastestByRuntime.runtime.toFixed(2)}}s</div>
                    <div class="stat-vendor">${{fastestByRuntime.vendor}} (${{formatConfigName(fastestByRuntime.config)}})</div>
                </div>
                <div class="stat-card">
                    <h3>Lowest Cost</h3>
                    <div class="stat-value" style="color: ${{vendorColors[cheapest.vendor]}}">$${{cheapest.cost.toFixed(4)}}</div>
                    <div class="stat-vendor">${{cheapest.vendor}} (${{formatConfigName(cheapest.config)}})</div>
                </div>
                <div class="stat-card">
                    <h3>Best Cost-Performance</h3>
                    <div class="stat-value" style="color: ${{vendorColors[bestCostPerf.vendor]}}">1.0×</div>
                    <div class="stat-vendor">${{bestCostPerf.vendor}} (${{formatConfigName(bestCostPerf.config)}})</div>
                </div>
            `;
        }}
        
        // Event Listeners
        document.getElementById('addVendor').addEventListener('change', function() {{
            if (this.value) {{
                addVendorCard(this.value);
                this.value = '';
            }}
        }});
        
        document.getElementById('scaleToggle').addEventListener('click', function(e) {{
            if (e.target.classList.contains('toggle-btn')) {{
                this.querySelectorAll('.toggle-btn').forEach(btn => btn.classList.remove('active'));
                e.target.classList.add('active');
                selectedScale = e.target.dataset.value;
                
                // Refresh vendor cards with new scale options using scale-specific defaults
                const currentVendors = activeVendors.map(v => v.vendor);
                document.getElementById('vendorCards').innerHTML = '';
                activeVendors = [];
                currentVendors.forEach(vendor => {{
                    const configs = getConfigsForVendor(vendor, selectedScale);
                    if (configs.length > 0) {{
                        const defaults = scaleDefaults[selectedScale]?.[vendor] || {{}};
                        const config = defaults.config || configs[configs.length - 1];
                        const tier = defaults.tier || null;
                        addVendorCard(vendor, config, tier);
                    }}
                }});
            }}
        }});
        
        document.getElementById('viewToggle').addEventListener('click', function(e) {{
            if (e.target.classList.contains('toggle-btn')) {{
                this.querySelectorAll('.toggle-btn').forEach(btn => btn.classList.remove('active'));
                e.target.classList.add('active');
                selectedView = e.target.dataset.value;
                updateChart();
            }}
        }});
        
        document.getElementById('logScaleToggle').addEventListener('click', function(e) {{
            if (e.target.classList.contains('toggle-btn')) {{
                this.querySelectorAll('.toggle-btn').forEach(btn => btn.classList.remove('active'));
                e.target.classList.add('active');
                useLogScale = e.target.dataset.value === 'log';
                updateChart();
            }}
        }});
        
        // Initialize
        initializeDefaults();
    </script>
</body>
</html>
'''
    
    with open(output_path, 'w') as f:
        f.write(html)
    
    print(f"Generated visualization at: {output_path}")

def main():
    base_dir = Path(__file__).parent
    output_path = base_dir / 'benchmark_explorer.html'
    
    print("Collecting benchmark results...")
    results = collect_all_results(base_dir)
    print(f"Found {len(results)} result files")
    
    print("Generating HTML visualization...")
    generate_html(results, output_path)
    
    print("Done!")

if __name__ == '__main__':
    main()

