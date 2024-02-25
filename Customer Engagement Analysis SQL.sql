
-- Retrieving Courses Information

WITH course_student_info AS (
SELECT
	ci.course_id,
    course_title,
    ROUND(SUM(minutes_watched),2) AS total_minutes_watched,
    COUNT(DISTINCT sl.student_id) AS student_count
FROM 365_course_info ci
LEFT JOIN 365_student_learning sl
	ON ci.course_id = sl.course_id
GROUP BY
	ci.course_id
),
course_info_minutes AS (
SELECT
	course_id,
    course_title,
    total_minutes_watched,
    ROUND((total_minutes_watched / student_count ), 2) AS average_minutes
FROM course_student_info
),
course_info_student_ratings AS (
SELECT
	cim.*,
    COUNT(course_rating) AS number_of_ratings,
    COALESCE(SUM(course_rating) / COUNT(course_rating), 0) as average_rating
FROM course_info_minutes cim
LEFT JOIN 365_course_ratings cr
	ON cr.course_id = cim.course_id
GROUP BY course_id
)
SELECT *
FROM course_info_student_ratings;




-- Creating View for Purchases Information

DROP VIEW purchase_info;

CREATE VIEW purchase_info AS
SELECT
	purchase_id,
    student_id,
    purchase_type,
    date_purchased AS date_started,
    CASE
		WHEN purchase_type = 'Monthly' THEN date_purchased + INTERVAL '1' MONTH
        WHEN purchase_type = 'Quarterly' THEN date_purchased + INTERVAL '3' MONTH
        WHEN purchase_type = 'Annual' THEN date_purchased + INTERVAL '12' MONTH
	END AS end_date
FROM 365_student_purchases;
	
SELECT *
FROM purchase_info;

-- Retrieving Student Information

SELECT
	si.student_id,
    student_country,
    date_registered,
    date_watched,
    COALESCE(SUM(minutes_watched),0) AS minutes_watched,
    minutes_watched AS total,
    CASE
		WHEN date_watched IS NULL THEN 0
        ELSE 1
	END AS onboarded,
    CASE
		WHEN pi.student_id IS NULL THEN 0
        ELSE 1
	END AS paid
FROM 365_student_info si
LEFT JOIN 365_student_learning sl
	ON si.student_id = sl.student_id
LEFT JOIN purchase_info pi
	ON si.student_id = pi.student_id AND
    date_watched BETWEEN date_started AND end_date
GROUP BY 
	si.student_id, student_country, date_registered, date_watched, minutes_watched
ORDER BY student_id;365_student_info
    