#!/bin/bash
set -euo pipefail

# Firebolt Cloud ClickBench Benchmark
#
# This script runs the ClickBench benchmark against Firebolt Cloud.
# It authenticates using service account credentials, creates the table,
# loads data from S3, and runs the benchmark queries.
#
# Required Environment Variables:
#   FIREBOLT_CLIENT_ID     - Service account client ID
#   FIREBOLT_CLIENT_SECRET - Service account client secret
#   FIREBOLT_ACCOUNT       - Firebolt account name
#   FIREBOLT_ENGINE        - Engine name to use
#   FIREBOLT_DATABASE      - Database name
#
# Usage:
#   ./benchmark.sh

# Required environment variables
: "${FIREBOLT_CLIENT_ID:?ERROR: Set FIREBOLT_CLIENT_ID}"
: "${FIREBOLT_CLIENT_SECRET:?ERROR: Set FIREBOLT_CLIENT_SECRET}"
: "${FIREBOLT_ACCOUNT:?ERROR: Set FIREBOLT_ACCOUNT}"
: "${FIREBOLT_ENGINE:?ERROR: Set FIREBOLT_ENGINE}"
: "${FIREBOLT_DATABASE:?ERROR: Set FIREBOLT_DATABASE}"

echo "=== Firebolt Cloud ClickBench Benchmark ==="
echo "Account:  $FIREBOLT_ACCOUNT"
echo "Engine:   $FIREBOLT_ENGINE"
echo "Database: $FIREBOLT_DATABASE"
echo ""

# Get access token
echo "Authenticating with Firebolt Cloud..."
ACCESS_TOKEN=$(curl -s -X POST "https://id.app.firebolt.io/oauth/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=${FIREBOLT_CLIENT_ID}" \
    -d "client_secret=${FIREBOLT_CLIENT_SECRET}" \
    -d "grant_type=client_credentials" \
    -d "audience=https://api.firebolt.io" | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "ERROR: Failed to get access token"
    exit 1
fi
echo "Authentication successful!"

# Get system engine URL
echo "Getting system engine URL..."
SYSTEM_ENGINE_URL=$(curl -s "https://api.app.firebolt.io/web/v3/account/${FIREBOLT_ACCOUNT}/engineUrl" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" | jq -r '.engineUrl')

if [ -z "$SYSTEM_ENGINE_URL" ] || [ "$SYSTEM_ENGINE_URL" == "null" ]; then
    echo "ERROR: Failed to get system engine URL"
    exit 1
fi

# Get user engine URL
echo "Getting user engine URL for '${FIREBOLT_ENGINE}'..."
USER_ENGINE_URL=$(curl -s "https://${SYSTEM_ENGINE_URL}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT url FROM information_schema.engines WHERE engine_name='${FIREBOLT_ENGINE}'" | jq -r '.data[0].url')

if [ -z "$USER_ENGINE_URL" ] || [ "$USER_ENGINE_URL" == "null" ]; then
    echo "ERROR: Failed to get user engine URL. Is the engine running?"
    exit 1
fi
echo "Engine URL: $USER_ENGINE_URL"

# Function to run a SQL query
run_sql() {
    local query="$1"
    curl -s "https://${USER_ENGINE_URL}&database=${FIREBOLT_DATABASE}" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        --data "$query"
}

# Create table and load data
echo ""
echo "Creating table and loading data..."
echo "This may take several minutes..."

LOAD_START=$(date +%s)

# Read and execute create.sql
while IFS= read -r -d ';' statement; do
    # Trim whitespace and skip empty statements
    statement=$(echo "$statement" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -n "$statement" ] && [[ ! "$statement" == "--"* ]]; then
        echo "Executing: ${statement:0:60}..."
        RESULT=$(run_sql "$statement")
        ERROR=$(echo "$RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
        if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
            echo "Warning: $ERROR"
        fi
    fi
done < create.sql

LOAD_END=$(date +%s)
LOAD_TIME=$((LOAD_END - LOAD_START))
echo "Load time: ${LOAD_TIME} seconds"

# Get data size
echo ""
echo "Getting table statistics..."
STATS_RESULT=$(run_sql "SELECT compressed_bytes, uncompressed_bytes FROM information_schema.tables WHERE table_name = 'hits'")
COMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].compressed_bytes // 0')
UNCOMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].uncompressed_bytes // 0')

echo "Data size (compressed): $COMPRESSED_SIZE bytes"
echo "Uncompressed data size: $UNCOMPRESSED_SIZE bytes"

# Run the benchmark
echo ""
echo "Running the benchmark..."
./run.sh | tee benchmark_output.txt

# Generate result JSON
DATE_ISO="$(date -u +%F)"
MACHINE="Firebolt Cloud"
CLUSTER_SIZE=1

# Extract results from benchmark output (lines starting with [)
RESULTS=$(grep -E '^\[' benchmark_output.txt | tr '\n' ' ' | sed 's/,\s*$//' | sed 's/\], \[/],\n[/g')

mkdir -p results

cat > results/firebolt_cloud.json <<EOF
{
    "system": "Firebolt Cloud",
    "date": "$DATE_ISO",
    "machine": "$MACHINE",
    "cluster_size": $CLUSTER_SIZE,
    "proprietary": "yes",
    "tuned": "no",
    "comment": "Firebolt Cloud (${FIREBOLT_ENGINE})",
    "tags": ["C++", "column-oriented", "PostgreSQL compatible", "managed", "aws"],
    "load_time": $LOAD_TIME,
    "data_size": ${COMPRESSED_SIZE:-0},
    "result": [
$RESULTS
    ]
}
EOF

echo ""
echo "Results saved to results/firebolt_cloud.json"
rm -f benchmark_output.txt

echo ""
echo "Benchmark complete!"
