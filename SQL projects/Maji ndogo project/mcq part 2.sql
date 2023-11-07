/*
Cleaning our data
Our employee table does not include email addresses
*/
SELECT * FROM md_water_services.employee
/* We will determine the email address for each employee by:
 Selecting the employee_name column
 Replacing the space with a full stop
 make it lowercase
 and stitch it all together
 */

SELECT
    REPLACE(employee_name, ' ', '.') -- Replace the space with a full stop
FROM
    employee;

-- Use LOWER() with the result we just got
SELECT
    LOWER(REPLACE(employee_name, ' ', '.')) -- Make it all lower case
FROM
    employee;

-- We use CONCAT() to add the rest of the email address
SELECT
    CONCAT(
    LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email -- add it all together
FROM
    employee;

-- Lets update the email column with email addresses
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
            '@ndogowater.gov')
            
-- Let's clean our phone_number column, the values are stored as strings
-- We will check the lenght first
SELECT
     LENGTH(phone_number)
FROM
    employee;
-- it returns 13 characters, indicating there's an extra character because there is space at the end of the number
-- Let's use the TRIM(column) it will remove any leading or trailing spaces froma string
SELECT
     LTRIM(RTRIM(phone_number)) as Trimmed_phone_number
From
    employee;

UPDATE employee
SET phone_number =  LTRIM(RTRIM(phone_number))

-- let's check whether our phone_number lenght is 12
SELECT
     LENGTH(phone_number)
FROM
    employee;

/* Honouring the workers
Let's have a look at where our employees live
We will use the GROUPBY function
*/

SELECT town_name, COUNT(*) AS number_of_employees
FROM employee
GROUP BY town_name
limit 20;

-- total number of employees
SELECT employee_name, count(*) AS total_number_of_employees
FROM employee;

-- Three top field surveyors with the most location visits
SELECT assigned_employee_id, COUNT(*) AS location_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY location_visits DESC;

-- Let's use the top 3 assigned_employee_id and use the to ceate a qery that looks up the employee's info
SELECT employee_name, email, phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);

-- Worst performing workers
SELECT employee_name, email, phone_number
FROM employee
WHERE assigned_employee_id IN (20, 22, 44);

/* Analysing Locations
Let's focus on the province_name, town_name and location_type
Let's create a query that counts the number of records per town
*/
SELECT town_name, COUNT(*) AS records_per_town
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- Records per province
SELECT province_name, COUNT(*) AS records_per_province
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;

-- Let's create a result set with province and town name with their aggregated reords
SELECT province_name, town_name, COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, records_per_town DESC;

-- Number of records for each location type
SELECT location_type, COUNT(*) AS num_sources
FROM location
GROUP BY location_type;
-- Let's convert to percentage
SELECT 23740 / (15910 + 23740) * 100;

-- Diving into the sources
-- Lets count the different water sources there are and sort them

SELECT type_of_water_source, COUNT(*) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;

-- Average number of people that are served by each water source in percentage
SELECT type_of_water_source,
     CAST(AVG(number_of_people_served) AS SIGNED) avg_people_per_source
FROM water_source
GROUP BY type_of_water_source;

-- Total number of people served by each type of water source
SELECT type_of_water_source,
    SUM(number_of_people_served) AS population_served
FROM water_source
group by type_of_water_source
order by population_served desc;

-- How many people did we survey in total
SELECT SUM(number_of_people_served) AS total_people_surveyed
FROM water_source;

-- Let's calculate percentages using the total we just got.
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served,
    ROUND((SUM(number_of_people_served) / t.total_people_surveyed) * 100, 0) AS percentage
FROM water_source
CROSS JOIN (
    SELECT SUM(number_of_people_served) AS total_people_surveyed
    FROM water_source
) t
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;

SELECT type_of_water_source,
       SUM(number_of_people_served) AS population_served,
       RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS ranked_by_population
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;

-- Analysing queues
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;

