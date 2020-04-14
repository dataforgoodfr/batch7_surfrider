drop view public.river_trajectory;
create view public.river_trajectory as
select  tpr.id_ref_river_fk 
		,tp.id_ref_campaign_fk 
		,river."name" 
		,ST_MakeLine(tpr.closest_point_the_geom ORDER BY tp."time")::geometry(Linestring, 2154) river_trajectory_geom
		,ST_MakeLine(tpr.trajectory_point_the_geom ORDER BY tp."time")::geometry(Linestring, 2154) trajectory_geom
		,ST_Length(ST_MakeLine(tpr.closest_point_the_geom ORDER BY tp."time")::geometry(Linestring, 2154))
from trajectory_point_river tpr
left join trajectory_point tp
	on tpr.id_ref_trajectory_point_fk = tp.id 
left join river 
	on river.id = tpr.id_ref_river_fk 
group by tpr.id_ref_river_fk  
		,tp.id_ref_campaign_fk 
		,river."name" 
having count(tpr.closest_point_the_geom) > 1
