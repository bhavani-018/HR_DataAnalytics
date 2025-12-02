SELECT * FROM hr;

ALTER table hr
rename column employee_id to empl_id;

ALTER table hr
RENAME to hr_data;

SELECT * FROM hr_data;

DESCRIBE hr_data;

ALTER TABLE hr_data
MODIFY column birthdate DATE; 

SET sql_safe_updates=0;

UPDATE hr_data
SET birthdate = CASE
WHEN birthdate LIKE "%/%"
THEN date_format(str_to_date(birthdate,"%m/%d/%y"),'%y-%m-%d')
WHEN birthdate LIKE "%-%"
THEN date_format(str_to_date(birthdate,"%m/%d/%y"),"%y-%m-%d")
ELSE NULL
end;

UPDATE hr_data
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr_data
MODIFY COLUMN hire_date DATE;

UPDATE hr_data
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

ALTER TABLE hr_data
MODIFY COLUMN termdate date;

ALTER TABLE hr_data
 ADD COLUMN age INT;

UPDATE hr_data
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr_data;

SELECT count(*) FROM hr_data WHERE age < 18;

SELECT termdate FROM hr_data;


SELECT COUNT(*)
FROM hr_data
WHERE termdate is null;

SELECT location FROM hr_data;

SELECT location_city FROM hr_data;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, COUNT(*) as count
FROM hr_data
WHERE age>=18 
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race , COUNT(*) as count
FROM hr_data
GROUP BY race 
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?

SELECT MIN(age) as young ,MAX(age) as old
FROM hr_data
WHERE age >=18;

SELECT FLOOR(age/10)*10 AS age_group, COUNT(*) AS count
FROM hr_data
WHERE age >= 18
GROUP BY FLOOR(age/10)*10
order by age_group;

SELECT
CASE
WHEN age BETWEEN 18 and 29 THEN "18-29"
WHEN age BETWEEN 30 and 39 THEN "30-39"
WHEN age BETWEEN 40 and 49 THEN "40-49"
ELSE "50-59"
END as age_group,gender
FROM hr_data
WHERE age>=18
GROUP BY age_group,gender;


-- 4. How many employees work at headquarters versus remote locations?
SELECT location,COUNT(*)
FROM hr_data
WHERE age>=18
GROUP BY location;
 
-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date)),0)/365 AS avg_length_of_employment
FROM hr_data
WHERE termdate <= CURDATE() AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT gender,department, count(*) 
FROM hr_data
where age>=18
GROUP BY gender,department
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT * FROM hr_data;
SELECT jobtitle,COUNT(*)
FROM hr_data
where age>=18
GROUP BY jobtitle;

-- 8. Which department has the highest turnover rate?
SELECT department, COUNT(*) as total_count, 
    SUM(CASE WHEN termdate <= CURDATE() AND termdate is not NULL THEN 1 ELSE 0 END) as terminated_count, 
    SUM(CASE WHEN termdate is NULL THEN 1 ELSE 0 END) as active_count,
    (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) as termination_rate
FROM hr_data
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state,COUNT(*)
FROM hr_data
where age>=18
GROUP BY location_state;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
    YEAR(hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate is not null AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate is not null AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
    ROUND(((COUNT(*) - SUM(CASE WHEN termdate is not null AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM 
    hr_data
WHERE age >= 18
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    YEAR(hire_date) ASC;
    
-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM hr_data
WHERE termdate <= CURDATE() AND termdate is not null AND age >= 18
GROUP BY department;