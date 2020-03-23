/**********************************************************************************************************************
==========
OBJECT NAME:    surfriderdb_postgres_init.sql
DESCRIPTION:    Initialize the surfrider database:
                    - Create schemas
                    - Create tables
                    - Create indices
AUTHOR:         Lucas Rymenants
ORIGIN DATE:    22-MAR-2020

Additional Notes
================
To initialize the postgres database, execute the command below in your terminal:
psql -h surfrider-geodata.postgres.database.azure.com -p 5432 -U SurfriderAdmin@surfrider-geodata -d postgres < "scripts/SQL/surfrider-geodata_init.sql"


REVISION HISTORY
=====================================================================================================================
Version	ChangeDate		Author	Narrative
=======	============	======	=============================================================================
    0	22 Mar 2020		LRY 	Created
------- ------------	------  -----------------------------------------------------------------------------

**********************************************************************************************************************/

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


---------------------
--	Create Schemas --
---------------------
--
-- Name: raw_data; Type: SCHEMA; Schema: -;


CREATE SCHEMA IF NOT EXISTS raw_data;


--
-- Name: traces; Type: SCHEMA; Schema: -;

CREATE SCHEMA IF NOT EXISTS traces;

--
-- Name: bi; Type: SCHEMA; Schema: -;
--

CREATE SCHEMA IF NOT EXISTS bi;

----------------------------
--	Add PostGis Extension --
----------------------------

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET default_tablespace = '';

SET default_with_oids = false;


-----------------------------
--	Create Tables - public --
-----------------------------

--
-- Name: arrondissement_departemental_carto; Type: TABLE; Schema: public; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS public.arrondissement_departemental_carto (
    id text,
    insee_arr text,
    insee_dep text,
    insee_reg text,
    geometry text
);


--
-- Name: interpolated_points; Type: TABLE; Schema: public; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS public.interpolated_points (
    position_values public.geometry,
    altitude_points double precision,
    date_recorded date,
    hr_values integer,
    lat double precision,
    lng double precision,
    started_at date,
    uid text,
    river_the_geom public.geometry,
    closest_point public.geometry,
    interpolate_line public.geometry
);


--
-- Name: trace; Type: TABLE; Schema: public; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS public.trace (
    position_values public.geometry,
    altitude_points double precision,
    date_recorded date,
    hr_values integer,
    lat double precision,
    lng double precision,
    started_at date,
    uid uuid
);

--
-- Name: campaign; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.campaign(
	Id uuid NOT NULL PRIMARY KEY,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	StartLat double precision NULL,
	StartLong double precision NULL,
	EndLat double precision NULL,
	EndLong double precision NULL,
	Locomotion text NOT NULL,
	IsAIDriven bit NOT NULL,
	Remark text NULL,
	RiverId numeric(8, 0) NULL,
	TracedRiverSide bit NOT NULL,
	UserId uuid NULL
);

--
-- Name: campaign_staff; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.campaign_staff(
	CampaignId uuid NOT NULL,
	UserId uuid NOT NULL,
	IsStaff bit NOT NULL,
	HasBeenTrained bit NOT NULL,
    PRIMARY KEY (CampaignId, UserId)
);

--
-- Name: CampaignImageAssoc; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.CampaignImageAssoc(
	CampaignId uuid NOT NULL,
	ImageId uuid NOT NULL,
    PRIMARY KEY (CampaignId, ImageId)
);

--
-- Name: Images; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.Images(
	Id uuid NOT NULL PRIMARY KEY,
	Filename text NOT NULL,
	BlobName text NOT NULL,
	ContainerUrl text NOT NULL,
	CreatedBy text NOT NULL,
	CreatedOn date NOT NULL,
	IsDeleted bit NOT NULL,
	Latitude double precision NULL,
	Longitude double precision NULL
);

--
-- Name: River; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.River(
	CID numeric(8, 0) NOT NULL PRIMARY KEY,
	CodeEntite varchar(8) NOT NULL,
	Name text NULL,
	Candidat text NULL,
	Classe int NOT NULL
);

--
-- Name: Trash; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.Trash(
	Id uuid NOT NULL PRIMARY KEY,
	CampaignId uuid NOT NULL,
	Latitude double precision NULL,
	Longitude double precision NULL,
	TrashTypeId uuid NOT NULL,
	Precision double precision NULL,
	AI_Version decimal(18, 0) NULL,
	Brand_Type text NULL,
	RelatedImageId uuid NULL,
	AIVersion decimal(18, 0) NULL
);

