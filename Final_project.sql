USE MD_WATER_SERVICES
-- All of the information about the location of a water source is in the location table, specifically the town and province of that water source
-- water_source has the type of source and the number of people served by each source.
-- visits has queue information, and connects source_id to location_id. There were multiple visits to sites, so we need to be careful to include duplicate data (visit_count > 1 ).
-- well_pollution has information about the quality of water from only wells, so we need to keep that in mind when we join this table.
-- Questions
-- 1. Are there any specific provinces, or towns where some sources are more abundant?
-- We identified that tap_in_home_broken taps are easy wins. Are there any towns where this is a particular problem?
SELECT 
loc.province_name,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.visit_count,
v.location_id, 
v.source_id
FROM 
location AS loc
JOIN 
visits AS v ON loc.location_id = v.location_id 
JOIN
water_source AS ws ON ws.source_id = v.source_id
WHERE v.location_id = 'AkHa00103'
-- There are more visit_count for the selected id with same province and town. 

-- There you can see what I mean. For one location, there are multiple AkHa00103 records for the same location. 
-- If we aggregate, we will include these rows, so our results will be incorrect. To fix this, we can just select rows where visits.visit_count = 1.
SELECT 
loc.province_name,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.visit_count,
v.location_id, 
v.source_id
FROM 
location AS loc
JOIN 
visits AS v ON loc.location_id = v.location_id 
JOIN
water_source AS ws ON ws.source_id = v.source_id
WHERE v.visit= 1


SELECT 
loc.province_name,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.source_id
FROM 
location AS loc
JOIN 
visits AS v ON loc.location_id = v.location_id 
JOIN
water_source AS ws ON ws.source_id = v.source_id

-- Add the location_type column from location and time_in_queue from visits to our results set.
SELECT 
loc.province_name,
loc.location_type,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.time_in_queue,
v.source_id
FROM 
location AS loc
JOIN 
visits AS v ON loc.location_id = v.location_id 
JOIN
water_source AS ws ON ws.source_id = v.source_id


-- Last one! Now we need to grab the results from the well_pollution table.
-- This one is a bit trickier. The well_pollution table contained only data for well. If we just use JOIN, we will do an inner join, so that only records
-- that are in well_pollution AND visits will be joined. We have to use a LEFT JOIN to join theresults from the well_pollution table for well
-- sources, and will be NULL for all of the rest. Play around with the different JOIN operations to make sure you understand why we used LEFT JOIN

SELECT 
loc.province_name,
loc.location_type,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.time_in_queue,
v.source_id,
wp.results
FROM 
location AS loc
JOIN 
visits AS v ON loc.location_id = v.location_id 
JOIN
water_source AS ws ON ws.source_id = v.source_id


-- Playing around to see differnce in the type of join 
SELECT 
loc.province_name,
loc.location_type,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.time_in_queue,
v.source_id,
wp.results
FROM 
location AS loc
INNER JOIN 
visits AS v ON loc.location_id = v.location_id 
LEFT JOIN
well_pollution AS wp ON wp.source_id = v.source_id
INNER JOIN
water_source AS ws ON ws.source_id = v.source_id


CREATE VIEW combined_analysis_table AS ( -- Creating a temporary table for further analysis. You can also use CTE
SELECT 
loc.province_name,
loc.location_type,
loc.town_name,
ws.type_of_water_source, 
ws.number_of_people_served, 
v.time_in_queue,
v.source_id,
wp.results
FROM 
location AS loc
INNER JOIN 
visits AS v ON loc.location_id = v.location_id 
LEFT JOIN
well_pollution AS wp ON wp.source_id = v.source_id
INNER JOIN
water_source AS ws ON ws.source_id = v.source_id
where v.visit_count = 1
)

WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;


WITH town_totals AS (-- This CTE calculates the population of each province
SELECT
town_name,
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name,
town_name
)
SELECT
ct.town_name,
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY
ct.province_name, ct.town_name
ORDER BY
ct.town_name;
