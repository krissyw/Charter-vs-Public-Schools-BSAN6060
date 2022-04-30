/*
BSAN 6060 Project 
Krissy Wong 
Sanjana Chowdhury
*/ 

# 2018 Data 

USE lmudashb_bsan6060_project;

/*
Create a new table named LA_schools_2018 to filter CA_schools_2018
to only include schools in Los Anegles county and Los Angeles Unified School
District.
*/ 

CREATE TABLE LA_schools_2018 AS
SELECT * 
FROM CA_schools_2018
WHERE county_name = "Los Angeles"
AND district_name = "Los Angeles Unified";


/*
Create a new table named LA_grad_2018 to filter grad_rate_2018
to only include schools in Los Anegles county.
*/ 

CREATE TABLE LA_grad_rate_2018 AS 
SELECT * 
FROM grad_rate_2018
WHERE county_name = "Los Angeles"
AND district_name = "Los Angeles Unified";


/*
Add primary key for LA_grad_rate_2018
*/

ALTER TABLE LA_grad_rate_2018
add column school_id INT AUTO_INCREMENT PRIMARY KEY;


/*
Create a new table named LA_staff_2018 to filter staff_2018
to only include schools in Los Anegles county.
*/ 

CREATE TABLE LA_staff_2018
SELECT * 
FROM staff_2018
WHERE county_name = "Los Angeles"
AND district_name = "Los Angeles Unified";


/*
Create a new table named LA_staff__assign_2018 to filter staff__assign_2018
to only include schools in Los Anegles county.
*/ 

CREATE TABLE LA_staff_assign_2018
SELECT * 
FROM staff_assign_2018
WHERE county_name = "Los Angeles"
AND district_name = "Los Angeles Unified";


/* 
Find the the average dropout and High School graduation rates for 
Charter schools.
*/

SELECT 
	school_name,
    SUM(cohort_students) AS total_students,
	ROUND(AVG(dropout_rate), 1) AS avg_total_dropout,
    ROUND(AVG(HS_grad_rate), 1) AS avg_total_HS_grads 
FROM LA_grad_rate_2018
WHERE charter_school = "Yes"
GROUP BY school_name
ORDER BY total_students DESC;


/* 
Find the the average dropout and High School graduation rates for 
Public schools.
*/

SELECT 
	school_name,
    SUM(cohort_students) AS total_students,
	ROUND(AVG(dropout_rate), 1) AS avg_total_dropout,
    ROUND(AVG(HS_grad_rate), 1) AS avg_total_HS_grads 
FROM LA_grad_rate_2018
WHERE charter_school = "No"
GROUP BY school_name
ORDER BY total_students DESC;


/* 
Find the the the counts of ethnicities of teachers, administrators, and pupil personnel
services (PPS) the district. Since Windows Functions does not work in LMU Build, I will
need to create individual tables for certified staff so I can make queries with the count
later. 
*/

CREATE TABLE teachers_2018
	SELECT
		sa.recID,
		s.ethnicity,
		COUNT(sa.staff_type) AS count_teachers 
	FROM LA_staff_assign_2018 sa
	JOIN LA_staff_2018 s
		ON sa.recID = s.recID
	WHERE sa.staff_type  = "T"
	GROUP BY s.ethnicity; 

CREATE TABLE administrators_2018
	SELECT 
		sa.recID,
        s.ethnicity,
		COUNT(sa.staff_type) AS count_administrators
	FROM LA_staff_assign_2018 sa
    JOIN LA_staff_2018 s
		ON sa.recID = s.recID
	WHERE sa.staff_type  = "A"
	GROUP BY s.ethnicity;
    
CREATE TABLE pps_2018
	SELECT 
		sa.recID,
        s.ethnicity,
		COUNT(sa.staff_type) AS count_pps
	FROM LA_staff_assign_2018 sa
    JOIN LA_staff_2018 s
		ON sa.recID = s.recID
	WHERE sa.staff_type  = "P"
	GROUP BY s.ethnicity;
    

SELECT 
	t.ethnicity,
    t.count_teachers,
    a.count_administrators,
    p.count_pps
FROM teachers_2018 t 
JOIN administrators_2018 a
	ON t.ethnicity = a.ethnicity
JOIN pps_2018 p
	ON a.ethnicity = p.ethnicity
GROUP BY t.ethnicity;

/* 
Find average age of teachers in charter schools.Since Windows Functions does not work in LMU Build, I will
need to create individual tables for certified staff so I can make queries with the count
later. 
*/ 