--
-- Name: Trash_Type; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.Trash_Type(
	Id uuid NOT NULL PRIMARY KEY,
	Type text NOT NULL,
    PRIMARY KEY (Id, Type)
);

--
-- Name: User; Type: TABLE; Schema: public;
--

CREATE TABLE IF NOT EXISTS public.User(
	Id uuid NOT NULL PRIMARY KEY,
	Firstname text NULL,
	Lastname text NULL,
	Email text NOT NULL,
	EmailConfirmed bit NOT NULL,
	PasswordHash text NULL,
	YearOfBirth date NULL,
	Experience text NULL,
	IsDeleted bit NOT NULL
);
-------------------------------
--	Create Tables - raw_data --
-------------------------------

--
-- Name: europe_sea; Type: TABLE; Schema: raw_data; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS raw_data.europe_sea (
    geo_point text,
    geo_shape text,
    fcsubtype integer,
    inspire_id text,
    begin_lifes date,
    f_code text,
    icc text,
    shape__length double precision,
    shape__area double precision,
    the_geom public.geometry
);


--
-- Name: limite_terre_mer; Type: TABLE; Schema: raw_data; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS raw_data.limite_terre_mer (
    id text,
    code_hydro text,
    code_pays text,
    type_limit text,
    niveau text,
    date_creat text,
    date_maj text,
    date_app text,
    date_conf text,
    source text,
    id_source text,
    prec_plani text,
    src_coord text,
    statut text,
    origine text,
    comment text,
    geometry public.geometry
);


--
-- Name: region; Type: TABLE; Schema: raw_data; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS raw_data.region (
    id text,
    nom_reg text,
    insee_reg text,
    geometry public.geometry
);


--
-- Name: trace; Type: TABLE; Schema: raw_data; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS raw_data.trace (
    position_values public.geometry,
    altitude_points double precision,
    date_recorded date,
    hr_values integer,
    lat double precision,
    lng double precision,
    started_at date,
    uid text
);


-----------------------------
--	Create Tables - traces --
-----------------------------

--
-- Name: trajectory; Type: TABLE; Schema: traces; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS traces.trajectory (
    position_values public.geometry,
    altitude_points double precision,
    date_recorded date,
    hr_values integer,
    lat double precision,
    lng double precision,
    started_at date,
    uid text
);

-------------------------
--	Create Tables - bi --
-------------------------

--
-- Name: Campaign; Type: TABLE; Schema: bi; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS bi.Campaign(
	Id uuid NOT NULL PRIMARY KEY,
	CampaignStartSeaDist int NULL,
	CampaignEndSeaDist int NULL,
	TotalDist int NULL,
	TotalLitter int NULL,
	LitterDensity int NULL,
	TotalUnknow int NULL,
	TotalUnknow10 int NULL,
	TotalCommonHouseholdItems int NULL,
	TotalDrinkingBottles int NULL,
	TotalFoodPackaging int NULL,
	TotalAgriculturalWaste int NULL,
	TotalIndustrialOrConstructionDebris int NULL,
	TotalFishingAndHunting int NULL,
	TotalBottles int NULL,
	TotalFragments int NULL,
	TotalOthers int NULL
);

--
-- Name: Logs; Type: TABLE; Schema: bi; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS bi.Logs(
	Id uuid NOT NULL PRIMARY KEY,
	InitiatedOn date NOT NULL,
	FinishedOn date NOT NULL,
	ElapsedTime double precision NULL,
	Status text NOT NULL
);

--
-- Name: River; Type: TABLE; Schema: bi; Owner: SurfriderAdmin
--

CREATE TABLE IF NOT EXISTS bi.River(
	Id uuid NOT NULL PRIMARY KEY,
	Name text NOT NULL,
	MeanDensityOfLitter decimal(18, 0) NULL
);

---------------------
--	Create Indices --
---------------------
--
-- Name: raw_data_europe_sea_the_geom; Type: INDEX; Schema: raw_data; Owner: SurfriderAdmin
--

CREATE INDEX IF NOT EXISTS raw_data_europe_sea_the_geom ON raw_data.europe_sea USING gist (the_geom);


--
-- Name: traces_trajectory_position_values; Type: INDEX; Schema: traces; Owner: SurfriderAdmin
--

CREATE INDEX IF NOT EXISTS traces_trajectory_position_values ON traces.trajectory USING gist (position_values);


--
-- End of script
--

