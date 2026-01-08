#!/bin/bash
set -euo pipefail

# Firebolt Cloud - ClickBench Benchmark Script
#
# This script:
#   1. Loads the initial hits table from clickbench.public.hits if it doesn't exist
#   2. Expands the data to the target size (1B, 10B, 100B) using cascading expansion
#   3. Always drops and recreates the target table
#   4. Runs the benchmark queries
#
# Data scaling (cascading - each level builds on previous):
#   hits      (~100M rows) - Original source from clickbench.public.hits
#   hits_1b   (~1B rows)   - hits × 10
#   hits_10b  (~10B rows)  - hits_1b × 10
#   hits_100b (~100B rows) - hits_10b × 10
#
# Required Environment Variables:
#   FIREBOLT_CLIENT_ID     - Service account client ID
#   FIREBOLT_CLIENT_SECRET - Service account client secret
#   FIREBOLT_ACCOUNT       - Firebolt account name
#   FIREBOLT_DATABASE      - Database name
#
# Usage:
#   ./benchmark.sh --engine ENGINE_NAME --size 1B [--skip-load] [--skip-run]
#   ./benchmark.sh --engine ENGINE_NAME --size 10B [--skip-load] [--skip-run]
#   ./benchmark.sh --engine ENGINE_NAME --size 100B [--skip-load] [--skip-run]
#
# Options:
#   --engine ENGINE_NAME  Engine to use for the benchmark (required)
#   --size SIZE           Target data size: 1B, 10B, or 100B (required)
#   --skip-load           Skip data loading, assume tables exist
#   --skip-run            Only load data, don't run benchmark

# Parse arguments
ENGINE_NAME=""
TARGET_SIZE=""
SKIP_LOAD=false
SKIP_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine|-e)
            ENGINE_NAME="$2"
            shift 2
            ;;
        --size|-s)
            TARGET_SIZE="$2"
            shift 2
            ;;
        --skip-load)
            SKIP_LOAD=true
            shift
            ;;
        --skip-run)
            SKIP_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./benchmark.sh --engine ENGINE_NAME --size SIZE [options]"
            echo ""
            echo "Required:"
            echo "  --engine, -e      Engine name to use"
            echo "  --size, -s        Target data size: 1B, 10B, or 100B"
            echo ""
            echo "Options:"
            echo "  --skip-load       Skip data loading, assume tables exist"
            echo "  --skip-run        Only load data, don't run benchmark"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Data hierarchy: hits -> hits_1b -> hits_10b -> hits_100b (each 10x)"
            echo ""
            echo "Examples:"
            echo "  ./benchmark.sh --engine my_engine --size 1B"
            echo "  ./benchmark.sh --engine my_engine --size 100B"
            echo "  ./benchmark.sh --engine my_engine --size 10B --skip-load"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$ENGINE_NAME" ]; then
    echo "ERROR: Engine name is required. Use --engine ENGINE_NAME"
    exit 1
fi

if [ -z "$TARGET_SIZE" ]; then
    echo "ERROR: Target size is required. Use --size [1B|10B|100B]"
    exit 1
fi

# Normalize and validate size (cascading expansion)
case "$TARGET_SIZE" in
    1B|1b)
        TARGET_SIZE="1B"
        TARGET_TABLE="hits_1b"
        SOURCE_TABLE="hits"
        SCALE_FACTOR=10
        ;;
    10B|10b)
        TARGET_SIZE="10B"
        TARGET_TABLE="hits_10b"
        SOURCE_TABLE="hits_1b"
        SCALE_FACTOR=10
        ;;
    100B|100b)
        TARGET_SIZE="100B"
        TARGET_TABLE="hits_100b"
        SOURCE_TABLE="hits_10b"
        SCALE_FACTOR=10
        ;;
    *)
        echo "ERROR: Invalid size '$TARGET_SIZE'. Must be 1B, 10B, or 100B"
        exit 1
        ;;
esac

# Required environment variables
: "${FIREBOLT_CLIENT_ID:?ERROR: Set FIREBOLT_CLIENT_ID}"
: "${FIREBOLT_CLIENT_SECRET:?ERROR: Set FIREBOLT_CLIENT_SECRET}"
: "${FIREBOLT_ACCOUNT:?ERROR: Set FIREBOLT_ACCOUNT}"
: "${FIREBOLT_DATABASE:?ERROR: Set FIREBOLT_DATABASE}"

