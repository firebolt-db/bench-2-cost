#!/bin/bash
set -euo pipefail

# Firebolt Cloud - Create Scaled Tables (1B/10B/100B rows)
#
# Creates scaled versions of the hits table using generate_series() cross join.
# Each level builds on the previous one (cascading expansion):
#
# Table hierarchy:
#   hits      (~100M rows) - Base table from clickbench.public.hits
#   hits_1b   (~1B rows)   - hits × 10
#   hits_10b  (~10B rows)  - hits_1b × 10
#   hits_100b (~100B rows) - hits_10b × 10
#
# If a source table doesn't exist, it will be created first.
# Only the target table is dropped and recreated.
#
# NOTE: The original 'hits' table is NOT modified.
#
# Required Environment Variables:
#   FIREBOLT_CLIENT_ID     - Service account client ID
#   FIREBOLT_CLIENT_SECRET - Service account client secret
#   FIREBOLT_ACCOUNT       - Firebolt account name
#   FIREBOLT_ENGINE        - Engine name to use
#   FIREBOLT_DATABASE      - Database name
#
# Usage:
#   ./create_scaled.sh 1 --engine ENGINE_NAME      # Create hits_1b from hits
#   ./create_scaled.sh 10 --engine ENGINE_NAME     # Create hits_10b from hits_1b
#   ./create_scaled.sh 100 --engine ENGINE_NAME    # Create hits_100b from hits_10b
#   ./create_scaled.sh all --engine ENGINE_NAME    # Create all scaled tables

# Parse arguments
SCALE=""
ENGINE_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine)
            ENGINE_ARG="$2"
            shift 2
            ;;
        1|10|100|all)
            SCALE="$1"
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ -z "$SCALE" ]; then
    echo "Usage: ./create_scaled.sh [1|10|100|all] --engine ENGINE_NAME"
    echo ""
    echo "  1    - Create hits_1b (~1B rows) from hits × 10"
    echo "  10   - Create hits_10b (~10B rows) from hits_1b × 10"
    echo "  100  - Create hits_100b (~100B rows) from hits_10b × 10"
    echo "  all  - Create all scaled tables in order"
    echo ""
    echo "Options:"
    echo "  --engine ENGINE_NAME  Engine to use for the operation"
    echo ""
    echo "NOTE: Each level builds on the previous. Missing source tables are created automatically."
    exit 1
fi

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

echo "=== Firebolt Cloud - Create Scaled Tables ==="
echo "Account:  $FIREBOLT_ACCOUNT"
echo "Engine:   $FIREBOLT_ENGINE"
echo "Database: $FIREBOLT_DATABASE"
echo "Scale:    $SCALE"
echo ""
echo "Hierarchy: hits -> hits_1b -> hits_10b -> hits_100b (each 10x)"
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
    local result=$(run_sql "SELECT COUNT(*) as cnt FROM $table" 2>/dev/null)
    echo "$result" | jq -r '.data[0].cnt // 0' 2>/dev/null || echo "0"
}

# Function to check if table exists
table_exists() {
    local table="$1"
    local result=$(run_sql "SELECT table_name FROM information_schema.tables WHERE table_name = '$table'" 2>/dev/null)
    local count=$(echo "$result" | jq -r '.data | length' 2>/dev/null || echo "0")
    [ "$count" -gt 0 ]
}

# Function to create a scaled table from a source table
# Args: source_table, target_table, scale_factor
create_table_from() {
    local source_table="$1"
    local target_table="$2"
    local scale_factor="$3"
    
    echo ""
    echo "=== Creating $target_table from $source_table (×$scale_factor) ==="
    
    # Check source table exists and has data
    SOURCE_COUNT=$(get_row_count "$source_table")
    if [ "$SOURCE_COUNT" == "0" ] || [ "$SOURCE_COUNT" == "null" ]; then
        echo "ERROR: $source_table is empty or does not exist."
        exit 1
    fi
    echo "Source $source_table has $SOURCE_COUNT rows"
    
    # Calculate expected target
    EXPECTED_COUNT=$((SOURCE_COUNT * scale_factor))
    echo "Expected rows: $EXPECTED_COUNT"
    
    # Drop existing target table
    echo "Dropping existing $target_table if exists..."
    run_sql "DROP TABLE IF EXISTS $target_table" > /dev/null
    
    # Create using generate_series
    echo "Creating $target_table with generate_series(1, $scale_factor)..."
    LOAD_START=$(date +%s)
    
    RESULT=$(run_sql "CREATE TABLE $target_table
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT ${source_table}.* FROM ${source_table}, generate_series(1, $scale_factor)")
    
    # Check for errors
    ERROR=$(echo "$RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
        echo "ERROR: $ERROR"
        exit 1
    fi
    
    LOAD_END=$(date +%s)
    LOAD_TIME=$((LOAD_END - LOAD_START))
    echo "Created in ${LOAD_TIME} seconds"
    
    # Get final count
    FINAL_COUNT=$(get_row_count "$target_table")
    echo "Final rows: $FINAL_COUNT"
    
    echo "$target_table created successfully!"
}

# Function to ensure hits_1b exists (creates from hits if needed)
ensure_hits_1b() {
    if ! table_exists "hits_1b"; then
        echo ""
        echo "hits_1b does not exist. Creating it first..."
        
        # Check hits table exists
        if ! table_exists "hits"; then
            echo "ERROR: Base 'hits' table does not exist. Load it first."
            exit 1
        fi
        
        create_table_from "hits" "hits_1b" 10
    else
        echo "hits_1b exists ($(get_row_count hits_1b) rows)"
    fi
}

# Function to ensure hits_10b exists (creates from hits_1b if needed)
ensure_hits_10b() {
    if ! table_exists "hits_10b"; then
        echo ""
        echo "hits_10b does not exist. Creating it first..."
        ensure_hits_1b
        create_table_from "hits_1b" "hits_10b" 10
    else
        echo "hits_10b exists ($(get_row_count hits_10b) rows)"
    fi
}

# Create hits_1b: hits × 10
create_hits_1b() {
    # Check hits table exists
    if ! table_exists "hits"; then
        echo "ERROR: Base 'hits' table does not exist. Load it first."
        exit 1
    fi
    
    create_table_from "hits" "hits_1b" 10
}

# Create hits_10b: hits_1b × 10
create_hits_10b() {
    ensure_hits_1b
    create_table_from "hits_1b" "hits_10b" 10
}

# Create hits_100b: hits_10b × 10
create_hits_100b() {
    ensure_hits_10b
    create_table_from "hits_10b" "hits_100b" 10
}

# Execute based on scale argument
case "$SCALE" in
    1)
        create_hits_1b
        ;;
    10)
        create_hits_10b
        ;;
    100)
        create_hits_100b
        ;;
    all)
        create_hits_1b
        create_hits_10b
        create_hits_100b
        ;;
esac

echo ""
echo "Done!"
echo ""
echo "Original 'hits' table is unchanged."
