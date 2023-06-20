#!/usr/bin/env bash

set -euo pipefail

source ./util/load_dotenv.sh
source ./util/make_db_uri.sh

echo "Starting..."

load_dotenv
db_uri=$(make_db_uri)

geojson_path=/tmp/internet-xplorer/summary-addresses-tile-features.geojsonl

# TODO shortening these attribute names might not be netting much of a gain
# https://github.com/felt/tippecanoe/issues/100
echo "Exporting summary addresses as GeoJSON..."
ogr2ogr \
  -f GeoJSONSeq \
  $geojson_path \
  $db_uri \
  -sql "
    select
      hash,
      bdc_all_down_max,
      bdc_all_up_max,
      bdc_terrestrial_down_max,
      bdc_terrestrial_up_max,
      bdc_wired_down_max,
      bdc_wired_up_max,
      geom
    from summary_addresses
  " \
  -progress

echo "Tiling..."

tile_dir_path="/tmp/internet-xplorer/summary-addresses-tiles_$(date '+%Y%m%d_%H%M%S')"
echo "Output directory:" $tile_dir_path

cat $geojson_path | tippecanoe \
  --read-parallel \
  --layer=summary-addresses \
  --maximum-zoom=16 \
  --no-feature-limit \
  --maximum-tile-bytes=3000000 \
  --drop-rate=1 \
  --drop-densest-as-needed \
  -e $tile_dir_path
