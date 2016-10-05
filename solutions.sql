---1---
SELECT t.tt_id, t.TT_NAME, COUNT(DISTINCT e.ED_STUDENT) as students_count 
FROM TUTORS t LEFT JOIN  EDUCATION e ON t.TT_ID=e.ED_TUTOR 
GROUP BY t.tt_name, t.TT_ID;

---2---
SELECT STUDENTS.ST_ID, STUDENTS.ST_NAME, COUNT (DISTINCT EDUCATION.ED_TUTOR) as tutors_count 
FROM STUDENTS JOIN EDUCATION ON STUDENTS.ST_ID=EDUCATION.ED_STUDENT 
GROUP BY STUDENTS.ST_NAME, STUDENTS.ST_ID ORDER BY STUDENTS.ST_ID ASC;

---3---
SELECT * FROM 
	(
		SELECT TUTORS.TT_ID, TUTORS.TT_NAME, COUNT(EDUCATION.ed_subject) AS classes_count
		FROM TUTORS JOIN EDUCATION
			ON EDUCATION.ED_TUTOR=TUTORS.TT_ID
			WHERE EDUCATION.ED_DATE BETWEEN TO_DATE('2012-09-01', 'yyyy/mm/dd') AND TO_DATE('2012-09-30', 'yyyy/mm/dd') 
			GROUP BY TUTORS.TT_ID, TUTORS.TT_NAME
			ORDER BY classes_count DESC
	)
WHERE ROWNUM <= 1;

---4---
SELECT STUDENTS.ST_ID, STUDENTS.ST_NAME, AVG(EDUCATION.ED_MARK)
FROM STUDENTS LEFT JOIN EDUCATION ON STUDENTS.ST_ID=EDUCATION.ED_STUDENT
GROUP BY STUDENTS.ST_ID, STUDENTS.ST_NAME
ORDER BY STUDENTS.ST_ID;

---5---
SELECT st_id, st_name, LISTAGG(sb_name, ',  ') WITHIN GROUP (ORDER BY sb_name DESC), mark_max
  FROM (
    SELECT DISTINCT st_id, st_name, subjects.sb_name, mark_max
      FROM (
        SELECT students.st_id, students.st_name, MAX(education.ed_mark) AS mark_max
          FROM students
            LEFT JOIN education ON students.st_id = education.ed_student
          GROUP BY students.st_id, students.st_name
      ) T
        LEFT JOIN education ON T.st_id = education.ed_student
        LEFT JOIN subjects ON education.ed_subject = subjects.sb_id
      WHERE mark_max = education.ed_mark
        OR mark_max IS NULL
  )
  GROUP BY st_id, st_name, mark_max
  ORDER BY st_id;

---6---
SELECT name FROM
  (
  SELECT TUTORS.TT_NAME as name, MIN(EDUCATION.ED_MARK) as mark
  FROM STUDENTS 
  JOIN EDUCATION ON EDUCATION.ED_STUDENT=STUDENTS.ST_ID
  JOIN TUTORS ON EDUCATION.ED_TUTOR=TUTORS.TT_ID
  WHERE STUDENTS.ST_NAME='Соколов С.С.'
  GROUP BY TUTORS.TT_NAME
  )
WHERE mark is not NULL;

SELECT tt_name FROM education 
JOIN tutors ON tutors.tt_id = education.ed_tutor 
JOIN students ON students.st_id = education.ed_student
WHERE students.st_name = 'Соколов С.С.'
      AND education.ed_mark = (SELECT MIN(ed_mark) FROM education);

---7---
SELECT 
CASE
  COUNT(*) WHEN NULL THEN '0'
  ELSE '1'
END AS answer
FROM EDUCATION
WHERE ED_MARK IS NOT NULL AND ED_CLASS_TYPE NOT IN (2,3);

--OR
SELECT 
CASE
  COUNT(*) WHEN NULL THEN '0'
  ELSE '1'
END AS answer
FROM EDUCATION JOIN CLASS_TYPES ON EDUCATION.ED_CLASS_TYPE=CLASS_TYPES.CT_ID
WHERE ED_MARK IS NOT NULL AND CLASS_TYPES.CT_NAME NOT IN ('Экзамен','Лабораторная работа');

