#!/bin/bash
set -euo pipefail

# Firebolt Cloud - Load 1B Hits Table
#
# Creates hits_1b (1 billion rows) by scaling the original hits table (~100M rows)
# using generate_series(1, 10).
#
# The original hits table is NOT modified.
#
# Table scaling:
#   hits      (~100M rows) - Original source table (unchanged)
#   hits_1b   (~1B rows)   - hits × 10 via generate_series
#   hits_10b  (~10B rows)  - hits_1b × 10 via generate_series
#   hits_100b (~100B rows) - hits_1b × 100 via generate_series
#
# Required Environment Variables:
#   FIREBOLT_CLIENT_ID     - Service account client ID
#   FIREBOLT_CLIENT_SECRET - Service account client secret
#   FIREBOLT_ACCOUNT       - Firebolt account name
#   FIREBOLT_ENGINE        - Engine name to use
#   FIREBOLT_DATABASE      - Database name (should be 'clickbench')
#
# Usage:
#   ./load_hits.sh --engine ENGINE_NAME

# Parse arguments
ENGINE_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine)
            ENGINE_ARG="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: ./load_hits.sh --engine ENGINE_NAME"
            exit 1
            ;;
    esac
done

# Required environment variables
: "${FIREBOLT_CLIENT_ID:?ERROR: Set FIREBOLT_CLIENT_ID}"
: "${FIREBOLT_CLIENT_SECRET:?ERROR: Set FIREBOLT_CLIENT_SECRET}"
: "${FIREBOLT_ACCOUNT:?ERROR: Set FIREBOLT_ACCOUNT}"
: "${FIREBOLT_DATABASE:?ERROR: Set FIREBOLT_DATABASE}"

# Use engine from argument or environment variable
if [ -n "$ENGINE_ARG" ]; then
    FIREBOLT_ENGINE="$ENGINE_ARG"
elif [ -z "${FIREBOLT_ENGINE:-}" ]; then
    echo "ERROR: Engine not specified. Use --engine ENGINE_NAME or set FIREBOLT_ENGINE"
    exit 1
fi

# Table names
SOURCE_TABLE="hits"
TARGET_TABLE="hits_1b"
SCALE_FACTOR=10

echo "=== Firebolt Cloud - Create 1B Hits Table ==="
echo "Account:  $FIREBOLT_ACCOUNT"
echo "Engine:   $FIREBOLT_ENGINE"
echo "Database: $FIREBOLT_DATABASE"
echo "Source:   public.${SOURCE_TABLE} (~100M rows)"
echo "Target:   ${TARGET_TABLE} (~1B rows)"
echo "Scale:    ${SCALE_FACTOR}x via generate_series"
echo ""
echo "NOTE: Original 'hits' table will NOT be modified."
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

# Function to get row count
get_row_count() {
    local table="$1"
    local result=$(run_sql "SELECT COUNT(*) as cnt FROM $table")
    echo "$result" | jq -r '.data[0].cnt // 0'
}

# Check source table exists
echo ""
echo "Checking source table public.${SOURCE_TABLE}..."
SOURCE_COUNT=$(get_row_count "public.${SOURCE_TABLE}")
if [ "$SOURCE_COUNT" == "0" ] || [ "$SOURCE_COUNT" == "null" ]; then
    echo "ERROR: Source table public.${SOURCE_TABLE} does not exist or is empty"
    exit 1
fi
echo "Source table has $SOURCE_COUNT rows"

# Calculate target
TARGET_COUNT=$((SOURCE_COUNT * SCALE_FACTOR))
echo "Target rows: $TARGET_COUNT (${SOURCE_COUNT} × ${SCALE_FACTOR})"

echo ""
echo "Dropping existing ${TARGET_TABLE} table if exists..."
run_sql "DROP TABLE IF EXISTS ${TARGET_TABLE}" > /dev/null

echo "Creating ${TARGET_TABLE} with generate_series(1, ${SCALE_FACTOR})..."
LOAD_START=$(date +%s)

LOAD_RESULT=$(run_sql "CREATE TABLE ${TARGET_TABLE}
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT ${SOURCE_TABLE}.* FROM public.${SOURCE_TABLE} AS ${SOURCE_TABLE}, generate_series(1, ${SCALE_FACTOR})")

LOAD_END=$(date +%s)
LOAD_TIME=$((LOAD_END - LOAD_START))

# Check for errors
ERROR=$(echo "$LOAD_RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
    echo "ERROR during load: $ERROR"
    exit 1
fi

echo ""
echo "Load complete!"
echo "Load time: ${LOAD_TIME} seconds"

# Get row count
ROW_COUNT=$(get_row_count "${TARGET_TABLE}")
echo "Rows created: $ROW_COUNT"

# Get table size
STATS_RESULT=$(run_sql "SELECT compressed_bytes, uncompressed_bytes FROM information_schema.tables WHERE table_name = '${TARGET_TABLE}'")
COMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].compressed_bytes // 0')
UNCOMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].uncompressed_bytes // 0')

echo "Compressed size: $COMPRESSED_SIZE bytes"
echo "Uncompressed size: $UNCOMPRESSED_SIZE bytes"
echo ""
echo "Table ${TARGET_TABLE} (~1B rows) ready for benchmarking."
echo "Use './create_scaled.sh 10' to create hits_10b (~10B rows)."
echo ""
echo "Original 'hits' table is unchanged."
