#!/usr/bin/env bash

set -euo pipefail

source ./util/create_temp_dir.sh
source ./util/load_dotenv.sh
source ./util/make_db_uri.sh

echo "Starting..."

load_dotenv

geojson_path=$SCRIPTS_TEMP_DIR/summary_addresses.geojsonl

db_uri=$(make_db_uri)

create_temp_dir

echo "Exporting summary addresses as GeoJSON..."
ogr2ogr \
  -f GeoJSONSeq \
  $geojson_path \
  $db_uri \
  -sql "
    select
      hash,
      -- classify bdc wired service
      case
        when
          bdc_wired_down_max >= 100 and
          bdc_wired_up_max >= 20
        then 3
        when
          bdc_wired_down_max >= 25 and
          bdc_wired_down_max >= 3 and
          (
            bdc_wired_down_max < 100 or
            bdc_wired_up_max < 20
          )
        then 2
        when
          bdc_wired_down_max < 25 or
          bdc_wired_up_max < 3
        then 1
        when
        	bdc_wired_down_max is null or
        	bdc_wired_up_max is null
        then -1
      end as bdc_wired_class,
      -- flag addresses missing from bdc (based on census block and hex)
      case
        when
        	bdc_all_down_max is not null and
        	bdc_all_up_max is not null
        then 1
        else 0
      end as bdc_service_reported,
      -- compare mlab to bdc
      round((mlab_down_pctl_95 / bdc_wired_down_max)::numeric, 2) as mlab_pctl_95_vs_bdc_down,
      round((mlab_up_pctl_95 / bdc_wired_up_max)::numeric, 2) as mlab_pctl_95_vs_bdc_up,
      geom
    from summary_addresses
  " \
  -progress

echo "Tiling..."

out_tiles_path="$SCRIPTS_TEMP_DIR/summary_addresses_$(date '+%Y%m%d_%H%M%S').pmtiles"
echo "Output tile path:" $out_tiles_path

tippecanoe \
  --read-parallel \
  --layer=summary-addresses \
  --maximum-zoom=16 \
  --no-feature-limit \
  --maximum-tile-bytes=3000000 \
  --drop-rate=1 \
  --drop-densest-as-needed \
  -o $out_tiles_path \
  $geojson_path