---8---
SELECT SB_CL_MAX.YEAR || SB_CL_MAX.MONTH as short_date, LISTAGG(SB_NAME, '; ') WITHIN GROUP (ORDER BY SB_NAME) SN_NAME, MAX(SB_CL_MAX.MAX_CLASSES)
  FROM (
    SELECT YEAR, MONTH, MAX(CLASSES) MAX_CLASSES
      FROM (
        SELECT EXTRACT(YEAR FROM ED_DATE) YEAR, EXTRACT(MONTH FROM ED_DATE) MONTH, SUBJECTS.SB_NAME, COUNT(ED_ID) CLASSES
          FROM EDUCATION
            JOIN SUBJECTS ON EDUCATION.ED_SUBJECT = SUBJECTS.SB_ID
          WHERE EXTRACT(YEAR FROM ED_DATE) = 2012
          GROUP BY EXTRACT(YEAR FROM ED_DATE), EXTRACT(MONTH FROM ED_DATE), SUBJECTS.SB_NAME
      )
      GROUP BY YEAR, MONTH
  ) SB_CL_MAX
    LEFT JOIN (
      SELECT EXTRACT(YEAR FROM ED_DATE) YEAR, EXTRACT(MONTH FROM ED_DATE) MONTH, SUBJECTS.SB_NAME, COUNT(ED_ID) CLASSES
        FROM EDUCATION
          JOIN SUBJECTS ON EDUCATION.ED_SUBJECT = SUBJECTS.SB_ID
        WHERE EXTRACT(YEAR FROM ED_DATE) = 2012
        GROUP BY EXTRACT(YEAR FROM ED_DATE), EXTRACT(MONTH FROM ED_DATE), SUBJECTS.SB_NAME
    ) SB_CL ON
      SB_CL_MAX.YEAR = SB_CL.YEAR 
      AND SB_CL_MAX.MONTH = SB_CL.MONTH
      AND SB_CL_MAX.MAX_CLASSES = SB_CL.CLASSES
  GROUP BY SB_CL_MAX.YEAR, SB_CL_MAX.MONTH
  ORDER BY SB_CL_MAX.MONTH DESC;

---9---
SELECT st_id, st_name, avg_mark FROM (
  SELECT STUDENTS.st_id, STUDENTS.st_name, AVG(EDUCATION.ed_mark) AS avg_mark
  FROM STUDENTS JOIN EDUCATION ON students.ST_ID=EDUCATION.ED_STUDENT
  GROUP BY STUDENTS.st_id, STUDENTS.st_name
  ORDER BY STUDENTS.st_id ASC)
WHERE avg_mark<(SELECT AVG(EDUCATION.ed_mark) FROM EDUCATION);

--OR
select students.ST_ID, students.st_name, AVG(education.ed_mark) as avg
from students 
  join education on students.ST_ID=education.ED_STUDENT
group by students.ST_NAME, students.ST_ID
having avg(education.ed_mark) < (select avg(education.ED_MARK) from education)
order by students.ST_ID;

---10---
SELECT STUDENTS.st_ID, STUDENTS.ST_name
FROM STUDENTS 
LEFT JOIN (
  SELECT EDUCATION.ED_STUDENT as st FROM EDUCATION WHERE EDUCATION.ED_CLASS_TYPE = 1 AND EDUCATION.ED_SUBJECT IN (2,3)
  ) ON STUDENTS.ST_ID = st
WHERE st IS NULL;

SELECT DISTINCT EDUCATION.ED_STUDENT as st 
FROM EDUCATION 
WHERE EDUCATION.ED_CLASS_TYPE = 1 AND (EDUCATION.ED_SUBJECT=2 OR EDUCATION.ED_SUBJECT=3);

---11---
SELECT STUDENTS.st_id, STUDENTS.st_name
FROM STUDENTS 
LEFT JOIN (
  SELECT DISTINCT EDUCATION.ED_STUDENT AS st FROM EDUCATION WHERE ED_MARK = 10 
) ON STUDENTS.ST_ID=st WHERE st IS NULL
ORDER BY STUDENTS.ST_ID ASC;

