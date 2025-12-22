# Firebolt Cloud ClickBench Benchmark

This benchmark tests Firebolt Cloud's performance using the ClickBench dataset.

## Overview

This implementation uses **Firebolt Cloud** via the REST API. Queries are executed
using `curl` with service account authentication.

## Prerequisites

1. **Firebolt Cloud Account**: Sign up at https://www.firebolt.io/
2. **Service Account**: Create a service account with appropriate permissions
3. **Database**: Access to the `clickbench` database with the `hits` table (~100M rows)
4. **Engine**: A running engine attached to the database
5. **Tools**: `curl`, `jq`

## Environment Variables

Set the following environment variables before running the benchmark:

```bash
# Required
export FIREBOLT_CLIENT_ID="your-service-account-client-id"
export FIREBOLT_CLIENT_SECRET="your-service-account-client-secret"
export FIREBOLT_ACCOUNT="your-account-name"
export FIREBOLT_ENGINE="your-engine-name"
export FIREBOLT_DATABASE="clickbench"
```

## Table Naming Convention

The original `hits` table is **never modified**. All benchmark tables have distinct names:

| Table | Rows | Source | Created By |
|-------|------|--------|------------|
| `hits` | ~100M | Original dataset | (unchanged) |
| `hits_1b` | ~1B | hits × 10 | `./load_hits.sh` |
| `hits_10b` | ~10B | hits_1b × 10 | `./create_scaled.sh 10` |
| `hits_100b` | ~100B | hits_1b × 100 | `./create_scaled.sh 100` |

## Quick Start

```bash
# Make scripts executable
chmod +x *.sh

# Set environment variables
source ../../envvars.sh

# Create 1B table (scales hits × 10)
./load_hits.sh --engine bench2cost_l_co_3n

# Run the benchmark on 1B table
./run.sh --engine bench2cost_l_co_3n
```

## Data Volume Workflow

### Scaling Chain

```
hits (~100M) --×10--> hits_1b (~1B) --×10---> hits_10b (~10B)
                           |
                           +--×100--> hits_100b (~100B)
```

### Step-by-Step Workflow

```bash
# 1. Create 1B table (from hits × 10)
./load_hits.sh --engine bench2cost_l_co_3n

# 2. Run 1B benchmark
./run.sh --engine bench2cost_l_co_3n
# → saves to results_1B/bench2cost_l_co_3n.json

# 3. Create 10B table (from hits_1b × 10)
./create_scaled.sh 10 --engine bench2cost_l_co_6n

# 4. Run 10B benchmark
./run.sh --engine bench2cost_l_co_6n --table hits_10b
# → saves to results_10B/bench2cost_l_co_6n.json

# 5. Create 100B table (from hits_1b × 100)
./create_scaled.sh 100 --engine bench2cost_l_co_9n

# 6. Run 100B benchmark
./run.sh --engine bench2cost_l_co_9n --table hits_100b
# → saves to results_100B/bench2cost_l_co_9n.json
```

## File Structure

```
firebolt/
├── clickbench/
│   └── large/
│       ├── load_hits.sh      # Create hits_1b (1B rows from hits × 10)
│       ├── create_scaled.sh  # Create hits_10b/hits_100b
│       ├── run.sh            # Query runner (REST API)
│       ├── benchmark.sh      # Full benchmark script
│       ├── queries.sql       # 43 ClickBench queries
│       ├── template.json     # Result metadata template
│       ├── README.md         # This file
│       ├── results_1B/       # 1B benchmark results
│       ├── results_10B/      # 10B benchmark results
│       └── results_100B/     # 100B benchmark results
├── compare_results.py        # Comparison report generator
├── enrich_large.sh           # Cost enrichment script
├── pricings/                 # Pricing configuration files
└── results_*/                # Enriched results

# At project root (Bench2Cost/)
compare/                          # Generated comparison reports
```

## Script Reference

### `load_hits.sh`
Creates `hits_1b` table (~1B rows) by scaling `hits` × 10.

```bash
./load_hits.sh --engine ENGINE_NAME
```

Example:
```bash
./load_hits.sh --engine bench2cost_l_co_3n
```

### `create_scaled.sh`
Creates scaled tables using `generate_series()` cross join.

```bash
./create_scaled.sh 10 --engine ENGINE_NAME     # Create hits_10b (~10B rows) from hits_1b
./create_scaled.sh 100 --engine ENGINE_NAME    # Create hits_100b (~100B rows) from hits_1b
./create_scaled.sh all --engine ENGINE_NAME    # Create both
```

Example:
```bash
./create_scaled.sh 100 --engine bench2cost_l_co_9n
```

