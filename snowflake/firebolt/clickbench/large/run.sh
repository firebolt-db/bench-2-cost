#!/bin/bash
set -euo pipefail

# Firebolt Cloud ClickBench Query Runner
#
# Runs all queries from queries.sql against Firebolt Cloud via REST API.
# Each query is run 3 times and the elapsed time is extracted from the response.
#
# Required Environment Variables:
#   FIREBOLT_CLIENT_ID     - Service account client ID
#   FIREBOLT_CLIENT_SECRET - Service account client secret
#   FIREBOLT_ACCOUNT       - Firebolt account name
#   FIREBOLT_DATABASE      - Database name
#
# Optional Environment Variables:
#   FIREBOLT_ENGINE        - Engine name (can be overridden with --engine)
#
# Usage:
#   ./run.sh --engine bench2cost_3n
#   ./run.sh --engine bench2cost_3n --table hits_10b
#   ./run.sh --engine bench2cost_3n --table hits_100b
#
# Output is saved to results_{1B,10B,100B}/{engine_name}.json

TRIES=3
TABLE="hits_1b"
ENGINE_NAME=""
SKIP_TABLE_SIZE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --table|-t)
            TABLE="$2"
            shift 2
            ;;
        --engine|-e)
            ENGINE_NAME="$2"
            shift 2
            ;;
        --skip-table-size)
            SKIP_TABLE_SIZE=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./run.sh --engine ENGINE_NAME [--table TABLE_NAME] [--skip-table-size]"
            echo ""
            echo "Options:"
            echo "  --engine, -e      Engine name (required)"
            echo "  --table, -t       Table to query (default: hits_1b)"
            echo "                    Options: hits_1b, hits_10b, hits_100b"
            echo "  --skip-table-size Skip querying table size (faster startup)"
            echo ""
            echo "Output is saved to results_{1B,10B,100B}/{engine_name}.json"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: ./run.sh --engine ENGINE_NAME [--table TABLE_NAME] [--skip-table-size]" >&2
            exit 1
            ;;
    esac
done

# Engine name is required (from arg or env var)
if [ -z "$ENGINE_NAME" ]; then
    ENGINE_NAME="${FIREBOLT_ENGINE:-}"
fi

if [ -z "$ENGINE_NAME" ]; then
    echo "ERROR: Engine name required. Use --engine or set FIREBOLT_ENGINE" >&2
    exit 1
fi

# Determine output directory based on table
case "$TABLE" in
    hits_1b)
        OUTPUT_DIR="results_1B"
        ;;
    hits_10b)
        OUTPUT_DIR="results_10B"
        ;;
    hits_100b)
        OUTPUT_DIR="results_100B"
        ;;
    *)
        OUTPUT_DIR="results"
        ;;
esac

OUTPUT_FILE="${OUTPUT_DIR}/${ENGINE_NAME}.json"

# Required environment variables
: "${FIREBOLT_CLIENT_ID:?ERROR: Set FIREBOLT_CLIENT_ID}"
: "${FIREBOLT_CLIENT_SECRET:?ERROR: Set FIREBOLT_CLIENT_SECRET}"
: "${FIREBOLT_ACCOUNT:?ERROR: Set FIREBOLT_ACCOUNT}"
: "${FIREBOLT_DATABASE:?ERROR: Set FIREBOLT_DATABASE}"

echo "=== Firebolt ClickBench Query Runner ===" >&2
echo "Engine:  $ENGINE_NAME" >&2
echo "Table:   $TABLE" >&2
echo "Output:  $OUTPUT_FILE" >&2
echo "" >&2