---12---
SELECT SUBJECTS.SB_ID, SUBJECTS.SB_NAME, AVG(EDUCATION.ED_MARK) AS A
    FROM EDUCATION 
      JOIN SUBJECTS 
          ON EDUCATION.ED_SUBJECT = SUBJECTS.SB_ID
    GROUP BY SUBJECTS.SB_ID, SUBJECTS.SB_NAME
HAVING AVG(EDUCATION.ED_MARK) > (SELECT AVG(EDUCATION.ED_MARK) FROM EDUCATION)
ORDER BY SUBJECTS.SB_ID ASC;

--13--
SELECT sb_id, sb_name, ROUND(COUNT(ed_subject) / MONTHS_BETWEEN(MAX(ed_date), MIN(ed_date)), 4) FROM education 
JOIN subjects ON sb_id = ed_subject
GROUP BY sb_id, sb_name
ORDER BY sb_id;

--14--
SELECT
  students.st_id, students.st_name, subjects.sb_id, subjects.sb_name, ed.ed_mark as avg
FROM students
INNER JOIN
  (SELECT education.ed_student, education.ed_subject, AVG(education.ed_mark) as ed_mark
  FROM education
  WHERE CONCAT(education.ed_student, education.ed_subject) NOT IN
    (
   	SELECT DISTINCT CONCAT (education.ed_student, education.ed_subject)
    FROM education
    WHERE education.ed_class_type = 2
    ) 
  GROUP BY
    education.ed_student,
    education.ed_subject
  ) ed
ON
  ed.ed_student = students.st_id
LEFT JOIN subjects
ON subjects.sb_id = ed.ed_subject
ORDER BY  ed.ed_mark asc;

--15--
select t.tt_id, t.tt_name, count(e.ed_subject)
from tutors t left join EDUCATION e on e.ED_TUTOR=t.TT_ID
group by t.tt_id, t.tt_name
order by t.TT_ID;

--16--
select tt.tt_id, tt.tt_name 
from tutors tt
minus 
(
    select tt.tt_id, tt.tt_name 
    from tutors tt
      left join education e 
      on tt.TT_ID=e.ED_TUTOR
      where e.ED_MARK is not null
);

--17--
select t.tt_id, t.tt_name, count(e.ed_mark) as marks
  from TUTORS t 
  left join EDUCATION e
  on e.ED_TUTOR=t.TT_ID
  GROUP by t.TT_ID, t.TT_NAME
  order by marks desc;

 --18--
select sb.sb_name, st.st_name, avg(e.ed_mark) as mark
  from EDUCATION e
  join students st on e.ed_student=st.st_id
  join  subjects sb on e.ed_subject=sb.sb_id
  group by sb.sb_name, st.st_name
  order by sb.sb_name asc, st.st_name asc,  mark desc;

 --19--
select st.st_name, TO_CHAR(e.ed_date, 'YYYYMM') as short_date, avg(e.ed_mark) as mark
  from EDUCATION e 
  join STUDENTS st on e.ED_STUDENT=st.ST_ID
  group by st.st_name, TO_CHAR(e.ed_date, 'YYYYMM')
  order by st.ST_NAME asc,  short_date desc;

--20--
select st.st_name, max(e.ed_mark) as mark
	from education e
	join students st on e.ED_STUDENT=st.ST_ID
	group by st.ST_NAME
	order by mark desc;

--21--
select st.st_name, count(e.ed_mark) as bad_marks
  from students st
  join education e on e.ED_STUDENT = st.ST_ID
  where e.ed_mark < 5 
  group by st.st_name
  having count(e.ed_mark)=
  (
    select bad_marks from 
    (
      select count(e.ed_mark) as bad_marks
        from students st
        join education e on e.ED_STUDENT = st.ST_ID
        where e.ed_mark < 5 
        group by st.st_name
        order by bad_marks desc
    )
    where rownum=1
  );

