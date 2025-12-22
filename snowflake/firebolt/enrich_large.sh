#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Firebolt Cost Enrichment Script
# -----------------------------
# Calculates compute and storage costs for Firebolt benchmark results
# based on FBU (Firebolt Unit) pricing model.
#
# Pricing source: https://docs.firebolt.io/overview/billing
# -----------------------------

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <results_dir> <output_dir>"
  echo "  <results_dir> : directory with *.json result files"
  echo "  <output_dir>  : where enriched JSON files will be written"
  exit 1
fi

RESULTS_DIR="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"
shopt -s nullglob
files=( "$RESULTS_DIR"/*.json )
echo "Found ${#files[@]} file(s) in $RESULTS_DIR"

# FBU sizing by node type and compute family
# Storage-optimized: S=8, M=16, L=32, XL=64
# Compute-optimized: S=4, M=8, L=16, XL=32
FBU_MAP='{
  "STORAGE_OPTIMIZED": {"S": 8, "M": 16, "L": 32, "XL": 64},
  "COMPUTE_OPTIMIZED": {"S": 4, "M": 8, "L": 16, "XL": 32}
}'

# Pricing tiers (US region - us-east-1)
# Storage-optimized pricing per FBU/hour
# Compute-optimized is ~2x cheaper (same FBU rate but half the FBUs)
# Storage: $27.07/TiB/month = $27.07 / (1024^4) per byte/month
TIERS_JSON='[
  {
    "name": "Standard",
    "fbu_rate_per_hour": 0.23,
    "storage_per_tib_month": 27.07
  },
  {
    "name": "Enterprise",
    "fbu_rate_per_hour": 0.30,
    "storage_per_tib_month": 27.07
  }
]'

for infile in "${files[@]}"; do
  base="$(basename "$infile")"
  out="$OUTPUT_DIR/$base"
  echo " -> $base"

  jq --arg provider aws --arg region us-east-1 \
     --argjson tiers "$TIERS_JSON" \
     --argjson fbu_map "$FBU_MAP" '
    def tosec:
      if type=="number" then . else (try tonumber catch 0) // 0 end;

    # Constants
    (1024 * 1024 * 1024 * 1024) as $tib_bytes |
    
    # Extract engine info
    (.engine.type // "L") as $node_type |
    (.engine.family // "STORAGE_OPTIMIZED") as $family |
    (.engine.nodes // .cluster_size // 1) as $nodes |
    
    # Get FBU per node based on type and family
    ($fbu_map[$family][$node_type] // 32) as $fbu_per_node |
    ($fbu_per_node * $nodes) as $total_fbu |
    
    # Data size (if available)
    (if has("data_size") and (.data_size != null) then (.data_size|tonumber) else 0 end) as $bytes |
    
    # Results array
    (.result // []) as $res |
    
    # Add metadata and costs
    .provider = $provider |
    .region = $region |
    .fbu_per_node = $fbu_per_node |
    .total_fbu = $total_fbu |
    . + {
      costs: (
        $tiers | map(
          . as $tier |
          # FBU cost per second = (fbu_rate_per_hour / 3600)
          ($tier.fbu_rate_per_hour / 3600.0) as $fbu_per_sec |
          # Storage cost per byte per month
          ($tier.storage_per_tib_month / $tib_bytes) as $storage_per_byte |
          # Compute costs for each query run
          # Cost = time_seconds × fbu_per_sec × total_fbu
          (
            [ $res[] |
              [ .[] | (tosec * $fbu_per_sec * $total_fbu) ]
            ]
          ) as $compute_costs |
          # Storage cost (monthly)
          ($bytes * $storage_per_byte) as $storage_cost_value |
          {
            tier: $tier.name,
            provider: $provider,
            region: $region,
            fbu_per_node: $fbu_per_node,
            total_fbu: $total_fbu,
            compute_costs: $compute_costs,
            storage_cost: $storage_cost_value
          }
        )
      )
    }
  ' "$infile" > "$out"

  echo "    saved → $out"
done

echo "Done. Outputs in: $OUTPUT_DIR"