echo "Authenticating with Firebolt Cloud..." >&2
ACCESS_TOKEN=$(curl -s -X POST "https://id.app.firebolt.io/oauth/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=${FIREBOLT_CLIENT_ID}" \
    -d "client_secret=${FIREBOLT_CLIENT_SECRET}" \
    -d "grant_type=client_credentials" \
    -d "audience=https://api.firebolt.io" | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "ERROR: Failed to get access token" >&2
    exit 1
fi
echo "Authentication successful!" >&2

# Get system engine URL
echo "Getting system engine URL..." >&2
SYSTEM_ENGINE_URL=$(curl -s "https://api.app.firebolt.io/web/v3/account/${FIREBOLT_ACCOUNT}/engineUrl" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" | jq -r '.engineUrl')

if [ -z "$SYSTEM_ENGINE_URL" ] || [ "$SYSTEM_ENGINE_URL" == "null" ]; then
    echo "ERROR: Failed to get system engine URL" >&2
    exit 1
fi

# Get user engine URL
echo "Getting user engine URL for '${ENGINE_NAME}'..." >&2
USER_ENGINE_URL=$(curl -s "https://${SYSTEM_ENGINE_URL}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT url FROM information_schema.engines WHERE engine_name='${ENGINE_NAME}'" | jq -r '.data[0].url')

if [ -z "$USER_ENGINE_URL" ] || [ "$USER_ENGINE_URL" == "null" ]; then
    echo "ERROR: Failed to get user engine URL. Is the engine running?" >&2
    exit 1
fi
echo "Engine URL: $USER_ENGINE_URL" >&2

# Get engine characteristics (nodes, type, family)
echo "Getting engine characteristics..." >&2
ENGINE_INFO=$(curl -s "https://${SYSTEM_ENGINE_URL}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT nodes, type, family FROM information_schema.engines WHERE engine_name='${ENGINE_NAME}'")

ENGINE_NODES=$(echo "$ENGINE_INFO" | jq -r '.data[0].nodes // 1')
ENGINE_TYPE=$(echo "$ENGINE_INFO" | jq -r '.data[0].type // "unknown"')
ENGINE_FAMILY=$(echo "$ENGINE_INFO" | jq -r '.data[0].family // "unknown"')

echo "Engine: $ENGINE_NODES nodes, type: $ENGINE_TYPE, family: $ENGINE_FAMILY" >&2

# Get table size (compressed bytes) for cost calculation
if [ "$SKIP_TABLE_SIZE" = true ]; then
    echo "Skipping table size query (--skip-table-size)" >&2
    TABLE_ROWS=0
    TABLE_UNCOMPRESSED=0
    TABLE_COMPRESSED=0
else
    echo "Getting table size for '$TABLE'..." >&2
    TABLE_INFO=$(curl -s "https://${USER_ENGINE_URL}&database=${FIREBOLT_DATABASE}" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        --data "SELECT table_name, number_of_rows, uncompressed_bytes, compressed_bytes FROM information_schema.tables WHERE table_name = '${TABLE}'")

    TABLE_ROWS=$(echo "$TABLE_INFO" | jq -r '.data[0].number_of_rows // 0')
    TABLE_UNCOMPRESSED=$(echo "$TABLE_INFO" | jq -r '.data[0].uncompressed_bytes // 0')
    TABLE_COMPRESSED=$(echo "$TABLE_INFO" | jq -r '.data[0].compressed_bytes // 0')

    echo "Table: $TABLE_ROWS rows, compressed: $TABLE_COMPRESSED bytes, uncompressed: $TABLE_UNCOMPRESSED bytes" >&2
fi

# Query parameters for benchmarking (disable caches for consistent results)
BASE_QUERY_PARAMS="database=${FIREBOLT_DATABASE}&enable_result_cache=false&enable_subresult_cache=false&output_format=JSON_Compact"

# Determine data volume label based on table name
case "$TABLE" in
    hits_1b)
        DATA_VOLUME="1B"
        ;;
    hits_10b)
        DATA_VOLUME="10B"
        ;;
    hits_100b)
        DATA_VOLUME="100B"
        ;;
    *)
        DATA_VOLUME="unknown"
        ;;
esac

