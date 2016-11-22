with mt1 as (
SELECT START_DATE,
       END_DATE,
       mt.END_DATE - mt.START_DATE "DIFF",
--       nvl2(mt.SUNDAY_IND, '1',null) "SUNDAY",
--       nvl2(mt.MONDAY_IND, '2',null) "MONDAY",
--       nvl2(mt.TUESDAY_IND, '3',null) "TUESDAY",
--       nvl2(mt.WEDNESDAY_IND, '4',null) "WESNESDAY",
--       nvl2(mt.THURSDAY_IND, '5',null) "THURSDAY",
--       nvl2(mt.FRIDAY_IND, '6',null) "FRIDAY",
--       nvl2(mt.SATURDAY_IND, '7',null) "SATURDAY",
       mt.COURSE_REFERENCE_NUMBER
FROM ODSMGR.MEETING_TIME mt
WHERE mt.COURSE_REFERENCE_NUMBER = 11166
      AND mt.ACADEMIC_PERIOD = '201510'
      )

select s.PERSON_UID,
       s.ID,
       s.NAME,
       s.ACADEMIC_PERIOD,
       s.ACTIVITY,
       s.ACTIVITY_DESC,
       s.SPORT_STATUS,
       sc.COURSE_IDENTIFICATION,
       sc.COURSE_TITLE_SHORT,
       sc.COURSE_REFERENCE_NUMBER,
       mt0.START_DATE,
       mt0.END_DATE,
       mt0.BEGIN_TIME,
       mt0.END_TIME,
       e.EVENT_DATE
       --mt.MONDAY_IND||mt.TUESDAY_IND||mt.WEDNESDAY_IND||mt.THURSDAY_IND||mt.FRIDAY_IND||mt.SATURDAY_IND||mt.SUNDAY_IND "MEETING_DAYS"
       
from ODSMGR.SPORT s

     left outer join ODSMGR.STUDENT_COURSE sc
     on sc.PERSON_UID = s.PERSON_UID
     and substr(sc.ACADEMIC_PERIOD,1,5) = substr(s.ACADEMIC_PERIOD,1,5)
     and sc.REGISTRATION_STATUS in ('RE','RW','AU')
     
        inner join ODSMGR.MEETING_TIME mt0
        on mt0.COURSE_REFERENCE_NUMBER = sc.COURSE_REFERENCE_NUMBER
        and mt0.ACADEMIC_PERIOD = sc.ACADEMIC_PERIOD
        and mt0.SECTION = sc.COURSE_SECTION_NUMBER
        and mt0.BEGIN_TIME is not null
        and mt0.END_TIME is not null
        
    left outer join ODSMGR.Z_SPORT_EVENT_TBL e
    on e.SPORT = s.ACTIVITY
     
where s.ACADEMIC_PERIOD = '201510'
      and s.PERSON_UID = 157302 --TESTING
         and (e.EVENT_DATE, to_char(e.EVENT_DATE,'D')) in
         ( select  START_DATE + level -1 "DATES",
                   TO_CHAR(START_DATE + level -1, 'D') "DAY_OF_WEEK"
           from mt1
           where mt1.COURSE_REFERENCE_NUMBER = mt0.COURSE_REFERENCE_NUMBER
           connect by level <= mt1.diff
           )
           
           
           
      --and s.ACTIVITY = 
      --and s.SPORTS_STATUS = 'AC'