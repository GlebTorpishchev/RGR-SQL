SELECT Groups.name as group, Students.name, Students.budget
from Groups, Students
where Groups.id = Students.group_id
order by Groups.name, Students.name;


SELECT Students.name, Groups.name as group, Directions_of_study.name as direction
from Students
JOIN Groups
on Students.group_id = Groups.id
join Directions_of_study
on Groups.dir_id = Directions_of_study.id
where Students.name LIKE 'К%';


SELECT CONCAT(
          SUBSTRING(Students.name, 1, strpos(Students.name,' ')+1), '.',
          SUBSTRING(SUBSTRING(Students.name, strpos(Students.name,' ')+1),
                    strpos(SUBSTRING(Students.name, strpos(Students.name,' ')+1),' ')+1, 
                    1), '.') as name,
           EXTRACT(DAY FROM Students.birth) as day,
           TO_CHAR(Students.birth, 'Month') as month,
           Groups.name AS group,
           Directions_of_study.name as direction
FROM Students
join Groups ON Groups.id = Students.group_id
JOIN Directions_of_study ON Directions_of_study.id = Groups.dir_id;


SELECT Students.name,
(EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM birth)) AS age
FROM Students
ORDER BY age;


SELECT Students.name,
		EXTRACT(DAY FROM Students.birth) AS day,
		TO_CHAR(Students.birth, 'Month') AS month
FROM Students
WHERE ExTRACT(MONTH FROM Students.birth) = ExTRACT(MONTH FROM CURRENT_DATE);

SELECT Directions_of_study.name, COUNT(Students.id)
FROM Directions_of_study
JOIN Groups ON Groups.dir_id = Directions_of_study.id
JOIN Students ON Students.group_id = Groups.id
GROUP BY Directions_of_study.id;


SELECT Groups.name AS group,
		Directions_of_study.name as direction,
        COUNT(*) AS всего,
		SUM(CASE WHEN Students.budget = 1 THEN 1 END) AS бюджет,
        SUM(CASE WHEN Students.budget = 0 THEN 1 END) AS внебюджет
FROM Students
JOIN Groups ON Groups.id = Students.group_id
JOIN Directions_of_study ON Groups.dir_id = Directions_of_study.id
GROUP BY Groups.name, Directions_of_study.name;
