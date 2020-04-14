UPDATE  raw_data.trash set user_first_name = 'jérôme ' WHERE user_first_name = 'jérome';
UPDATE  raw_data.traces set user_first_name = 'jérôme' WHERE user_first_name = 'jérome';

--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

----------------------------------------------------------------------------------------------------------------------------------

drop table if exists country cascade;
create table country (id SERIAL primary key,
					 the_geom geometry not null,
					 code text unique, name text unique,
					 last_run timestamp
					);
----------------------------------------------------------------------------------------------------------------------------------

				drop table if exists state cascade;
create table state (id SERIAL primary key,
					the_geom geometry not null,
				    code text unique,
				   	name text unique,
				    id_source text,
				    id_ref_country_fk integer references country(id),
				    last_run timestamp);
----------------------------------------------------------------------------------------------------------------------------------
	  				   
drop table if exists department cascade;
create table department (id SERIAL primary key,
						 the_geom geometry not null,
						 code text unique, name text unique,
						 id_source text,
						 id_ref_state_fk integer references state(id),
						 last_run timestamp);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists municipality cascade;
create table municipality (id SERIAL primary key, 
						   the_geom geometry not null,
						   code text unique, name text,
						   id_source text,
						   id_ref_department_fk integer references department(id),
						   last_run timestamp);
----------------------------------------------------------------------------------------------------------------------------------
						  
drop table if exists river CASCADE; 
create table river (id SERIAL primary key,
					the_geom geometry not null,
					code text, name text,
					code text, nature text,
					origine text,
					code_hydro text,
					id_ref_country_fk integer references country(id),
					last_run timestamp);
----------------------------------------------------------------------------------------------------------------------------------
			
drop table if exists limits_land_sea;
create table limits_land_sea (id SERIAL primary key,
							  the_geom geometry not null,
							  code text, name text,
							  id_source text,
							  nature text,
							  origine text,
							  code_hydro text,
							  id_ref_country_fk integer references country(id),
							  last_run timestamp);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists user_campaign cascade; 
create table user_campaign (
	id uuid PRIMARY key default uuid_generate_v4(),
	firstname text NULL,
	lastname text NULL,
	email text NOT NULL,
	emailconfirmed bool NOT NULL,
	passwordhash text NULL,
	yearofbirth date NULL,
	experience text NULL,
	isdeleted bool NOT null, 
	insert_timestamp timestamp,
	UNIQUE(firstname, lastname) -- must use email?
); 
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists campaign cascade;
create table if not exists campaign (
	id uuid PRIMARY key DEFAULT uuid_generate_v4(),
	locomotion text NOT NULL,
	method text NOT NULL,
	remark text NULL,
	id_ref_user_fk uuid references user_campaign(id),
	campaign_date date,
	insert_timestamp timestamp
);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists trajectory_point cascade; 
create table if not exists trajectory_point (

	id uuid not null primary key default uuid_generate_v4(), 
	the_geom geometry,
	id_ref_campaign_fk uuid not null references campaign(id), 
	elevation float, 
	insert_timestamp timestamp
	
); 
----------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS image cascade; 
CREATE TABLE  image(
	id uuid  PRIMARY KEY,
	filename text NOT NULL,
	blobname text NOT NULL,
	containerurl text NOT NULL,
	createdby text NOT NULL,
	createdon date NOT NULL,
	isdeleted bit NOT null, 
	version integer not null, 
	id_ref_campaign_fk uuid references campaign(id), 
    id_ref_trajectory_points_fk uuid references trajectory(id), 
	insert_timestamp timestamp
);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists model cascade; 
create table model (

	id uuid primary key default uuid_generate_v4(), 
	version integer, 
	insert_timestamp timestamp
);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists trash_type CASCADE;
CREATE TABLE trash_type (
   id  SERIAL PRIMARY KEY,
   type TEXT UNIQUE
);
----------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS trash CASCADE;
CREATE TABLE trash (
	id uuid not null primary key default uuid_generate_v4(),
	id_ref_campaign_fk uuid NOT null references campaign(id),
	the_geom geometry,
	elevation float,
	id_ref_trash_type_fk int NOT null references trash_type(id) ,
	precision double precision NULL,
	id_ref_model_fk uuid references model(id) ,
	brand_type text NULL,
	id_ref_image_fk uuid references image(id)
);
----------------------------------------------------------------------------------------------------------------------------------

drop table if exists trash_river; 
create table trash_river (
						  id 						SERIAL primary key,
						  id_ref_trash_fk	 		uuid NOT null references trash(id) ,
						  id_ref_river_fk 			int NOT null references river(id) ,
						  trash_the_geom  			geometry not null,
						  river_the_geom  			geometry not null,
						  closest_point_the_geom 	geometry not null,
						  distance_river_trash   	float not null,
						  projection_trash_river_the_geom geometry not null
						  )
						  ;
----------------------------------------------------------------------------------------------------------------------------------
						 
--INDEXES
----------------------------------------------------------------------------------------------------------------------------------
drop index if exists limits_land_sea_the_geom; create index limits_land_sea_the_geom on limits_land_sea using gist(the_geom);
drop index if exists river_the_geom; create index river_the_geom on river using gist(the_geom);
drop index if exists municipality_code; create index municipality_code on municipality (code);
drop index if exists municipality_the_geom; create index municipality_the_geom on municipality using gist(the_geom);
drop index if exists state_the_geom; create index state_the_geom on state using gist(the_geom); drop index if exists state_code; create index state_code on state (code);
drop index if exists department_the_geom; create index department_the_geom on department using gist(the_geom); drop index if exists department_code; create index department_code on department (code);
drop index if exists country_the_geom; create index country_the_geom on country using gist(the_geom);
drop index if exists country_code; create index country_code on country (code); 
drop index if exists user_campaign_firstname; create index user_campaign_firstname on user_campaign (firstname);
drop index if exists user_campaign_lastname; create index user_campaign_lastname on user_campaign  (lastname);
drop index if exists trash_the_geom; create index trash_the_geom on trash using gist(the_geom)
drop index if exists trajectory_point_the_geom; create index trajectory_point_the_geom on trajectory_point using gist(the_geom)

----------------------------------------------------------------------------------------------------------------------------------


