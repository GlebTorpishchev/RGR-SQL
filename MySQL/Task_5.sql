SELECT Students.name, Subjects.name AS 'subject', Groups.name AS 'group', Teachers.name AS 'teacher'
FROM Teachers_dirs_subjects
JOIN Subjects ON Subjects.id = Teachers_dirs_subjects.subject_id
JOIN Directions_of_study ON Directions_of_study.id = Teachers_dirs_subjects.direction_id
JOIN Teachers ON Teachers.id = Teachers_dirs_subjects.teacher_id
JOIN Groups ON Groups.dir_id = Directions_of_study.id
JOIN Students ON Students.group_id = Groups.id
ORDER BY Groups.name;


SELECT Subjects.name AS 'subject',COUNT(*) AS cnt
FROM Teachers_dirs_subjects
JOIN Subjects ON Subjects.id = Teachers_dirs_subjects.subject_id
JOIN Directions_of_study ON Directions_of_study.id = Teachers_dirs_subjects.direction_id
JOIN Groups ON Groups.dir_id = Directions_of_study.id
JOIN Students ON Students.group_id = Groups.id
GROUP BY Subjects.id
ORDER BY cnt DESC;


SELECT Teachers.name AS 'subject',COUNT(*) AS cnt
FROM Teachers_dirs_subjects
JOIN Teachers ON Teachers.id = Teachers_dirs_subjects.teacher_id
JOIN Directions_of_study ON Directions_of_study.id = Teachers_dirs_subjects.direction_id
JOIN Groups ON Groups.dir_id = Directions_of_study.id
JOIN Students ON Students.group_id = Groups.id
GROUP BY Teachers.id
ORDER BY cnt DESC;


SELECT Subjects.name, (SUM(Marks.mark>2) *100.0 / COUNT(*)) as 'piece' FROM Subjects
JOIN Teachers_dirs_subjects ON Teachers_dirs_subjects.subject_id = Subjects.id
JOIN Marks ON Marks.student_id = Teachers_dirs_subjects.id
GROUP BY Subjects.name;


SELECT Subjects.name, AVG(Marks.mark) as 'avg' FROM Subjects
JOIN Teachers_dirs_subjects ON Teachers_dirs_subjects.subject_id = Subjects.id
JOIN Marks ON Marks.student_id = Teachers_dirs_subjects.id
WHERE Marks.mark > 2
GROUP BY Subjects.name;

SELECT Groups.name AS 'group', AVG(Marks.mark) as 'avg' FROM Groups
JOIN Students ON Students.group_id = Groups.id
JOIN Marks ON Marks.student_id = Students.id
GROUP BY Groups.name
ORDER BY AVG(Marks.mark) DESC


SELECT Students.name, AVG(Marks.mark)
FROM Students
JOIN Marks ON Marks.student_id = Students.id
GROUP BY Students.name
HAVING AVG(Marks.mark) = 5.0


SELECT Students.name
FROM Students
JOIN Marks ON Marks.student_id = Students.id
WHERE Marks.mark = 2
GROUP BY Students.name
HAVING COUNT(*)>1
