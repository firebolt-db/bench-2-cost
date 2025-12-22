#!/usr/bin/env python3
"""
Compare benchmark results between two systems (e.g., ClickHouse Cloud vs Firebolt).
Generates a markdown report with performance and cost analysis.

Usage:
    python compare_results.py <file1.json> <file2.json> [--output report.md]
    
Example:
    python compare_results.py \
        ../clickhouse-cloud/results_1B/aws.3.236.parallel_replicas.json \
        results_1B/bench2cost_l_so_3n.json \
        --output comparison_1B.md
"""

import json
import argparse
import sys
from pathlib import Path


def load_results(filepath):
    """Load benchmark results from JSON file."""
    with open(filepath) as f:
        return json.load(f)


def get_min_times(results):
    """Extract minimum time for each query (best of 3 runs)."""
    return [
        min([t for t in q if t is not None]) if any(t is not None for t in q) else None
        for q in results
    ]


def get_winning_query_labels(results, query_labels):
    """Get the query_label of the winning (fastest) attempt for each query.
    
    Args:
        results: List of [run1, run2, run3] times for each query
        query_labels: List of [label1, label2, label3] for each query (optional, may be None)
    
    Returns:
        List of winning query_labels (or None if not available)
    """
    if not query_labels:
        return [None] * len(results)
    
    winning_labels = []
    for i, q_times in enumerate(results):
        if i >= len(query_labels):
            winning_labels.append(None)
            continue
            
        q_labels = query_labels[i]
        if not q_labels or not any(t is not None for t in q_times):
            winning_labels.append(None)
            continue
        
        # Find index of minimum time
        valid_times = [(j, t) for j, t in enumerate(q_times) if t is not None]
        if not valid_times:
            winning_labels.append(None)
            continue
            
        best_idx = min(valid_times, key=lambda x: x[1])[0]
        if best_idx < len(q_labels):
            winning_labels.append(q_labels[best_idx])
        else:
            winning_labels.append(None)
    
    return winning_labels


def get_failed_queries(results):
    """Get list of query numbers (0-indexed) that failed (all null results)."""
    failed = []
    for i, q in enumerate(results):
        if not any(t is not None for t in q):
            failed.append(i)  # 0-indexed
    return failed


def get_compute_cost(costs, tier_name, exclude_queries=None):
    """Get total compute cost for a tier (based on best run per query).
    
    Args:
        costs: List of cost tier objects
        tier_name: Name of tier to get costs for
        exclude_queries: Set of query indices (0-indexed) to exclude
    """
    tier = next((c for c in costs if c['tier'] == tier_name), None)
    if tier is None:
        return None, None
    exclude_queries = exclude_queries or set()
    # Use min (best) cost per query, excluding specified queries
    total = 0
    for i, q in enumerate(tier['compute_costs']):
        if i in exclude_queries:
            continue
        if any(c is not None for c in q):
            total += min(c for c in q if c is not None)
    return tier, total


