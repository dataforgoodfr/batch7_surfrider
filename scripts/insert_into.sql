----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO country (the_geom, code, name, last_run)
SELECT 
	st_union(st_setsrid(geometry, 2154)),
	'FR', 
	'France', 
	current_timestamp
FROM
	raw_data.region;

drop index if exists country_the_geom; create index country_the_geom on country using gist(the_geom);
drop index if exists country_code; create index country_code on country (code);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO state (the_geom, code, name, id_source, id_ref_country_fk, last_run)
SELECT 
	st_setsrid(geometry, 2154), 
	insee_reg,
	nom_reg,
	r.id,
	c.id,
	current_timestamp
FROM
	raw_data.region r
INNER JOIN country c on c.code = 'FR'
;

drop index if exists state_the_geom; create index state_the_geom on state using gist(the_geom); drop index if exists state_code; create index state_code on state (code);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO department (the_geom, code, name, id_source, id_ref_state_fk, last_run)
SELECT
	st_setsrid(geometry, 2154), 
	insee_dep,
	nom_dep,
	d.id,
	r.id,
	current_timestamp
FROM 
	raw_data.departement d 
INNER JOIN state r ON r.code = d.insee_reg
;

drop index if exists department_the_geom; create index department_the_geom on department using gist(the_geom); drop index if exists department_code; create index department_code on department (code);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO municipality (the_geom, code, name, id_source, id_ref_department_fk, last_run)
SELECT
	st_setsrid(geometry, 2154), 
	insee_com,
	nom_com,
	c.id,
	r.id,
	current_timestamp
FROM 
	raw_data.commune c
INNER JOIN department r ON r.code = c.insee_dep
;

drop index if exists municipality_code; create index municipality_code on municipality (code);
drop index if exists municipality_the_geom; create index municipality_the_geom on municipality using gist(the_geom);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO river (the_geom, id_source, nature, origine, code_hydro, id_ref_country_fk, last_run)
SELECT 
	st_setsrid(geometry, 2154),
	th.id,
	th.nature, 
	th.origine,
	th.code_hydro, 
	c.id, 
	current_timestamp
FROM 
	raw_data.troncon_hydrographique th 
INNER JOIN country c on c.code = th.code_pays
; 

drop index if exists river_the_geom; create index river_the_geom on river using gist(the_geom);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO limits_land_sea (the_geom, id_ref_country_fk, last_run)
SELECT
	st_setsrid(geometry, 2154),
	c.id, 
	current_timestamp
FROM 
	raw_data.limite_terre_mer ltm
INNER JOIN country c on c.code = ltm.code_pays
;

drop index if exists limits_land_sea_the_geom; create index limits_land_sea_the_geom on limits_land_sea using gist(the_geom);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO user_campaign (
	firstname,
	lastname,
	email,
	emailconfirmed,
	passwordhash,
	yearofbirth,
	experience,
	isdeleted, 
	insert_timestamp)
SELECT 
DISTINCT ON (user_first_name, user_last_name) 
	user_first_name,
	user_last_name, 
	'fake@gmail.com', 
	true,
	'kdjkdsjs',
	'01/02/2000'::date, 
	'advanced', 
	TRUE, 
	current_timestamp
FROM
raw_data.trash 

WHERE user_first_name is not null 
; 

drop index if exists user_campaign_firstname; create index user_campaign_firstname on user_campaign (firstname);
drop index if exists user_campaign_lastname; create index user_campaign_lastname on user_campaign  (lastname);
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO campaign (locomotion, method, remark, id_ref_user_fk, campaign_date, insert_timestamp)
SELECT
DISTINCT
	locomotion, 
	method,
	'river: '||river || ' riverside: ' || riverside, 
	uc.id, 
	t.time::date, 
	current_timestamp
FROM
	raw_data.traces t
	
INNER JOIN user_campaign  uc ON uc.firstname = t.user_first_name and uc.lastname = t.user_last_name
;
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO trajectory_point (the_geom, id_ref_campaign_fk,elevation )
SELECT 
	st_setsrid(st_transform(st_setsrid(st_makepoint(longitude, latitude), 4326), 2154), 2154), 
	c.id, 
	elevation
FROM 
	raw_data.traces t

INNER JOIN user_campaign uc on t.user_last_name = uc.lastname and t.user_first_name = uc.firstname
INNER JOIN campaign c on c.id_ref_user_fk = uc.id and t.method = c.method and c.campaign_date = t.time and c.locomotion = t.locomotion
;

drop index if exists trajectory_point_the_geom; create index trajectory_point_the_geom on trajectory_point using gist(the_geom)
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO trash_type(type)
SELECT
DISTINCT object
FROM raw_data.trash t
;
----------------------------------------------------------------------------------------------------------------------------------

INSERT INTO trash (id_ref_campaign_fk, the_geom, elevation, id_ref_trash_type_fk)

SELECT 

	c.id,
	st_setsrid(st_transform(st_setsrid(st_makepoint(longitude, latitude), 4326), 2154), 2154),
	elevation,
	tt.id
	
FROM 
	raw_data.trash t
	
INNER JOIN trash_type tt on tt.type = t.object
INNER JOIN user_campaign uc on t.user_last_name = uc.lastname and t.user_first_name = uc.firstname
INNER JOIN campaign c on c.id_ref_user_fk = uc.id and t.method = c.method and c.campaign_date = t.time and c.locomotion = t.locomotion
;

drop index if exists trash_the_geom; create index trash_the_geom on trash using gist(the_geom)
----------------------------------------------------------------------------------------------------------------------------------

/*
insert into trash_river (id_ref_trash_fk, id_ref_river_fk, trash_the_geom, river_the_geom, distance_river_trash, projection_trash_river_the_geom, closest_point_the_geom)
WITH subquery_1 AS (

SELECT 
	t.id id_ref_trash_fk, 
	closest_r.id id_ref_river_fk,
	t.the_geom trash_the_geom, 
	closest_r.the_geom river_the_geom,
	st_closestpoint(closest_r.the_geom, t.the_geom) closest_point_the_geom
from 
	trash t

inner join lateral (

	select 
	* 
	from 
	river r 
	order by r.the_geom <-> t.the_geom  
	limit 1
	) closest_r on TRUE
	

) 
SELECT 
	id_ref_trash_fk, 
	id_ref_river_fk,
	trash_the_geom, 
	river_the_geom,
	st_distance(closest_point_the_geom, trash_the_geom) distance_river_trash, 
	st_makeline(trash_the_geom, closest_point_the_geom) projection_trash_river_the_geom, 
	closest_point_the_geom
FROM
	subquery_1;

drop index if exists trash_river_closest_point_the_geom; create index trash_river_closest_point_the_geom on trash_river using gist(closest_point_the_geom);
----------------------------------------------------------------------------------------------------------------------------------
*/

