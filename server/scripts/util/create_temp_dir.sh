#!/usr/bin/env bash

set -euo pipefail

# helper to create working directory for scripts that can't do this on their own
# (e.g. tile_summary_addresses; ogr2ogr doesn't seem to be able to create the 
# destination dir)
create_temp_dir () {
  mkdir -p "$SCRIPTS_TEMP_DIR"
}
