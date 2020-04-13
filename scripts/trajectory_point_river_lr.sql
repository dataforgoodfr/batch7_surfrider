-- public.trajectory_point_river_lr definition

-- Drop table

--DROP TABLE public.trajectory_point_river_lr;

CREATE TABLE public.trajectory_point_river_lr (
	id serial NOT NULL,
	id_ref_trajectory_point_fk uuid NOT NULL,
	id_ref_river_fk int4 NOT NULL,
	trajectory_point_the_geom geometry NOT NULL,
	river_the_geom geometry NOT NULL,
	closest_point_the_geom geometry NOT NULL,
	distance_river_trajectory_point float8 NOT NULL,
	projection_trajectory_point_river_the_geom geometry NOT NULL,
	importance int4 NULL,
	createdon timestamp NULL,
	CONSTRAINT trajectory_point_river_lr_pkey PRIMARY KEY (id)
);

-- public.trajectory_point_river foreign keys

ALTER TABLE public.trajectory_point_river_lr ADD CONSTRAINT trajectory_point_river_id_ref_river_lr_fk_fkey FOREIGN KEY (id_ref_river_fk) REFERENCES river(id);
ALTER TABLE public.trajectory_point_river_lr ADD CONSTRAINT trajectory_point_river_id_ref_trajectory_point_lr_fk_fkey FOREIGN KEY (id_ref_trajectory_point_fk) REFERENCES trajectory_point(id);


with ranking as (
select tp.id as id_ref_trajectory_point_fk
		, river.id as id_ref_river_fk
		, tp.the_geom as trajectory_point_the_geom
		, ST_GeomFromText(ST_AsEWKT(ST_Force2D(river.the_geom))) as river_the_geom
		, ST_ClosestPoint(river.the_geom, tp.the_geom) as closest_point_the_geom
		, ST_Distance(tp.the_geom, river.the_geom) as distance_river_trajectory_point
		, ST_MakeLine(tp.the_geom,ST_ClosestPoint(river.the_geom, tp.the_geom))as projection_trajectory_point_river_the_geom
		, river.importance
		, current_date as createdon
		
		, rank() over (partition by tp.id order by river.importance, ST_Distance(tp.the_geom, river.the_geom), river.id ) as r
from (select * from trajectory_point /*where id_ref_campaign_fk = '0fa521d4-598d-4416-b83a-769ca247ffc4'*/) tp
left join river 
	on ST_DWithin(tp.the_geom, river.the_geom, 100)
where river.the_geom is not null
)
insert into public.trajectory_point_river_lr (id_ref_trajectory_point_fk,
												id_ref_river_fk,
												trajectory_point_the_geom,
												river_the_geom,
												closest_point_the_geom,
												distance_river_trajectory_point,
												projection_trajectory_point_river_the_geom,
												importance,
												createdon)
select id_ref_trajectory_point_fk,
	id_ref_river_fk,
	trajectory_point_the_geom,
	river_the_geom geometry,
	closest_point_the_geom geometry,
	distance_river_trajectory_point,
	projection_trajectory_point_river_the_geom,
	importance,
	createdon
from ranking 
where r=1
select * from public.trajectory_point_river_lr
truncate table public.trajectory_point_river_lr
	--limit 4