-- Weaving The Data Threads Of Maji Ndogo's Narrative
select
    location_id,
    true_water_source_score
from
   auditor_report;
   
-- We join the visits table to the auditor_report table.
-- We need to grab subjective_quality_score, record_id and location_id

select
     ar.location_id as audit_location,
     ar.true_water_source_score,
     v.record_id,
	 v.location_id as v_location_id
from auditor_report ar
inner join visits v on ar.location_id = v.location_id;

-- Note that i specified from which table each selected column is from in this query:
select
    auditor_report.location_id as audit_location,
    auditor_report.true_water_source_score,
    visits.location_id as visit_location,
    visits.record_id
from
  auditor_report
join
   visits
   on auditor_report.location_id = visits.location_id;

-- Retreive the corresponding scores from the water_quality table particularly intrested in the subjective_quality_score.
-- We'll join the visits table and the water_quality table using record_id as the connecting key

SELECT
    ar.location_id as audit_location,
    ar.true_water_source_score,
    v.location_id as visit_location,
    wq.record_id,
    wq.subjective_quality_score
FROM
    auditor_report ar
JOIN
    visits v ON ar.location_id = v.location_id
JOIN
    water_quality wq ON v.record_id = wq.record_id;

-- Drop one of the location  and rename our scores
select
    ar.location_id as location_id,
    ar.true_water_source_score as auditor_score,
    v.record_id,
    wq.subjective_quality_score as surveyor_score
from
    auditor_report ar
join
    visits v on ar.location_id = v.location_id
join
    water_quality wq on v.record_id = wq.record_id;

-- Let's check whether our auditor's scores and employees' scores agree
-- Check if the surveyor_score = auditor_score, or we can subtract the two scores and check if the result is 0

select
   ar.location_id,
   ar.true_water_source_score as auditor_score,
   v.record_id,
   wq.subjective_quality_score as employee_score
from
   auditor_report ar
join
  visits v on ar.location_id = v.location_id
join
   water_quality wq on v.record_id = wq.record_id
where
   ar.true_water_source_score = wq.subjective_quality_score
   and v.visit_count = 1
limit 0, 10000;

-- Let's grab the type_of_water_source column from the water_source table and call it surveyor_source and use the source_id column to join
-- We will also select the type_of_water_source from the auditor_report table, and call it auditor_source
select
  ar.location_id,
  ar.true_water_source_score as auditor_score,
  v.record_id,
  wq.subjective_quality_score as employee_score,
  ws.type_of_water_source as survey_source,
  ar.type_of_water_source as auditor_source
from
   auditor_report ar
join
   visits v on ar.location_id = v.location_id
join
   water_quality wq on v.record_id = wq.record_id
left join
   water_source ws on v.source_id = ws.source_id
where 
    ar.true_water_source_score = wq.subjective_quality_score
    and v.visit_count = 1;

-- Join the assigned_employe_id for all the people on our the visits table
select
   ar.location_id,
   ar.true_water_source_score as auditor_score,
   v.record_id,
   wq.subjective_quality_score as employee_score,
   v.assigned_employee_id
from
    auditor_report ar
join
   visits v on ar.location_id = v.location_id
join
   water_quality wq on v.record_id = wq.record_id
where
   ar.true_water_source_score <> wq.subjective_quality_score
   and v.visit_count = 1;

-- Let's link the incorrect records to the employees who recorded them
select
    ar.location_id,
    ar.true_water_source_score as auditor_score,
    v.record_id,
    wq.subjective_quality_score as surveyor_score,
    ar.type_of_water_source as auditor_source,
    e.employee_name as employee_name
from
   auditor_report ar
join
   visits v on ar.location_id = v.location_id
join
   water_quality wq on v.record_id = wq.record_id
join
   employee e on v.assigned_employee_id = e.assigned_employee_id
where
   ar.true_water_source_score <> wq.subjective_quality_score
   and v.visit_count = 1;

-- Let's save the above code as a cte so that we can refer back to it later
WITH Incorrect_records AS (
    SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
)
SELECT * FROM Incorrect_records;

-- We can now query this on any other table
-- Let's get a unique list of the employees from this table
WITH Incorrect_records AS(
     SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
)
SELECT DISTINCT employee_name
FROM Incorrect_records;

-- Let's try to calculate how many mistakes each employee made 
-- That is we count how many times their name is in Incorrect_records list and group them by name

WITH Incorrect_records AS(
	SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
)
SELECT employee_name, COUNT(*) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;

-- We will create another subquery and rename the number of mistakes to error_count
WITH Incorrect_records AS(
	SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
),
error_count AS (
    SELECT employee_name, COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
avg_error_count_per_empl AS(
     SELECT
	    AVG(number_of_mistakes) as avg_error_count
     FROM
        error_count
)
SELECT
    employee_name,
    number_of_mistakes
FROM
    error_count
WHERE
    number_of_mistakes > ( SELECT avg_error_count FROM avg_error_count_per_empl);

-- Since Incorrect_records is a result ww will be using for the rest of the anlysis
-- Lets convert it to a VIEW

CREATE VIEW Incorrect_records AS (
SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1);
-- Calling SELECT* FROM Incorrect_records gives us the same result as the CTE did
WITH error_count AS( -- This CTE calculates the number of mistakes each employee made
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
	FROM
       Incorrect_records
       /* Incorrect_records is a view that joins the audit report to 
       the database for the records where the auditor and employees scores are different*/
    GROUP BY
        employee_name
)
SELECT * FROM error_count;

-- Calculating the average of the number_of_mistakes in error_count.
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
	FROM
        Incorrect_records
	GROUP BY
		employee_name
)
SELECT 
   AVG(number_of_mistakes) as average_mistakes
