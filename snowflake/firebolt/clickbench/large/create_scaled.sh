#!/bin/bash
set -euo pipefail

# Firebolt Cloud - Create Scaled Tables (10B/100B rows)
#
# Creates scaled versions of the hits table using generate_series() cross join.
# hits_10b from hits_1b (×10), hits_100b from hits_1b (×100).
#
# Table naming:
#   hits_1b   - Base table (~1B rows, hits × 10)
#   hits_10b  - 10x scaled (~10B rows, hits_1b × 10)
#   hits_100b - 100x scaled (~100B rows, hits_1b × 100)
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
#   ./create_scaled.sh 10 --engine ENGINE_NAME     # Create hits_10b (10x rows) from hits_1b
#   ./create_scaled.sh 100 --engine ENGINE_NAME    # Create hits_100b (100x rows) from hits_1b
#   ./create_scaled.sh all --engine ENGINE_NAME    # Create both hits_10b and hits_100b

# Parse arguments
SCALE=""
ENGINE_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine)
            ENGINE_ARG="$2"
            shift 2
            ;;
        10|100|all)
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
    echo "Usage: ./create_scaled.sh [10|100|all] --engine ENGINE_NAME"
    echo ""
    echo "  10   - Create hits_10b table (10x rows) from hits_1b"
    echo "  100  - Create hits_100b table (100x rows) from hits_1b"
    echo "  all  - Create both hits_10b and hits_100b"
    echo ""
    echo "Options:"
    echo "  --engine ENGINE_NAME  Engine to use for the operation"
    echo ""
    echo "NOTE: Original 'hits' table is never modified."
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

# Function to create hits_10b
create_hits_10b() {
    echo ""
    echo "=== Creating hits_10b (10x scale) ==="
    
    # Check source table exists
    SOURCE_COUNT=$(get_row_count "hits_1b")
    if [ "$SOURCE_COUNT" == "0" ] || [ "$SOURCE_COUNT" == "null" ]; then
        echo "ERROR: hits_1b table is empty or does not exist. Run load_hits.sh first."
        exit 1
    fi
    echo "Source hits_1b table has $SOURCE_COUNT rows"
    
    # Calculate target
    TARGET_COUNT=$((SOURCE_COUNT * 10))
    echo "Target rows: $TARGET_COUNT"
    
    # Drop existing table
    echo "Dropping existing hits_10b table if exists..."
    run_sql "DROP TABLE IF EXISTS hits_10b" > /dev/null
    
    # Create using generate_series
    echo "Creating hits_10b with generate_series(1, 10)..."
    LOAD_START=$(date +%s)
    
    RESULT=$(run_sql "CREATE TABLE hits_10b
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT hits_1b.* FROM hits_1b, generate_series(1, 10)")
    
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
    FINAL_COUNT=$(get_row_count "hits_10b")
    echo "Final rows: $FINAL_COUNT"
    
    echo "hits_10b table created successfully!"
}

# Function to create hits_100b
create_hits_100b() {
    echo ""
    echo "=== Creating hits_100b (100x scale) ==="
    
    # Check source table exists
    SOURCE_COUNT=$(get_row_count "hits_1b")
    if [ "$SOURCE_COUNT" == "0" ] || [ "$SOURCE_COUNT" == "null" ]; then
        echo "ERROR: hits_1b table is empty or does not exist. Run './load_hits.sh' first."
        exit 1
    fi
    echo "Source hits_1b table has $SOURCE_COUNT rows"
    
    # Calculate target
    TARGET_COUNT=$((SOURCE_COUNT * 100))
    echo "Target rows: $TARGET_COUNT"
    
    # Drop existing table
    echo "Dropping existing hits_100b table if exists..."
    run_sql "DROP TABLE IF EXISTS hits_100b" > /dev/null
    
    # Create using generate_series (from hits_1b with 100x scale)
    echo "Creating hits_100b with generate_series(1, 100) from hits_1b..."
    LOAD_START=$(date +%s)
    
    RESULT=$(run_sql "CREATE TABLE hits_100b
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT hits_1b.* FROM hits_1b, generate_series(1, 100)")
    
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
    FINAL_COUNT=$(get_row_count "hits_100b")
    echo "Final rows: $FINAL_COUNT"
    
    echo "hits_100b table created successfully!"
}

# Execute based on scale argument
case "$SCALE" in
    10)
        create_hits_10b
        ;;
    100)
        create_hits_100b
        ;;
    all)
        create_hits_10b
        create_hits_100b
        ;;
esac

echo ""
echo "Done!"
echo ""
echo "Original 'hits' table is unchanged."
