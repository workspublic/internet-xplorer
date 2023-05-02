#!/usr/bin/env bash

# set env vars
source ./load-dotenv.sh
load_dotenv

echo "Starting..."

conn_str=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE}

echo "Dropping existing addresses..."
# TODO check if the table exists before running this, or suppress error
psql $conn_str -c "truncate addresses"

# this makes ogr2ogr way, way faster importing data
# https://gdal.org/drivers/vector/pg.html#configuration-options
export PG_USECOPY=YES

# TODO create the table in a preliminary step and just populate that here?
# would suppress the "layer creation options ignored" warnings
echo "Loading addresses..."
for file in $1/*-addresses-*.geojson; do
  ogr2ogr \
  -append \
  -lco GEOMETRY_NAME=geom \
  -nln addresses \
  -progress \
  $conn_str \
  $file
done

# TODO create indexes

echo "Finished."