echo "=== Firebolt Cloud - ClickBench Benchmark ==="
echo "Account:   $FIREBOLT_ACCOUNT"
echo "Engine:    $ENGINE_NAME"
echo "Database:  $FIREBOLT_DATABASE"
echo "Size:      $TARGET_SIZE"
echo "Table:     $TARGET_TABLE"
echo "Source:    $SOURCE_TABLE"
echo "Skip Load: $SKIP_LOAD"
echo "Skip Run:  $SKIP_RUN"
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
echo "Getting user engine URL for '${ENGINE_NAME}'..."
USER_ENGINE_URL=$(curl -s "https://${SYSTEM_ENGINE_URL}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    --data "SELECT url FROM information_schema.engines WHERE engine_name='${ENGINE_NAME}'" | jq -r '.data[0].url')

if [ -z "$USER_ENGINE_URL" ] || [ "$USER_ENGINE_URL" == "null" ]; then
    echo "ERROR: Failed to get user engine URL. Is the engine running?"
    exit 1
fi
echo "Engine URL: $USER_ENGINE_URL"

# Function to run a SQL query on user engine
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

# Function to create a table from a source table
# Args: source_table, target_table, scale_factor
create_table_from() {
    local src="$1"
    local tgt="$2"
    local scale="$3"
    
    echo ""
    echo "Creating $tgt from $src (×$scale)..."
    
    local src_count=$(get_row_count "$src")
    echo "Source $src has $src_count rows"
    
    run_sql "DROP TABLE IF EXISTS $tgt" > /dev/null
    
    local result=$(run_sql "CREATE TABLE $tgt
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT ${src}.* FROM ${src}, generate_series(1, $scale)")
    
    local error=$(echo "$result" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$error" ] && [ "$error" != "null" ]; then
        echo "ERROR creating $tgt: $error"
        exit 1
    fi
    
    local tgt_count=$(get_row_count "$tgt")
    echo "$tgt created with $tgt_count rows"
}

# ============================================================
# DATA LOADING
# ============================================================

LOAD_TIME=0

if [ "$SKIP_LOAD" = false ]; then
    echo ""
    echo "=========================================="
    echo "DATA LOADING"
    echo "=========================================="
    
    # Step 1: Load base hits table if it doesn't exist
    echo ""
    echo "Checking if base 'hits' table exists..."
    if ! table_exists "hits"; then
        echo "Base 'hits' table not found. Creating from clickbench.public.hits..."
        
        BASE_LOAD_START=$(date +%s)
        
        # Create hits table with proper schema
        RESULT=$(run_sql "CREATE TABLE IF NOT EXISTS hits (
    WatchID BIGINT NOT NULL,
    JavaEnable INTEGER NOT NULL,
    Title TEXT NOT NULL,
    GoodEvent INTEGER NOT NULL,
    EventTime TIMESTAMP NOT NULL,
    EventDate DATE NOT NULL,
    CounterID INTEGER NOT NULL,
    ClientIP INTEGER NOT NULL,
    RegionID INTEGER NOT NULL,
    UserID BIGINT NOT NULL,
    CounterClass INTEGER NOT NULL,
    OS INTEGER NOT NULL,
    UserAgent INTEGER NOT NULL,
    URL TEXT NOT NULL,
    Referer TEXT NOT NULL,
    IsRefresh INTEGER NOT NULL,
    RefererCategoryID INTEGER NOT NULL,
    RefererRegionID INTEGER NOT NULL,
    URLCategoryID INTEGER NOT NULL,
    URLRegionID INTEGER NOT NULL,
    ResolutionWidth INTEGER NOT NULL,
    ResolutionHeight INTEGER NOT NULL,
    ResolutionDepth INTEGER NOT NULL,
    FlashMajor INTEGER NOT NULL,
    FlashMinor INTEGER NOT NULL,
    FlashMinor2 TEXT NOT NULL,
    NetMajor INTEGER NOT NULL,
    NetMinor INTEGER NOT NULL,
    UserAgentMajor INTEGER NOT NULL,
    UserAgentMinor VARCHAR(255) NOT NULL,
    CookieEnable INTEGER NOT NULL,
    JavascriptEnable INTEGER NOT NULL,
    IsMobile INTEGER NOT NULL,
    MobilePhone INTEGER NOT NULL,
    MobilePhoneModel TEXT NOT NULL,
    Params TEXT NOT NULL,
    IPNetworkID INTEGER NOT NULL,
    TraficSourceID INTEGER NOT NULL,
    SearchEngineID INTEGER NOT NULL,
    SearchPhrase TEXT NOT NULL,
    AdvEngineID INTEGER NOT NULL,
    IsArtifical INTEGER NOT NULL,
    WindowClientWidth INTEGER NOT NULL,
    WindowClientHeight INTEGER NOT NULL,
    ClientTimeZone INTEGER NOT NULL,
    ClientEventTime TIMESTAMP NOT NULL,
    SilverlightVersion1 INTEGER NOT NULL,
    SilverlightVersion2 INTEGER NOT NULL,
    SilverlightVersion3 INTEGER NOT NULL,
    SilverlightVersion4 INTEGER NOT NULL,
    PageCharset TEXT NOT NULL,
    CodeVersion INTEGER NOT NULL,
    IsLink INTEGER NOT NULL,
    IsDownload INTEGER NOT NULL,
    IsNotBounce INTEGER NOT NULL,
    FUniqID BIGINT NOT NULL,
    OriginalURL TEXT NOT NULL,
    HID INTEGER NOT NULL,
    IsOldCounter INTEGER NOT NULL,
    IsEvent INTEGER NOT NULL,
    IsParameter INTEGER NOT NULL,
    DontCountHits INTEGER NOT NULL,
    WithHash INTEGER NOT NULL,
    HitColor TEXT NOT NULL,
    LocalEventTime TIMESTAMP NOT NULL,
    Age INTEGER NOT NULL,
    Sex INTEGER NOT NULL,
    Income INTEGER NOT NULL,
    Interests INTEGER NOT NULL,
    Robotness INTEGER NOT NULL,
    RemoteIP INTEGER NOT NULL,
    WindowName INTEGER NOT NULL,
    OpenerName INTEGER NOT NULL,
    HistoryLength INTEGER NOT NULL,
    BrowserLanguage TEXT NOT NULL,
    BrowserCountry TEXT NOT NULL,
    SocialNetwork TEXT NOT NULL,
    SocialAction TEXT NOT NULL,
    HTTPError INTEGER NOT NULL,
    SendTiming INTEGER NOT NULL,
    DNSTiming INTEGER NOT NULL,
    ConnectTiming INTEGER NOT NULL,
    ResponseStartTiming INTEGER NOT NULL,
    ResponseEndTiming INTEGER NOT NULL,
    FetchTiming INTEGER NOT NULL,
    SocialSourceNetworkID INTEGER NOT NULL,
    SocialSourcePage TEXT NOT NULL,
    ParamPrice BIGINT NOT NULL,
    ParamOrderID TEXT NOT NULL,
    ParamCurrency TEXT NOT NULL,
    ParamCurrencyID INTEGER NOT NULL,
    OpenstatServiceName TEXT NOT NULL,
    OpenstatCampaignID TEXT NOT NULL,
    OpenstatAdID TEXT NOT NULL,
    OpenstatSourceID TEXT NOT NULL,
    UTMSource TEXT NOT NULL,
    UTMMedium TEXT NOT NULL,
    UTMCampaign TEXT NOT NULL,
    UTMContent TEXT NOT NULL,
    UTMTerm TEXT NOT NULL,
    FromTag TEXT NOT NULL,
    HasGCLID INTEGER NOT NULL,
    RefererHash BIGINT NOT NULL,
    URLHash BIGINT NOT NULL,
    CLID INTEGER NOT NULL
)
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID")
        
        # Check for errors
        ERROR=$(echo "$RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
        if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
            echo "ERROR creating hits table: $ERROR"
            exit 1
        fi
        
        # Load data from shared dataset
        echo "Loading data from clickbench.public.hits..."
        RESULT=$(run_sql "INSERT INTO hits SELECT * FROM clickbench.public.hits")
        
        ERROR=$(echo "$RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
        if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
            echo "ERROR loading hits data: $ERROR"
            exit 1
        fi
        
        BASE_LOAD_END=$(date +%s)
        BASE_LOAD_TIME=$((BASE_LOAD_END - BASE_LOAD_START))
        
        HITS_COUNT=$(get_row_count "hits")
        echo "Base 'hits' table created with $HITS_COUNT rows in ${BASE_LOAD_TIME}s"
    else
        HITS_COUNT=$(get_row_count "hits")
        echo "Base 'hits' table exists with $HITS_COUNT rows"
    fi
    
    # Step 2: Ensure prerequisite tables exist (for 10B and 100B)
    if [ "$TARGET_SIZE" = "10B" ]; then
        # Need hits_1b to exist
        if ! table_exists "hits_1b"; then
            echo ""
            echo "Prerequisite hits_1b does not exist. Creating it first..."
            create_table_from "hits" "hits_1b" 10
        else
            echo "Prerequisite hits_1b exists ($(get_row_count hits_1b) rows)"
        fi
    elif [ "$TARGET_SIZE" = "100B" ]; then
        # Need hits_1b and hits_10b to exist
        if ! table_exists "hits_1b"; then
            echo ""
            echo "Prerequisite hits_1b does not exist. Creating it first..."
            create_table_from "hits" "hits_1b" 10
        else
            echo "Prerequisite hits_1b exists ($(get_row_count hits_1b) rows)"
        fi
        
        if ! table_exists "hits_10b"; then
            echo ""
            echo "Prerequisite hits_10b does not exist. Creating it first..."
            create_table_from "hits_1b" "hits_10b" 10
        else
            echo "Prerequisite hits_10b exists ($(get_row_count hits_10b) rows)"
        fi
    fi
    
    # Step 3: Create target table (always drop and recreate from source)
    echo ""
    echo "Creating target table '$TARGET_TABLE' from '$SOURCE_TABLE' (×$SCALE_FACTOR)..."
    
    LOAD_START=$(date +%s)
    
    SOURCE_COUNT=$(get_row_count "$SOURCE_TABLE")
    echo "Source $SOURCE_TABLE has $SOURCE_COUNT rows"
    
    echo "Dropping existing $TARGET_TABLE if exists..."
    run_sql "DROP TABLE IF EXISTS $TARGET_TABLE" > /dev/null
    
    echo "Creating $TARGET_TABLE with generate_series(1, $SCALE_FACTOR)..."
    RESULT=$(run_sql "CREATE TABLE $TARGET_TABLE
PRIMARY INDEX CounterID, EventDate, UserID, EventTime, WatchID
AS SELECT ${SOURCE_TABLE}.* FROM ${SOURCE_TABLE}, generate_series(1, $SCALE_FACTOR)")
    
    ERROR=$(echo "$RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$ERROR" ] && [ "$ERROR" != "null" ]; then
        echo "ERROR creating $TARGET_TABLE: $ERROR"
        exit 1
    fi
    
    LOAD_END=$(date +%s)
    LOAD_TIME=$((LOAD_END - LOAD_START))
    
    TARGET_COUNT=$(get_row_count "$TARGET_TABLE")
    echo "$TARGET_TABLE created with $TARGET_COUNT rows in ${LOAD_TIME}s"
    
    # Get table size
    STATS_RESULT=$(run_sql "SELECT compressed_bytes, uncompressed_bytes FROM information_schema.tables WHERE table_name = '$TARGET_TABLE'")
    COMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].compressed_bytes // 0')
    UNCOMPRESSED_SIZE=$(echo "$STATS_RESULT" | jq -r '.data[0].uncompressed_bytes // 0')
    echo "Compressed: $(numfmt --to=iec-i --suffix=B $COMPRESSED_SIZE 2>/dev/null || echo "$COMPRESSED_SIZE bytes")"
    echo "Uncompressed: $(numfmt --to=iec-i --suffix=B $UNCOMPRESSED_SIZE 2>/dev/null || echo "$UNCOMPRESSED_SIZE bytes")"
fi

# ============================================================
# BENCHMARK EXECUTION
# ============================================================

if [ "$SKIP_RUN" = true ]; then
    echo ""
    echo "Skipping benchmark run (--skip-run specified)"
    echo "Data loading complete."
    exit 0
fi

echo ""
echo "=========================================="
echo "RUNNING BENCHMARK"
echo "=========================================="

# Run the benchmark using run.sh, passing the load time
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/run.sh" --engine "$ENGINE_NAME" --table "$TARGET_TABLE" --load-time "$LOAD_TIME"

echo ""
echo "Benchmark complete!"
