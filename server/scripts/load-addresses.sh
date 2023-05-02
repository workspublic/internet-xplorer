#!/usr/bin/env bash

# set env vars
source ./load-dotenv.sh
load_dotenv

echo "Starting..."
echo "Database: "$DB_DATABASE"@"$DB_HOST

echo "Dropping existing addresses..."
# TODO check if the table exists before running this, or suppress error
psql -d $DB_DATABASE -c "truncate addresses"

echo "Loading addresses..."
for file in $1/*-addresses-*.geojson; do
  ogr2ogr \
  -append \
  -lco FID=id \
  -lco GEOMETRY_NAME=geom \
  -nln addresses \
  PG:dbname=$DB_DATABASE \
  -progress \
  "$file"
done

# TODO create indexes

echo "Finished."
