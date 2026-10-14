SELECT * FROM md_water_services.location;
SELECT * 
FROM
water_source
SELECT 
type_of_water_source 
from 
water_source
LIMIT 5;

/* Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. 
/* How would it feel to queue 8 hours for water /*
SELECT 
* 
FROM 
VISITS 
WHERE 
time_in_queue >= 500

-- am wondering what type of water sources take this long to queue for --
SELECT 
visits.Source_id, 
water_source.source_id,
visits.time_in_queue,
water_source.type_of_water_source,
water_source.number_of_people_served
FROM 
water_source, visits 
WHERE 
time_in_queue >= 500

-- So please write a query to find records where the subject_quality_score is 10 -- only looking for home taps -- 
-- and where the source was visited a second time. What will this tell us? --
SELECT 
visits.record_id, 
water_quality.record_id,
Water_quality.subjective_quality_score
FROM 
visits,
water_quality 
WHERE 
subjective_quality_score = 10

SELECT 
visits.source_id,
visits.visit_count, 
water_source.type_of_water_source
FROM 
visits,
water_source
WHERE
visit_count > 1,
and
type_of_water_source = 'tap_in_home'

-- So, write a query that checks if the results is Clean but the biological column is > 0.01.-- 
SELECT 
source_id,
biological,
description,
results
FROM
well_pollution  
WHERE 
results = 'clean' AND 
biological > 0.01