### `run.sh`
Runs the 43 ClickBench queries against a specified table.

```bash
./run.sh --engine ENGINE_NAME                      # Query hits_1b → results_1B/ENGINE_NAME.json
./run.sh --engine ENGINE_NAME --table hits_10b     # Query hits_10b → results_10B/ENGINE_NAME.json
./run.sh --engine ENGINE_NAME --table hits_100b    # Query hits_100b → results_100B/ENGINE_NAME.json
```

**Options:**
| Option | Description |
|--------|-------------|
| `--engine`, `-e` | Engine name (required) |
| `--table`, `-t` | Table to query: `hits_1b`, `hits_10b`, `hits_100b` (default: `hits_1b`) |
| `--skip-table-size` | Skip querying table size for faster startup |

Example:
```bash
./run.sh --engine bench2cost_3n
# Output: results_1B/bench2cost_3n.json
```

## How It Works

### 1. Authentication
OAuth2 client credentials flow:
```bash
curl -X POST "https://id.app.firebolt.io/oauth/token" \
    -d "client_id=${FIREBOLT_CLIENT_ID}" \
    -d "client_secret=${FIREBOLT_CLIENT_SECRET}" \
    -d "grant_type=client_credentials" \
    -d "audience=https://api.firebolt.io"
```

### 2. Get Engine URL
First get system engine URL, then query for user engine URL:
```bash
# System engine URL
curl "https://api.app.firebolt.io/web/v3/account/${ACCOUNT}/engineUrl"

# User engine URL
curl "https://${SYSTEM_ENGINE_URL}" --data \
    "SELECT url FROM information_schema.engines WHERE engine_name='${ENGINE}'"
```

### 3. Query Execution
Execute queries via the user engine URL:
```bash
curl "https://${USER_ENGINE_URL}&database=${DATABASE}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT ..."
```

### 4. Scaling
Tables are scaled 10x progressively by copying rows from the source table 10 times
```sql
CREATE TABLE hits_1b PRIMARY INDEX ...
AS SELECT hits.* FROM public.hits, generate_series(1, 10);
```

## Enriching Results with Costs

After running benchmarks, enrich the results with cost calculations:

```bash
cd ../..
./enrich_large.sh clickbench/large/results_1B results_1B
```

## Comparing Results

Use the `compare_results.py` script to generate markdown comparison reports between two benchmark result files.

### Basic Usage

```bash
cd ../..
python3 compare_results.py <clickhouse_results.json> <firebolt_results.json> --output <report.md>
```

### Examples

```bash
# Compare 1B results
python3 compare_results.py \
    ../clickhouse-cloud/results_1B/aws.3.236.parallel_replicas.json \
    results_1B/bench2cost_l_co_3n.json \
    --output ../compare/1B_clickhouse-cloud_3x236GiB_vs_firebolt_3xL_CO.md

# Compare 10B results
python3 compare_results.py \
    ../clickhouse-cloud/results_10B/aws.6.236.parallel_replicas.json \
    results_10B/bench2cost_l_co_6n.json \
    --output ../compare/10B_clickhouse-cloud_6x236GiB_vs_firebolt_6xL_CO.md
```

### Report Contents

The generated report includes:

- **Configuration**: Cluster size, machine/engine type, data size
- **Performance**: Total query time (best of 3 runs), queries won
- **Failed Queries**: List of queries that failed (OOM, timeout, etc.)
- **Storage Cost**: Monthly storage cost comparison
- **Compute Cost**: Per-tier compute cost comparison (Enterprise, Basic/Standard, Scale/Standard)
- **Summary**: Winners for each category with savings percentages
- **Query Details**: Per-query breakdown with best times for each system

### Options

| Option | Description |
|--------|-------------|
| `--name1` | Custom name for first system (default: from JSON) |
| `--name2` | Custom name for second system (default: from JSON) |
| `--output`, `-o` | Output file path (default: stdout) |

## Troubleshooting

### Authentication Errors
- Verify credentials are correct
- Check service account permissions

### Engine Errors
- Ensure engine is running (not stopped)

### Query Errors
- Verify table exists: `SELECT * FROM information_schema.tables WHERE table_name = ...`
- Check table name in error message

## API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `https://id.app.firebolt.io/oauth/token` | Authentication |
| `https://api.app.firebolt.io/web/v3/account/{account}/engineUrl` | System engine URL |
| `https://{engine_url}?database={db}` | Query execution |

## References

- [Firebolt Documentation](https://docs.firebolt.io/)
- [Firebolt REST API](https://docs.firebolt.io/guides/run-queries/using-the-api)
- [Service Accounts](https://docs.firebolt.io/Guides/managing-your-organization/service-accounts.html)
