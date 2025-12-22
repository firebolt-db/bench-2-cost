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

# Check if source table exists
echo ""
echo "Checking if source table public.${SOURCE_TABLE} exists..."
TABLE_EXISTS=$(run_sql "SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_name = '${SOURCE_TABLE}' AND table_schema = 'public' AND database_name = '${FIREBOLT_DATABASE}'" | jq -r '.data[0].cnt // 0')

if [ "$TABLE_EXISTS" == "0" ] || [ "$TABLE_EXISTS" == "null" ]; then
    echo "Source table ${SOURCE_TABLE} does not exist. Creating and loading from S3..."
    echo ""
    
    LOAD_BASE_START=$(date +%s)
    
    # Step 1: Create EXTERNAL TABLE to read parquet files from S3 (mixed case to match parquet)
    echo "Creating external table hits_external..."
    EXT_RESULT=$(run_sql "CREATE EXTERNAL TABLE IF NOT EXISTS hits_external (
    \"WatchID\" BIGINT,
    \"JavaEnable\" INTEGER,
    \"Title\" BYTEA,
    \"GoodEvent\" INTEGER,
    \"EventTime\" BIGINT,
    \"EventDate\" INTEGER,
    \"CounterID\" INTEGER,
    \"ClientIP\" INTEGER,
    \"RegionID\" INTEGER,
    \"UserID\" BIGINT,
    \"CounterClass\" INTEGER,
    \"OS\" INTEGER,
    \"UserAgent\" INTEGER,
    \"URL\" BYTEA,
    \"Referer\" BYTEA,
    \"IsRefresh\" INTEGER,
    \"RefererCategoryID\" INTEGER,
    \"RefererRegionID\" INTEGER,
    \"URLCategoryID\" INTEGER,
    \"URLRegionID\" INTEGER,
    \"ResolutionWidth\" INTEGER,
    \"ResolutionHeight\" INTEGER,
    \"ResolutionDepth\" INTEGER,
    \"FlashMajor\" INTEGER,
    \"FlashMinor\" INTEGER,
    \"FlashMinor2\" BYTEA,
    \"NetMajor\" INTEGER,
    \"NetMinor\" INTEGER,
    \"UserAgentMajor\" INTEGER,
    \"UserAgentMinor\" BYTEA,
    \"CookieEnable\" INTEGER,
    \"JavascriptEnable\" INTEGER,
    \"IsMobile\" INTEGER,
    \"MobilePhone\" INTEGER,
    \"MobilePhoneModel\" BYTEA,
    \"Params\" BYTEA,
    \"IPNetworkID\" INTEGER,
    \"TraficSourceID\" INTEGER,
    \"SearchEngineID\" INTEGER,
    \"SearchPhrase\" BYTEA,
    \"AdvEngineID\" INTEGER,
    \"IsArtifical\" INTEGER,
    \"WindowClientWidth\" INTEGER,
    \"WindowClientHeight\" INTEGER,
    \"ClientTimeZone\" INTEGER,
    \"ClientEventTime\" BIGINT,
    \"SilverlightVersion1\" INTEGER,
    \"SilverlightVersion2\" INTEGER,
    \"SilverlightVersion3\" INTEGER,
    \"SilverlightVersion4\" INTEGER,
    \"PageCharset\" BYTEA,
    \"CodeVersion\" INTEGER,
    \"IsLink\" INTEGER,
    \"IsDownload\" INTEGER,
    \"IsNotBounce\" INTEGER,
    \"FUniqID\" BIGINT,
    \"OriginalURL\" BYTEA,
    \"HID\" INTEGER,
    \"IsOldCounter\" INTEGER,
    \"IsEvent\" INTEGER,
    \"IsParameter\" INTEGER,
    \"DontCountHits\" INTEGER,
    \"WithHash\" INTEGER,
    \"HitColor\" BYTEA,
    \"LocalEventTime\" BIGINT,
    \"Age\" INTEGER,
    \"Sex\" INTEGER,
    \"Income\" INTEGER,
    \"Interests\" INTEGER,
    \"Robotness\" INTEGER,
    \"RemoteIP\" INTEGER,
    \"WindowName\" INTEGER,
    \"OpenerName\" INTEGER,
    \"HistoryLength\" INTEGER,
    \"BrowserLanguage\" BYTEA,
    \"BrowserCountry\" BYTEA,
    \"SocialNetwork\" BYTEA,
    \"SocialAction\" BYTEA,
    \"HTTPError\" INTEGER,
    \"SendTiming\" INTEGER,
    \"DNSTiming\" INTEGER,
    \"ConnectTiming\" INTEGER,
    \"ResponseStartTiming\" INTEGER,
    \"ResponseEndTiming\" INTEGER,
    \"FetchTiming\" INTEGER,
    \"SocialSourceNetworkID\" INTEGER,
    \"SocialSourcePage\" BYTEA,
    \"ParamPrice\" BIGINT,
    \"ParamOrderID\" BYTEA,
    \"ParamCurrency\" BYTEA,
    \"ParamCurrencyID\" INTEGER,
    \"OpenstatServiceName\" BYTEA,
    \"OpenstatCampaignID\" BYTEA,
    \"OpenstatAdID\" BYTEA,
    \"OpenstatSourceID\" BYTEA,
    \"UTMSource\" BYTEA,
    \"UTMMedium\" BYTEA,
    \"UTMCampaign\" BYTEA,
    \"UTMContent\" BYTEA,
    \"UTMTerm\" BYTEA,
    \"FromTag\" BYTEA,
    \"HasGCLID\" INTEGER,
    \"RefererHash\" BIGINT,
    \"URLHash\" BIGINT,
    \"CLID\" INTEGER
)
URL = 's3://firebolt-publishing-public/clickbench/'
OBJECT_PATTERN = '*.parquet'
TYPE = (PARQUET)")

    EXT_ERROR=$(echo "$EXT_RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$EXT_ERROR" ] && [ "$EXT_ERROR" != "null" ]; then
        echo "ERROR creating external table: $EXT_ERROR"
        exit 1
    fi
    echo "External table created successfully."
    
    # Step 2: Create the hits table with proper schema (lowercase column names)
    echo "Creating table ${SOURCE_TABLE} with proper schema..."
    CREATE_RESULT=$(run_sql "CREATE TABLE ${SOURCE_TABLE} (
    watchid BIGINT NOT NULL,
    javaenable INTEGER NOT NULL,
    title TEXT NOT NULL,
    goodevent INTEGER NOT NULL,
    eventtime TIMESTAMP NOT NULL,
    eventdate DATE NOT NULL,
    counterid INTEGER NOT NULL,
    clientip INTEGER NOT NULL,
    regionid INTEGER NOT NULL,
    userid BIGINT NOT NULL,
    counterclass INTEGER NOT NULL,
    os INTEGER NOT NULL,
    useragent INTEGER NOT NULL,
    url TEXT NOT NULL,
    referer TEXT NOT NULL,
    isrefresh INTEGER NOT NULL,
    referercategoryid INTEGER NOT NULL,
    refererregionid INTEGER NOT NULL,
    urlcategoryid INTEGER NOT NULL,
    urlregionid INTEGER NOT NULL,
    resolutionwidth INTEGER NOT NULL,
    resolutionheight INTEGER NOT NULL,
    resolutiondepth INTEGER NOT NULL,
    flashmajor INTEGER NOT NULL,
    flashminor INTEGER NOT NULL,
    flashminor2 TEXT NOT NULL,
    netmajor INTEGER NOT NULL,
    netminor INTEGER NOT NULL,
    useragentmajor INTEGER NOT NULL,
    useragentminor TEXT NOT NULL,
    cookieenable INTEGER NOT NULL,
    javascriptenable INTEGER NOT NULL,
    ismobile INTEGER NOT NULL,
    mobilephone INTEGER NOT NULL,
    mobilephonemodel TEXT NOT NULL,
    params TEXT NOT NULL,
    ipnetworkid INTEGER NOT NULL,
    traficsourceid INTEGER NOT NULL,
    searchengineid INTEGER NOT NULL,
    searchphrase TEXT NOT NULL,
    advengineid INTEGER NOT NULL,
    isartifical INTEGER NOT NULL,
    windowclientwidth INTEGER NOT NULL,
    windowclientheight INTEGER NOT NULL,
    clienttimezone INTEGER NOT NULL,
    clienteventtime TIMESTAMP NOT NULL,
    silverlightversion1 INTEGER NOT NULL,
    silverlightversion2 INTEGER NOT NULL,
    silverlightversion3 INTEGER NOT NULL,
    silverlightversion4 INTEGER NOT NULL,
    pagecharset TEXT NOT NULL,
    codeversion INTEGER NOT NULL,
    islink INTEGER NOT NULL,
    isdownload INTEGER NOT NULL,
    isnotbounce INTEGER NOT NULL,
    funiqid BIGINT NOT NULL,
    originalurl TEXT NOT NULL,
    hid INTEGER NOT NULL,
    isoldcounter INTEGER NOT NULL,
    isevent INTEGER NOT NULL,
    isparameter INTEGER NOT NULL,
    dontcounthits INTEGER NOT NULL,
    withhash INTEGER NOT NULL,
    hitcolor TEXT NOT NULL,
    localeventtime TIMESTAMP NOT NULL,
    age INTEGER NOT NULL,
    sex INTEGER NOT NULL,
    income INTEGER NOT NULL,
    interests INTEGER NOT NULL,
    robotness INTEGER NOT NULL,
    remoteip INTEGER NOT NULL,
    windowname INTEGER NOT NULL,
    openername INTEGER NOT NULL,
    historylength INTEGER NOT NULL,
    browserlanguage TEXT NOT NULL,
    browsercountry TEXT NOT NULL,
    socialnetwork TEXT NOT NULL,
    socialaction TEXT NOT NULL,
    httperror INTEGER NOT NULL,
    sendtiming INTEGER NOT NULL,
    dnstiming INTEGER NOT NULL,
    connecttiming INTEGER NOT NULL,
    responsestarttiming INTEGER NOT NULL,
    responseendtiming INTEGER NOT NULL,
    fetchtiming INTEGER NOT NULL,
    socialsourcenetworkid INTEGER NOT NULL,
    socialsourcepage TEXT NOT NULL,
    paramprice BIGINT NOT NULL,
    paramorderid TEXT NOT NULL,
    paramcurrency TEXT NOT NULL,
    paramcurrencyid INTEGER NOT NULL,
    openstatservicename TEXT NOT NULL,
    openstatcampaignid TEXT NOT NULL,
    openstatadid TEXT NOT NULL,
    openstatsourceid TEXT NOT NULL,
    utmsource TEXT NOT NULL,
    utmmedium TEXT NOT NULL,
    utmcampaign TEXT NOT NULL,
    utmcontent TEXT NOT NULL,
    utmterm TEXT NOT NULL,
    fromtag TEXT NOT NULL,
    hasgclid INTEGER NOT NULL,
    refererhash BIGINT NOT NULL,
    urlhash BIGINT NOT NULL,
    clid INTEGER NOT NULL
)
PRIMARY INDEX counterid, eventdate, userid, eventtime, watchid")

    CREATE_ERROR=$(echo "$CREATE_RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$CREATE_ERROR" ] && [ "$CREATE_ERROR" != "null" ]; then
        echo "ERROR creating table: $CREATE_ERROR"
        exit 1
    fi
    echo "Table created successfully."
    
    # Step 3: INSERT/SELECT with type conversions from external table
    echo ""
    echo "Loading data from external table with type conversions..."
    INSERT_RESULT=$(run_sql "INSERT INTO ${SOURCE_TABLE}
SELECT
    \"WatchID\",
    \"JavaEnable\",
    CONVERT_FROM(\"Title\", 'UTF8'),
    \"GoodEvent\",
    TO_TIMESTAMP(\"EventTime\"),
    TO_DATE('1970-01-01') + \"EventDate\",
    \"CounterID\",
    \"ClientIP\",
    \"RegionID\",
    \"UserID\",
    \"CounterClass\",
    \"OS\",
    \"UserAgent\",
    CONVERT_FROM(\"URL\", 'UTF8'),
    CONVERT_FROM(\"Referer\", 'UTF8'),
    \"IsRefresh\",
    \"RefererCategoryID\",
    \"RefererRegionID\",
    \"URLCategoryID\",
    \"URLRegionID\",
    \"ResolutionWidth\",
    \"ResolutionHeight\",
    \"ResolutionDepth\",
    \"FlashMajor\",
    \"FlashMinor\",
    CONVERT_FROM(\"FlashMinor2\", 'UTF8'),
    \"NetMajor\",
    \"NetMinor\",
    \"UserAgentMajor\",
    CONVERT_FROM(\"UserAgentMinor\", 'UTF8'),
    \"CookieEnable\",
    \"JavascriptEnable\",
    \"IsMobile\",
    \"MobilePhone\",
    CONVERT_FROM(\"MobilePhoneModel\", 'UTF8'),
    CONVERT_FROM(\"Params\", 'UTF8'),
    \"IPNetworkID\",
    \"TraficSourceID\",
    \"SearchEngineID\",
    CONVERT_FROM(\"SearchPhrase\", 'UTF8'),
    \"AdvEngineID\",
    \"IsArtifical\",
    \"WindowClientWidth\",
    \"WindowClientHeight\",
    \"ClientTimeZone\",
    TO_TIMESTAMP(\"ClientEventTime\"),
    \"SilverlightVersion1\",
    \"SilverlightVersion2\",
    \"SilverlightVersion3\",
    \"SilverlightVersion4\",
    CONVERT_FROM(\"PageCharset\", 'UTF8'),
    \"CodeVersion\",
    \"IsLink\",
    \"IsDownload\",
    \"IsNotBounce\",
    \"FUniqID\",
    CONVERT_FROM(\"OriginalURL\", 'UTF8'),
    \"HID\",
    \"IsOldCounter\",
    \"IsEvent\",
    \"IsParameter\",
    \"DontCountHits\",
    \"WithHash\",
    CONVERT_FROM(\"HitColor\", 'UTF8'),
    TO_TIMESTAMP(\"LocalEventTime\"),
    \"Age\",
    \"Sex\",
    \"Income\",
    \"Interests\",
    \"Robotness\",
    \"RemoteIP\",
    \"WindowName\",
    \"OpenerName\",
    \"HistoryLength\",
    CONVERT_FROM(\"BrowserLanguage\", 'UTF8'),
    CONVERT_FROM(\"BrowserCountry\", 'UTF8'),
    CONVERT_FROM(\"SocialNetwork\", 'UTF8'),
    CONVERT_FROM(\"SocialAction\", 'UTF8'),
    \"HTTPError\",
    \"SendTiming\",
    \"DNSTiming\",
    \"ConnectTiming\",
    \"ResponseStartTiming\",
    \"ResponseEndTiming\",
    \"FetchTiming\",
    \"SocialSourceNetworkID\",
    CONVERT_FROM(\"SocialSourcePage\", 'UTF8'),
    \"ParamPrice\",
    CONVERT_FROM(\"ParamOrderID\", 'UTF8'),
    CONVERT_FROM(\"ParamCurrency\", 'UTF8'),
    \"ParamCurrencyID\",
    CONVERT_FROM(\"OpenstatServiceName\", 'UTF8'),
    CONVERT_FROM(\"OpenstatCampaignID\", 'UTF8'),
    CONVERT_FROM(\"OpenstatAdID\", 'UTF8'),
    CONVERT_FROM(\"OpenstatSourceID\", 'UTF8'),
    CONVERT_FROM(\"UTMSource\", 'UTF8'),
    CONVERT_FROM(\"UTMMedium\", 'UTF8'),
    CONVERT_FROM(\"UTMCampaign\", 'UTF8'),
    CONVERT_FROM(\"UTMContent\", 'UTF8'),
    CONVERT_FROM(\"UTMTerm\", 'UTF8'),
    CONVERT_FROM(\"FromTag\", 'UTF8'),
    \"HasGCLID\",
    \"RefererHash\",
    \"URLHash\",
    \"CLID\"
FROM hits_external")

    INSERT_ERROR=$(echo "$INSERT_RESULT" | jq -r '.errors[0].description // empty' 2>/dev/null)
    if [ -n "$INSERT_ERROR" ] && [ "$INSERT_ERROR" != "null" ]; then
        echo "ERROR loading data: $INSERT_ERROR"
        exit 1
    fi
    
    LOAD_BASE_END=$(date +%s)
    LOAD_BASE_TIME=$((LOAD_BASE_END - LOAD_BASE_START))
    echo "Data loaded successfully in ${LOAD_BASE_TIME} seconds."
    
    # Step 4: Drop external table
    echo "Dropping external table..."
    run_sql "DROP TABLE IF EXISTS hits_external" > /dev/null
    echo "External table dropped."
fi

# Get source table row count
echo ""
echo "Checking source table public.${SOURCE_TABLE}..."
SOURCE_COUNT=$(get_row_count "public.${SOURCE_TABLE}")
if [ "$SOURCE_COUNT" == "0" ] || [ "$SOURCE_COUNT" == "null" ]; then
    echo "ERROR: Source table public.${SOURCE_TABLE} is empty after load"
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
AS SELECT ${SOURCE_TABLE}.* FROM ${SOURCE_TABLE} AS ${SOURCE_TABLE}, generate_series(1, ${SCALE_FACTOR})")

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
