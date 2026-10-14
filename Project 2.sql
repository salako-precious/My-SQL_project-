SELECT * FROM md_water_services.auditor_report;
-- grab the location_id and true_water_source_score columns from auditor_report.
SELECT 
location_id,
true_water_source_score
FROM 
auditor_report

-- Now, we join the visits table to the auditor_report table. 
-- Make sure to grab subjective_quality_score, record_id and location_id.
SELECT 
ar.location_id AS ar_location,
ar.true_water_source_score,
v.record_id,
v.location_id AS v_locaton_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v
ON
ar.location_id = v.location_id

-- Now that we have the record_id for each location, our next step is to retrieve the corresponding scores from the water_quality table. 
-- We are particularly interested in the subjective_quality_score. 
-- To do this, we'll JOIN the visits table and the water_quality table, using the record_id as the connecting key.
SELECT 
ar.location_id AS ar_location,
ar.true_water_source_score,
wq.subjective_quality_score,
wq.record_id AS wq_record,
v.record_id AS v_record,
v.location_id AS v_locaton_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v ON ar.location_id = v.location_id
JOIN 
water_quality AS wq ON v.record_id = wq.record_id

-- It doesn't matter if your columns are in a different format, because we are about to clean this up a bit. 
-- Since it is a duplicate, we can drop one of the location_id columns. 
-- Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores we're looking at in the results set.
SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
wq.record_id AS wq_record,
v.record_id AS v_record,
v.location_id AS v_locaton_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v 
JOIN 
water_quality AS wq ON v.record_id = wq.record_id

SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
wq.record_id AS wq_record,
v.record_id AS v_record,
v.location_id AS v_locaton_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v 
JOIN 
water_quality AS wq ON v.record_id = wq.record_id
WHERE 
wq.subjective_quality_score = ar.true_water_source_score
LIMIT 10000

-- You got 2505 rows right? Some of the locations were visited multiple times, so these records are duplicated here. 
-- To fix it, we set visits.visit_count = 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.
SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
v.visit_count,
wq.record_id AS wq_record,
v.record_id AS v_record,
v.location_id AS v_locaton_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v 
JOIN 
water_quality AS wq ON v.record_id = wq.record_id
WHERE 
wq.subjective_quality_score = ar.true_water_source_score 
AND
v.visit_count = 1 
LIMIT 10000

-- So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the source_id column to JOIN. 
-- Also select the type_of_water_source from the auditor_report table, and call it auditor_source
SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
ws.type_of_water_source AS survey_source,
ws.source_id,
ar.type_of_water_source AS auditor_source,
v.record_id AS v_record,
v.location_id AS v_locaton_id,
v.source_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v ON v.location_id = ar.location_id 
JOIN
water_source AS ws ON v.source_id = ws.source_id
JOIN 
water_quality AS wq ON v.record_id = wq.record_id
WHERE 
wq.subjective_quality_score != ar.true_water_source_score 
AND
v.visit_count = 1 
-- Once you're done, remove the columns and JOIN statement for water_sources again.
-- In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on our list from the visits table to our query. 
-- Remember, our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which employees made these incorrect records.
SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
ar.type_of_water_source AS auditor_source,
v.record_id AS v_record,
v.assigned_employee_id,
e.assigned_employee_id,
v.location_id AS v_locaton_id,
v.source_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v ON v.location_id = ar.location_id 
JOIN 
employee AS e ON e.assigned_employee_id = v.assigned_employee_id
JOIN 
water_quality AS wq ON v.record_id = wq.record_id
WHERE 
wq.subjective_quality_score != ar.true_water_source_score 
AND
v.visit_count = 1 

-- So now we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. 
-- We have employees' names stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.
SELECT 
ar.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
ar.type_of_water_source AS auditor_source,
v.record_id AS v_record,
v.assigned_employee_id,
e.employee_name,
v.location_id AS v_locaton_id,
v.source_id
FROM 
auditor_report AS ar
JOIN 
Visits AS v ON v.location_id = ar.location_id 
JOIN 
employee AS e ON e.assigned_employee_id = v.assigned_employee_id
JOIN 
water_quality AS wq ON v.record_id = wq.record_id
WHERE 
wq.subjective_quality_score != ar.true_water_source_score 
AND
v.visit_count = 1 

-- Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, we can just call that CTE
-- like it was a table. Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets  the same table back.
    WITH Incorrect_Records AS (
    -- Step 1: Isolate the 102 incorrect records
    SELECT 
        ar.location_id,
        v.record_id,
        v.assigned_employee_id,
        ar.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS surveyor_score
    FROM 
        auditor_report AS ar
    JOIN 
        visits AS v ON ar.location_id = v.location_id
    JOIN 
        water_quality AS wq ON v.record_id = wq.record_id
    WHERE 
        v.visit_count = 1
        AND ar.true_water_source_score != wq.subjective_quality_score
)
-- Step 2: Join the employee names to those specific records
SELECT 
    ir.location_id,
    ir.record_id,
    e.employee_name,
    ir.auditor_score,
    ir.surveyor_score
FROM 
    Incorrect_Records AS ir
JOIN 
    employee AS e ON ir.assigned_employee_id = e.assigned_employee_id;
    
    WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
employee_name)
-- Query
SELECT * FROM error_count;