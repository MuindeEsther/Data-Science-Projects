SELECT * FROM md_water_services.employee;
SELECT employee_name, phone_number
FROM employee
WHERE position = 'Micro biologist';
SELECT*
FROM employee
WHERE position = 'Civil Engineer' AND (province_name = 'Dhahabu' OR address = 'Avenue');
 SELECT *
FROM employee
WHERE position = 'Civil Engineer' AND province_name = 'Dahabu' OR address LIKE '%Avenue%'; 

SELECT *
FROM employee
WHERE position = 'Civil Engineer' AND (province_name = 'Dahabu' OR address LIKE '%Avenue%'); 

 SELECT *
FROM employee
WHERE (position = 'Civil Engineer' AND province_name = 'Dahabu') OR address LIKE '%Avenue%'; 

SELECT *
FROM employee
WHERE
    (
        (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
        AND (employee_name LIKE 'A%' OR employee_name LIKE 'M%')
        AND position = 'Field Surveyor'
    );