CREATE TABLE avg_teach_age_charter_schools_2018 AS(
SELECT 
	g.school_code,
	g.school_name,
    ROUND(AVG(st.age), 0) AS average_age
FROM LA_staff_2018 st
JOIN LA_staff_assign_2018 sta
	ON st.recID = sta.recID
LEFT JOIN LA_grad_rate_2018 g
	ON sta.school_code = g.school_code
WHERE sta.staff_type = "T"
	AND g.charter_school = "Yes"
GROUP BY sta.school_name
ORDER BY average_age DESC
);


/* 
Find average age of teachers in public schools. Since Windows Functions does not work in LMU Build, I will
need to create individual tables for certified staff so I can make queries with the count
later. 
*/ 
CREATE TABLE avg_teach_age_public_schools_2018 AS (
	SELECT 
    g.school_code,
	g.school_name,
    ROUND(AVG(st.age), 0) AS average_age
FROM LA_staff_2018 st
JOIN LA_staff_assign_2018 sta
	ON st.recID = sta.recID
LEFT JOIN LA_grad_rate_2018 g
	ON sta.school_code = s.school_code
WHERE sta.staff_type = "T"
	AND g.charter_school = "No"
GROUP BY sta.school_name
ORDER BY average_age DESC
);

drop table avg_teach_age_public_schools_2018;

drop table avg_teach_age_charter_schools_2018;


/* 
Find the average age of staff from different ethnicities. 
*/ 

# Create table for average age of teachers 
CREATE TABLE teacher_age_2018 AS (
	SELECT 
		s.ethnicity, 
		ROUND(AVG(s.age), 0) AS average_age
    FROM LA_staff_2018 s
    JOIN LA_staff_assign_2018 sta 
		ON s.recID = sta.recID 
	WHERE sta.staff_type = "T"
	GROUP BY s.ethnicity
);

# Create table for average age of administrators
CREATE TABLE administrators_age_2018 AS (
	SELECT 
		s.ethnicity, 
		ROUND(AVG(s.age), 0) AS average_age
    FROM LA_staff_2018 s
    JOIN LA_staff_assign_2018 sta 
		ON s.recID = sta.recID 
	WHERE sta.staff_type = "A"
	GROUP BY s.ethnicity
);

#  Create table for average age of PPS 
CREATE TABLE pps_age_2018 AS (
	SELECT 
		s.ethnicity, 
		ROUND(AVG(s.age), 0) AS average_age
    FROM LA_staff_2018 s
    JOIN LA_staff_assign_2018 sta 
		ON s.recID = sta.recID 
	WHERE sta.staff_type = "P"
	GROUP BY s.ethnicity
);

SELECT 
	t.ethnicity,
    t.average_age AS teacher_avg_age,
    a.average_age AS administrator_avg_age,
    p.average_age AS pps_avg_age
FROM teacher_age_2018 t
JOIN administrators_age_2018 a
	ON t.ethnicity = a.ethnicity
JOIN pps_age_2018 p
	ON a.ethnicity = p.ethnicity 
GROUP BY t.ethnicity;

/* 
Find the number of teachers in charter and public schools. 
*/ 



# count of teachers in charter schools
CREATE TABLE num_teachers_charter_2018 AS(
	SELECT 
	s.school_code,
	s.school_name,
    COUNT(sta.staff_type) AS count_teachers
FROM LA_staff_assign_2018 sta
JOIN LA_schools_2018 s
	ON sta.school_code = s.school_code
WHERE s.charter_school = "Yes"
	AND sta.staff_type = "T"
GROUP BY s.school_name
); 

SELECT 
	g.school_name,
	SUM(g.cohort_students),
    num_teach.count_teachers,
    ROUND((SUM(g.cohort_students)/num_teach.count_teachers), 2) AS student_teacher_ratio 
FROM LA_grad_rate_2018 g
JOIN num_teachers_charter_2018 num_teach
	ON num_teach.school_code = g.school_code
GROUP BY g.school_name
ORDER BY student_teacher_ratio DESC
LIMIT 10;
    
# count of teachers in public schools
CREATE TABLE num_teachers_public_2018 AS(
	SELECT 
	s.school_code,
	s.school_name,
    COUNT(sta.staff_type) AS count_teachers
FROM LA_staff_assign_2018 sta
JOIN LA_schools_2018 s
	ON sta.school_code = s.school_code
WHERE s.charter_school = "No"
	AND sta.staff_type = "T"
GROUP BY s.school_name
);  

SELECT 
	g.school_name,
	SUM(g.cohort_students),
    num_teach.count_teachers,
    ROUND((SUM(g.cohort_students)/num_teach.count_teachers), 2) AS student_teacher_ratio 
FROM LA_grad_rate_2018 g
JOIN num_teachers_public_2018 num_teach
	ON num_teach.school_code = g.school_code
GROUP BY g.school_name
ORDER BY student_teacher_ratio DESC;

