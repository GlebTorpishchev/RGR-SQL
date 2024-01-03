SELECT Subjects.name, Lessons_schedule.date, COUNT(Lessons_schedule.date) FROM Teachers_dirs_subjects 
 join Subjects
on Teachers_dirs_subjects.subject_id = Subjects.id
 join Lessons_schedule
ON Teachers_dirs_subjects.id = Lessons_schedule.subj_teacher_id
 join Attendance
on Lessons_schedule.id = Attendance.schedule_id
WHERE Attendance.presense = 1
GROUP by Lessons_schedule.date, Subjects.name;


SELECT Subjects.name, Lessons_schedule.date, COUNT(Lessons_schedule.date) FROM Teachers_dirs_subjects 
 join Subjects
on Teachers_dirs_subjects.subject_id = Subjects.id
 join Lessons_schedule
ON Teachers_dirs_subjects.id = Lessons_schedule.subj_teacher_id
 join Attendance
on Lessons_schedule.id = Attendance.schedule_id
WHERE Attendance.presense = 0
GROUP by Lessons_schedule.date, Subjects.name;


SELECT teachers.name, Lessons_schedule.date, COUNT(Attendance.student_id) FROM Teachers_dirs_subjects 
left join teachers
on Teachers_dirs_subjects.teacher_id = teachers.id
left join Lessons_schedule
ON Teachers_dirs_subjects.id = Lessons_schedule.subj_teacher_id
left join Attendance
on Lessons_schedule.id = Attendance.schedule_id
WHERE Attendance.presense = 1
GROUP by Lessons_schedule.date, teachers.name;


SELECT Students.name, (COUNT(schedule_id) * 90)/60 FROM Students
JOIN Attendance
on Attendance.student_id = Students.id
WHERE Attendance.presense = 1
GROUP by Students.id; 