# Function to run a SQL query and get elapsed time
# Args: $1 = query, $2 = query number, $3 = attempt number
# Returns: elapsed_time|query_label (pipe-separated)
run_query() {
    local query="$1"
    local query_num="$2"
    local attempt_num="$3"
    
    # Create query label as JSON object (URL-encoded)
    # Format: {"benchmark":"clickbench","volume":"10B","query":"q05","attempt":2}
    local query_label="{\"benchmark\":\"clickbench\",\"volume\":\"${DATA_VOLUME}\",\"query\":\"q$(printf '%02d' $query_num)\",\"attempt\":${attempt_num}}"
    local encoded_label=$(printf '%s' "$query_label" | jq -sRr @uri)
    local query_params="${BASE_QUERY_PARAMS}&query_label=${encoded_label}"
    
    local response=$(curl -s "https://${USER_ENGINE_URL}&${query_params}" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        --data "$query")
    
    # Extract elapsed time from response statistics
    local elapsed=$(echo "$response" | jq -r '.statistics.elapsed // empty' 2>/dev/null)
    
    # Check for errors
    local error=$(echo "$response" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$error" ] && [ "$error" != "null" ]; then
        echo "null|null"
        echo "Query error: $error" >&2
        return
    elif [ -z "$elapsed" ] || [ "$elapsed" == "null" ]; then
        echo "null|null"
        echo "No elapsed time in response" >&2
        return
    fi
    
    printf "%.3f|%s" "$elapsed" "$query_label"
}

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Warm-up query to get the engine started
echo "" >&2
echo "Running warm-up query on '$TABLE'..." >&2
WARMUP_START=$(date +%s)
WARMUP_LABEL="{\"benchmark\":\"clickbench\",\"volume\":\"${DATA_VOLUME}\",\"query\":\"warmup\",\"attempt\":1}"
WARMUP_LABEL_ENCODED=$(printf '%s' "$WARMUP_LABEL" | jq -sRr @uri)
WARMUP_PARAMS="${BASE_QUERY_PARAMS}&query_label=${WARMUP_LABEL_ENCODED}"
curl -s "https://${USER_ENGINE_URL}&${WARMUP_PARAMS}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT CHECKSUM(*) FROM ${TABLE}" > /dev/null
WARMUP_END=$(date +%s)
echo "Warm-up complete ($(( WARMUP_END - WARMUP_START ))s)" >&2

# Count queries
QUERY_COUNT=$(grep -c '^SELECT' queries.sql || echo 0)
echo "" >&2
echo "Running $QUERY_COUNT queries on table '$TABLE', $TRIES times each..." >&2

# Collect results
RESULTS=""
QUERY_LABELS=""
QUERY_NUM=0
while IFS= read -r query; do
    # Skip empty lines and comments-only lines
    if [ -z "$query" ] || [[ "$query" == "--"* ]] || [[ "$query" == "#"* ]]; then
        continue
    fi
    
    QUERY_ID=$(printf "q%02d" $QUERY_NUM)

    # Replace 'hits' with the target table name in the query
    modified_query="${query//FROM hits/FROM $TABLE}"
    modified_query="${modified_query//JOIN hits/JOIN $TABLE}"
    
    # Extract bid comment if present, otherwise add one
    if [[ "$modified_query" =~ --\ bid:\ q[0-9]+ ]]; then
        # Query already has bid comment, use as-is
        final_query="$modified_query"
    else
        # Add bid comment
        final_query="${modified_query} -- bid: ${QUERY_ID}"
    fi
    
    # Show full query
    echo "" >&2
    echo "[$QUERY_ID] $final_query" >&2
    
    # Run the query TRIES times
    QUERY_RESULT="["
    QUERY_LABEL_RESULT="["
    for i in $(seq 1 $TRIES); do
        result=$(run_query "$final_query" "$QUERY_NUM" "$i")
        elapsed=$(echo "$result" | cut -d'|' -f1)
        qlabel=$(echo "$result" | cut -d'|' -f2-)
        echo "  Run $i: ${elapsed}s" >&2
        
        # Properly escape the JSON string for embedding (jq -Rs escapes quotes)
        escaped_qlabel=$(printf '%s' "$qlabel" | jq -Rs '.')
        
        if [ "$i" -eq 1 ]; then
            QUERY_RESULT="${QUERY_RESULT}${elapsed}"
            QUERY_LABEL_RESULT="${QUERY_LABEL_RESULT}${escaped_qlabel}"
        else
            QUERY_RESULT="${QUERY_RESULT}, ${elapsed}"
            QUERY_LABEL_RESULT="${QUERY_LABEL_RESULT}, ${escaped_qlabel}"
        fi
    done
    QUERY_RESULT="${QUERY_RESULT}]"
    QUERY_LABEL_RESULT="${QUERY_LABEL_RESULT}]"
    
    if [ -z "$RESULTS" ]; then
        RESULTS="        ${QUERY_RESULT}"
        QUERY_LABELS="        ${QUERY_LABEL_RESULT}"
    else
        RESULTS="${RESULTS},
        ${QUERY_RESULT}"
        QUERY_LABELS="${QUERY_LABELS},
        ${QUERY_LABEL_RESULT}"
    fi

    QUERY_NUM=$((QUERY_NUM + 1))
    
done < queries.sql

# Generate JSON output
DATE_ISO="$(date -u +%F)"

cat > "$OUTPUT_FILE" <<EOF
{
    "system": "Firebolt Cloud",
    "date": "$DATE_ISO",
    "machine": "${ENGINE_TYPE}_${ENGINE_FAMILY}",
    "scan_cache": false,
    "cluster_size": $ENGINE_NODES,
    "comment": "Firebolt Cloud (${ENGINE_NAME}), table: $TABLE",
    "tags": ["C++", "column-oriented", "PostgreSQL compatible", "managed", "aws"],
    "data_size": $TABLE_COMPRESSED,
    "data_size_uncompressed": $TABLE_UNCOMPRESSED,
    "row_count": $TABLE_ROWS,
    "engine": {
        "name": "$ENGINE_NAME",
        "nodes": $ENGINE_NODES,
        "type": "$ENGINE_TYPE",
        "family": "$ENGINE_FAMILY"
    },
    "result": [
$RESULTS
    ],
    "query_labels": [
$QUERY_LABELS
    ]
}
EOF

echo "" >&2
echo "Results saved to $OUTPUT_FILE" >&2
echo "Done!" >&2