FROM error_count;

-- Find employees who made more mistkaes than average person
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
	FROM
        Incorrect_records
	GROUP BY
		employee_name
),
average_mistakes AS (
      SELECT AVG(number_of_mistakes) AS avg_mistakes
      FROM error_count
)
SELECT
    ec.employee_name,
    ec.number_of_mistakes
FROM error_count AS ec
CROSS JOIN average_mistakes AS am
WHERE ec.number_of_mistakes > am.avg_mistakes;

-- We should look at the Incorrect_records table and isolate the reocrds of the top 5 employees
-- We convert the suspect list to CTE, and use it to filter the records from these four employess

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
	FROM
        Incorrect_records
	GROUP BY
		employee_name
),
average_mistakes AS (
      SELECT AVG(number_of_mistakes) AS avg_mistakes
      FROM error_count
),
suspect_list AS (
    SELECT
        ec.employee_name,
        ec.number_of_mistakes
	FROM error_count AS ec
    CROSS JOIN average_mistakes AS am
	WHERE ec.number_of_mistakes > am.avg_mistakes
)
SELECT* FROM suspect_list;

-- filter all the records where the 'corrupt' employees gathered data
-- first we need to add the statements column to the Incorrect_records CTE

WITH Incorrect_records AS (
    SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name,
        ar.statements  -- Add the statements column here
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
)
SELECT * FROM Incorrect_records;
-- We then update the view
CREATE VIEW Incorrect_records2 AS (
SELECT
        ar.location_id,
        ar.true_water_source_score as auditor_score,
        v.record_id,
        wq.subjective_quality_score as surveyor_score,
        ar.type_of_water_source as auditor_source,
        e.employee_name as employee_name,
        ar.statements  -- Add the statements column here
    FROM
        auditor_report ar
    JOIN
        visits v ON ar.location_id = v.location_id
    JOIN
        water_quality wq ON v.record_id = wq.record_id
    JOIN
        employee e ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        ar.true_water_source_score <> wq.subjective_quality_score
        AND v.visit_count = 1
);

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
	FROM
        Incorrect_records
	GROUP BY
		employee_name
),
average_mistakes AS (
      SELECT AVG(number_of_mistakes) AS avg_mistakes
      FROM error_count
),
suspect_list AS (
    SELECT
        ec.employee_name,
        ec.number_of_mistakes
	FROM error_count AS ec
    CROSS JOIN average_mistakes AS am
	WHERE ec.number_of_mistakes > am.avg_mistakes
)
SELECT
     employee_name,
     location_id,
     statements
FROM
    Incorrect_records2
WHERE
    employee_name in (SELECT employee_name FROM suspect_list);   

-- Questions
-- Q1
-- The following query results in 2,698 rows but the auditor_table has 1,620.
-- Analyze the query and select why this discrepancy occurs.alter

select
    ar.location_id,
    v.record_id,
    E.employee_name,
    ar.true_water_source_score as auditor_score,
    wq.subjective_quality_score as employee_score
from
   auditor_report as ar
join visits as v
on ar.location_id = v.location_id
join water_quality as wq
on v.record_id = wq.record_id
join employee as E
on E.assigned_employee_id = v.assigned_employee_id;
-- The visits table has multiple records for each location_id, which when joined
-- with auditor_report, results in multiple records for each location_id
-- Q2
/*
WITH Incorrect_records AS (-- This CTE fetches all of the records with wrong scores
    SELECT
       auditorRep.location_id,
       visitsTbl.record_id,
       Empl_Table.employee_name,
       auditorRep.true_water_source_score AS auditor_score,
       wq.subjective_quality_score AS employee_score
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id
WHERE visitsTbl.visit_count =1 AND auditorRep.true_water_source_score != wq.subjective_quality_score
);*/
-- Incorrect_records serves as a temporary result set to store aggregated data of records with different scores between
-- auditor and employee for the main query
-- Q3 = The subquery is a scalar subquery used to calculate number_of_mistakes for comparison.
-- Q4 = The subquery is a correlated subquery that returns all of the employees that made errors
-- Q5 = employee has a 1-to-many relationship with visits
-- Q6 = location
-- Q7 = JOIN well_pollution ON visitstbl.source_id = well_pollution.source_id
-- Q8 = Lalitha Kaburi
-- Q9 = Lalitha Kaburi
-- Q10 = The query retreives the location_id, record_id, and water scores by joining
-- the water_quality and visits table, and then calculates a difference in scores between the employee's scores and the auditor's scores
