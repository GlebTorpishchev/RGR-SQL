SELECT Groups.name as 'group', Students.name, Students.budget
from Groups, Students
where Groups.id = Students.group_id
order by Groups.name, Students.name;


SELECT Students.name, Groups.name as 'group', directions.name as 'direction'
from Students
JOIN Groups
on Students.group_id = Groups.id
join directions
on Groups.dir_id = directions.id
where Students.name LIKE 'К%'


SELECT CONCAT(
          SUBSTRING(Students.name, 1, INSTR(Students.name,' ')+1), '.',
          SUBSTRING(SUBSTRING(Students.name, INSTR(Students.name,' ')+1),
                    INSTR(SUBSTRING(Students.name, INSTR(Students.name,' ')+1),' ')+1, 
                    1), '.') as 'name',
           DAY(Students.birth) as 'day',
           MONTHNAME(Students.birth) as 'month',
           Groups.name AS 'group',
           directions.name as 'direction'
FROM Students
join Groups ON Groups.id = Students.group_id
JOIN directions ON directions.id = Groups.dir_id


SELECT Students.name,
(YEAR(CURRENT_DATE)-YEAR(birth))-(RIGHT(CURRENT_DATE,5)<RIGHT(birth,5)) AS 'age'
FROM Students
ORDER BY age


SELECT Students.name,
		DAY(Students.birth) AS 'day',
		MONTHNAME(Students.birth) AS 'month'
FROM Students
WHERE MONTH(Students.birth) = MONTH(CURRENT_DATE)


SELECT directions.name, COUNT(Students.id)
FROM directions
JOIN Groups ON Groups.dir_id = directions.id
JOIN Students ON Students.group_id = Groups.id
GROUP BY directions.id


SELECT Groups.name AS 'group',
		directions.name as 'direction',
        COUNT(*) AS 'всего',
		SUM(Students.budget = true) AS 'бюджет',
        SUM(Students.budget = false) AS 'внебюджет'
FROM Students
JOIN Groups ON Groups.id = Students.group_id
JOIN directions ON Groups.dir_id = directions.id
GROUP BY group_id
