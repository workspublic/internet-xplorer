drop table if exists bdc_hexblocks;

create table bdc_hexblocks as
with hexblock_geoms as (
	select
		c.geoid20 as block_id,
		h.id as hexagon_id,
		st_intersection(c.geom, h.geom) as geom
	from census_blocks c
	join hexagons h on
		st_intersects(c.geom, h.geom)
), location_services_real_speeds as (
	select *
	from bdc_location_services
	where
		-- so far haven't observed null speeds in the source data, but just in case
		-- only downside to this is we lose bsl counts. maybe just set 0 speeds = 
		-- null for consistency?
		max_advertised_download_speed is not null and
		max_advertised_download_speed > 0 and
		max_advertised_upload_speed is not null and
		max_advertised_upload_speed > 0
), hexblock_speeds_all_tech as (
	select
		block_geoid as block_id,
		h3_res8_id as hexagon_id,
		max(max_advertised_download_speed) as down_max,
		max(max_advertised_upload_speed) as up_max,
		-- this isn't really speed-related but putting it here for now since we're already doing the needed aggregation
		count(distinct location_id) as num_bsls
	from location_services_real_speeds
	group by
		block_geoid,
		h3_res8_id
), hexblock_speeds_terrestrial as (
	select
		s.block_geoid as block_id,
		s.h3_res8_id as hexagon_id,
		max(s.max_advertised_download_speed) as down_max,
		max(s.max_advertised_upload_speed) as up_max
	from (
		select *
		from location_services_real_speeds
		where
			technology <> '0' and
			--TODO use range type for this and wired?
			(
				technology::integer < 60 or
				technology::integer >= 70
			)
	) as s
	group by
		block_geoid,
		h3_res8_id
), hexblock_speeds_wired as (
	select
		s.block_geoid as block_id,
		s.h3_res8_id as hexagon_id,
		max(s.max_advertised_download_speed) as down_max,
		max(s.max_advertised_upload_speed) as up_max
	from (
		select *
		from location_services_real_speeds
		where
			technology <> '0' and
			technology::integer < 60
	) as s
	group by
		block_geoid,
		h3_res8_id
)
select
	g.block_id,
	g.hexagon_id,
	sa.down_max as all_down_max,
	sa.up_max as all_up_max,
	st.down_max as terrestrial_down_max,
	st.up_max as terrestrial_up_max,
	sw.down_max as wired_down_max,
	sw.up_max as wired_up_max,
	sa.num_bsls,
	g.geom
from hexblock_geoms g
join hexblock_speeds_all_tech sa on
	g.hexagon_id = sa.hexagon_id and
	g.block_id = sa.block_id
left join hexblock_speeds_terrestrial st on
	g.hexagon_id = st.hexagon_id and
	g.block_id = st.block_id
left join hexblock_speeds_wired sw on
	g.hexagon_id = sw.hexagon_id and
	g.block_id = sw.block_id
;

create index bdc_hexblocks_geom_idx on bdc_hexblocks using gist (geom);
