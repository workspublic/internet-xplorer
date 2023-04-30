create extension if not exists postgis;

-- addresses
-- create table if not exists addresses (
--   id serial primary key,
--   oa_hash text,
--   num text,
--   street text,
--   unit text,
--   county text,
--   zip text,
--   geom geometry(Point, 4326)
-- );
-- create index if not exists addresses_oa_hash_idx on addresses (oa_hash);
-- create index if not exists addresses_geom_idx on addresses using gist (geom);


-- bdc location services

-- mlab tests