--22--
select st.st_name, count(e.ed_student) as classes
  from students st
  join education e on e.ED_STUDENT = st.ST_ID
  group by st.st_name
  having count(e.ed_student)=
  (
    select classes from 
    (
      select count(e.ed_student) as classes
        from students st
        join education e on e.ED_STUDENT = st.ST_ID
        group by st.st_name
        order by classes desc
    )
    where rownum=1
  );

 ---23---
SELECT TUTORS.TT_ID, TUTORS.TT_NAME, COUNT(EDUCATION.ED_SUBJECT) AS CLASSES
  FROM TUTORS
  LEFT JOIN EDUCATION ON TUTORS.TT_ID=EDUCATION.ED_TUTOR
  LEFT JOIN CLASS_TYPES ON CLASS_TYPES.CT_ID=EDUCATION.ED_CLASS_TYPE
GROUP BY TUTORS.TT_ID, TUTORS.TT_NAME
ORDER BY TUTORS.TT_ID ASC;

--24--
SELECT temp.st_name, temp.classes  
FROM 
	(
	SELECT students.st_name, ed.classes
  FROM
    (
    SELECT education.ed_student, COUNT(*) as classes
    FROM education
    GROUP BY education.ed_student
    ) ed
  LEFT JOIN students
  ON students.st_id = ed.ed_student
  ORDER BY
    ed.classes desc
  ) temp
WHERE ROWNUM <= 1;

--25--
SELECT   tutors.tt_name, subjects.sb_name, students.st_name, ed.max
FROM 
	(
	SELECT education.ed_tutor, education.ed_subject, education.ed_student, MAX(education.ed_mark) AS max
  FROM education
  WHERE education.ed_mark IS NOT NULL
  GROUP BY education.ed_tutor, education.ed_subject, education.ed_student 
  ) ed
LEFT JOIN tutors
ON ed.ed_tutor = tutors.tt_id
LEFT JOIN subjects
ON ed.ed_subject = subjects.sb_id
LEFT JOIN students
ON ed.ed_student = students.st_id
ORDER BY tutors.tt_id, subjects.sb_id,  students.st_id
;

--26--
select st.st_name, sum(e.ed_mark)
  from education e 
  join students st on st.st_id=e.ED_STUDENT
  group by st.st_name
  having sum(e.ed_mark)=
  (
    select min(mark) from 
    (
      select sum(e2.ed_mark) as mark from education e2 group by e2.ed_student
    )
  );

--27--
select sb.sb_name
  from subjects sb
minus 
  select sb1.sb_name 
    from subjects sb1
  join education e on sb1.sb_id=e.ED_SUBJECT;

--28--
select e.ed_id, e.ed_student, e.ed_tutor, e.ed_subject, e.ed_class_type, e.ed_mark, e.ed_date
from education e
where e.ED_CLASS_TYPE=3 and e.ED_SUBJECT=2 and e.ED_MARK is null;

--29--
select sb.sb_name, count(e.ed_class_type)
  from education e
    join subjects sb on e.ED_SUBJECT=sb.SB_ID
  where to_char(e.ED_DATE,'YYYY')='2012' and e.ED_CLASS_TYPE=2
  group by sb.sb_name
having count(e.ed_class_type)=
(
  select max(cnt) from 
  (
      select count(e.ed_class_type) as cnt
    from education e
      join subjects sb on e.ED_SUBJECT=sb.SB_ID
    where to_char(e.ED_DATE,'YYYY')='2012' and e.ED_CLASS_TYPE=2
    group by e.ED_SUBJECT
  )
);

--30--
select sb.sb_id, sb.sb_name,  count(e1.ed_class_type)/
(
  select (y_max-y_min)*12+m_max+m_min+1 from 
  (
    select 
      max(to_char(e.ed_date,'YYYY')) as y_max, 
      min(to_char(e.ed_date,'YYYY')) as y_min, 
      max(to_char(e.ed_date,'MM')) as m_max, 
      min(to_char(e.ed_date,'MM')) as m_min
    from education e where e.ED_SUBJECT=1
  )
) as exams_per_month
from education e1
join subjects sb on sb.SB_ID=e1.ed_subject
where sb.SB_ID=1
group by sb.sb_id, sb.sb_name;