def generate_report(data1, data2, name1=None, name2=None):
    """Generate markdown comparison report."""
    
    # Use system names if not provided
    name1 = name1 or data1.get('system', 'System 1')
    name2 = name2 or data2.get('system', 'System 2')
    
    # Get min times for performance comparison (best of 3 runs)
    min_times1 = get_min_times(data1['result'])
    min_times2 = get_min_times(data2['result'])
    
    # Get failed queries for each system
    failed1 = get_failed_queries(data1['result'])
    failed2 = get_failed_queries(data2['result'])
    
    # Queries that failed in either system (to exclude from comparison)
    all_failed = set(failed1) | set(failed2)
    # Convert to 0-indexed for internal use
    exclude_indices = {q - 1 for q in all_failed}
    
    # Count successful queries (succeeded in both systems)
    total_queries = len(min_times1)
    successful_queries = total_queries - len(all_failed)
    
    # Total min time (sum of best runs, only for queries that succeeded in BOTH)
    total_min1 = sum(t for i, t in enumerate(min_times1) if t is not None and i not in all_failed)
    total_min2 = sum(t for i, t in enumerate(min_times2) if t is not None and i not in all_failed)
    
    # Count wins based on min times (only for queries that succeeded in both)
    wins1 = sum(1 for i, (t1, t2) in enumerate(zip(min_times1, min_times2)) 
                if t1 is not None and t2 is not None and i not in all_failed and t1 < t2)
    wins2 = sum(1 for i, (t1, t2) in enumerate(zip(min_times1, min_times2)) 
                if t1 is not None and t2 is not None and i not in all_failed and t2 < t1)
    
    # Storage costs
    storage1 = data1['costs'][0]['storage_cost'] if 'costs' in data1 else 0
    storage2 = data2['costs'][0]['storage_cost'] if 'costs' in data2 else 0
    
    # Build report
    lines = []
    lines.append(f"### Cost Comparison: {name1} vs {name2}")
    lines.append("")
    lines.append("#### Configuration")
    lines.append("")
    lines.append(f"| Metric | {name1} | {name2} |")
    lines.append("|--------|" + "-" * (len(name1) + 2) + "|" + "-" * (len(name2) + 2) + "|")
    lines.append(f"| Cluster Size | {data1.get('cluster_size', 'N/A')} | {data2.get('cluster_size', 'N/A')} |")
    lines.append(f"| Machine/Engine | {data1.get('machine', 'N/A')} | {data2.get('machine', 'N/A')} |")
    
    size1 = data1.get('data_size', 0) / 1e9
    size2 = data2.get('data_size', 0) / 1e9
    lines.append(f"| Data Size (GB) | {size1:.2f} | {size2:.2f} |")
    lines.append("")
    
    # Performance (based on best of 3 runs)
    lines.append(f"#### Performance (Best of 3 runs, {successful_queries}/{total_queries} queries)")
    lines.append("")
    lines.append(f"| Metric | {name1} | {name2} |")
    lines.append("|--------|" + "-" * (len(name1) + 2) + "|" + "-" * (len(name2) + 2) + "|")
    lines.append(f"| Total Query Time | {total_min1:.3f}s | {total_min2:.3f}s |")
    lines.append(f"| Queries Won | {wins1} | {wins2} |")
    lines.append("")
    
    # Failed queries section
    if failed1 or failed2:
        lines.append("#### Failed Queries")
        lines.append("")
        if failed1:
            lines.append(f"- **{name1}**: Q{', Q'.join(map(str, failed1))}")
        if failed2:
            lines.append(f"- **{name2}**: Q{', Q'.join(map(str, failed2))}")
        lines.append("")
    
    # Storage
    lines.append("---")
    lines.append("")
    lines.append("#### Storage Cost (Monthly)")
    lines.append("")
    lines.append("| System | Cost |")
    lines.append("|--------|------|")
    lines.append(f"| {name1} | ${storage1:.4f} |")
    lines.append(f"| {name2} | ${storage2:.4f} |")
    
    if storage1 > 0 and storage2 > 0:
        if storage2 < storage1:
            savings = ((storage1 - storage2) / storage1) * 100
            lines.append(f"| **Savings** | **{name2} saves {savings:.1f}%** |")
        elif storage1 < storage2:
            savings = ((storage2 - storage1) / storage2) * 100
            lines.append(f"| **Savings** | **{name1} saves {savings:.1f}%** |")
    lines.append("")
    
    # Compute costs - try to match tiers
    tier_pairs = [
        ('Enterprise', 'Enterprise'),
        ('Basic', 'Standard'),
        ('Scale', 'Standard'),
    ]
    
    for tier1_name, tier2_name in tier_pairs:
        tier1, compute1 = get_compute_cost(data1.get('costs', []), tier1_name, exclude_indices)
        tier2, compute2 = get_compute_cost(data2.get('costs', []), tier2_name, exclude_indices)
        
        if tier1 is None or tier2 is None:
            continue
            
        lines.append("---")
        lines.append("")
        tier_label = tier1_name if tier1_name == tier2_name else f"{tier1_name}/{tier2_name}"
        lines.append(f"#### Compute Cost - {tier_label} Tier ({successful_queries} queries)")
        lines.append("")
        lines.append("| System | Cost |")
        lines.append("|--------|------|")
        lines.append(f"| {name1} ({tier1_name}) | ${compute1:.6f} |")
        lines.append(f"| {name2} ({tier2_name}) | ${compute2:.6f} |")
        
        if compute1 > 0 and compute2 > 0:
            if compute2 < compute1:
                savings = ((compute1 - compute2) / compute1) * 100
                lines.append(f"| **Savings** | **{name2} saves {savings:.1f}%** |")
            elif compute1 < compute2:
                savings = ((compute2 - compute1) / compute2) * 100
                lines.append(f"| **Savings** | **{name1} saves {savings:.1f}%** |")
        lines.append("")
    
    # Summary
    lines.append("---")
    lines.append("")
    lines.append("#### Summary")
    lines.append("")
    lines.append("| Category | Winner | Savings |")
    lines.append("|----------|--------|---------|")
    
    # Storage winner
    if storage1 > 0 and storage2 > 0:
        if storage2 < storage1:
            savings = ((storage1 - storage2) / storage1) * 100
            lines.append(f"| Storage | {name2} | {savings:.1f}% |")
        elif storage1 < storage2:
            savings = ((storage2 - storage1) / storage2) * 100
            lines.append(f"| Storage | {name1} | {savings:.1f}% |")
        else:
            lines.append("| Storage | Tie | 0% |")
    
    # Compute winners for each tier pair
    for tier1_name, tier2_name in tier_pairs:
        tier1, compute1 = get_compute_cost(data1.get('costs', []), tier1_name, exclude_indices)
        tier2, compute2 = get_compute_cost(data2.get('costs', []), tier2_name, exclude_indices)
        
        if tier1 is None or tier2 is None:
            continue
            
        tier_label = tier1_name if tier1_name == tier2_name else f"{tier1_name}/{tier2_name}"
        if compute1 > 0 and compute2 > 0:
            if compute2 < compute1:
                savings = ((compute1 - compute2) / compute1) * 100
                lines.append(f"| Compute ({tier_label}) | {name2} | {savings:.1f}% |")
            elif compute1 < compute2:
                savings = ((compute2 - compute1) / compute2) * 100
                lines.append(f"| Compute ({tier_label}) | {name1} | {savings:.1f}% |")
            else:
                lines.append(f"| Compute ({tier_label}) | Tie | 0% |")
    
    # Performance winner (based on best of 3 runs)
    if total_min2 < total_min1:
        perf_savings = ((total_min1 - total_min2) / total_min1) * 100
        lines.append(f"| Query Performance | {name2} | {perf_savings:.1f}% faster |")
    elif total_min1 < total_min2:
        perf_savings = ((total_min2 - total_min1) / total_min2) * 100
        lines.append(f"| Query Performance | {name1} | {perf_savings:.1f}% faster |")
    else:
        lines.append("| Query Performance | Tie | 0% |")
    
    lines.append("")
    
    # Detailed per-query comparison table
    lines.append("---")
    lines.append("")
    lines.append("#### Query Details")
    lines.append("")
    
    # Get machine/engine info
    machine1 = data1.get('machine', 'N/A')
    machine2 = data2.get('machine', 'N/A')
    cluster1 = data1.get('cluster_size', 'N/A')
    cluster2 = data2.get('cluster_size', 'N/A')
    scan_cache2 = data2.get('scan_cache', 'N/A')
    
    # Get winning query_labels for system 2 (Firebolt)
    query_labels2 = data2.get('query_labels', None)
    winning_labels = get_winning_query_labels(data2['result'], query_labels2)
    # Check if we have any valid query labels
    has_query_labels = any(ql is not None and ql != "null" for ql in winning_labels)
    
    # Short names for headers
    short_name1 = name1.split()[0] if ' ' in name1 else name1[:15]
    short_name2 = name2.split()[0] if ' ' in name2 else name2[:15]
    
    if has_query_labels:
        lines.append(f"| {short_name1} Node | {short_name2} Node | Cluster Size | Scan Cache | Query | {short_name1} Best | {short_name2} Best | {short_name2} Query Label |")
        lines.append("|---|---|---|---|---|---|---|---|")
    else:
        lines.append(f"| {short_name1} Node | {short_name2} Node | Cluster Size | Scan Cache | Query | {short_name1} Best | {short_name2} Best |")
        lines.append("|---|---|---|---|---|---|---|")
    
    for i, (t1, t2) in enumerate(zip(min_times1, min_times2)):
        query_num = f"Q{i}"
        winning_label = winning_labels[i] if i < len(winning_labels) else None
        # Format query label for display (or N/A if missing)
        label_str = winning_label if (winning_label and winning_label != "null") else "N/A"
        
        if has_query_labels:
            if t1 is None and t2 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | FAIL | FAIL | N/A |")
            elif t1 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | FAIL | {t2:.3f} | {label_str} |")
            elif t2 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | {t1:.3f} | FAIL | N/A |")
            else:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | {t1:.3f} | {t2:.3f} | {label_str} |")
        else:
            if t1 is None and t2 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | FAIL | FAIL |")
            elif t1 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | FAIL | {t2:.3f} |")
            elif t2 is None:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | {t1:.3f} | FAIL |")
            else:
                lines.append(f"| {machine1} | {machine2} | {cluster1} | {scan_cache2} | {query_num} | {t1:.3f} | {t2:.3f} |")
    
    lines.append("")
    
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Compare benchmark results between two systems"
    )
    parser.add_argument("file1", help="First results JSON file")
    parser.add_argument("file2", help="Second results JSON file")
    parser.add_argument("--name1", help="Name for first system (default: from JSON)")
    parser.add_argument("--name2", help="Name for second system (default: from JSON)")
    parser.add_argument("--output", "-o", help="Output markdown file (default: stdout)")
    
    args = parser.parse_args()
    
    # Load data
    try:
        data1 = load_results(args.file1)
        data2 = load_results(args.file2)
    except Exception as e:
        print(f"Error loading files: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Generate report
    report = generate_report(data1, data2, args.name1, args.name2)
    
    # Output
    if args.output:
        Path(args.output).write_text(report)
        print(f"Report saved to {args.output}")
    else:
        print(report)


if __name__ == "__main__":
    main()

