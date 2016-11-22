SELECT s.PERSON_UID,
       mt.START_DATE,
       mt.END_DATE,
       mt.COURSE_REFERENCE_NUMBER,
       sc.COURSE_IDENTIFICATION,
       sc.COURSE_TITLE_SHORT,
       TO_CHAR(e.EVENT_DATE, 'D') "DAY_OF_WEEK",
       e.EVENT_DATE,
       MONDAY,
       BEGIN_TIME,
       END_TIME,
       DISMISSAL_TIME
       
FROM ODSMGR.MST_SPORT s

     left outer join ODSMGR.MST_STUDENT_COURSE sc
     on sc.PERSON_UID = s.PERSON_UID
     and substr(sc.ACADEMIC_PERIOD,1,5) = substr(s.ACADEMIC_PERIOD,1,5)
     and sc.REGISTRATION_STATUS in ('RE','RW','AU')
     
        inner join (
        select COURSE_REFERENCE_NUMBER,
               SECTION,
               ACADEMIC_PERIOD,  
               nvl2(SUNDAY_IND, '1',null) "SUNDAY",
               nvl2(MONDAY_IND, '2',null) "MONDAY",
               nvl2(TUESDAY_IND, '3',null) "TUESDAY",
               nvl2(WEDNESDAY_IND, '4',null) "WEDNESDAY",
               nvl2(THURSDAY_IND, '5',null) "THURSDAY",
               nvl2(FRIDAY_IND, '6',null) "FRIDAY",
               nvl2(SATURDAY_IND, '7',null) "SATURDAY",
               START_DATE,
               END_DATE,
               BEGIN_TIME,
               END_TIME
        from ODSMGR.MST_MEETING_TIME
        where BEGIN_TIME is not null
        and END_TIME is not null
        ) mt
        on mt.COURSE_REFERENCE_NUMBER = sc.COURSE_REFERENCE_NUMBER
        and mt.ACADEMIC_PERIOD = sc.ACADEMIC_PERIOD
        and mt.SECTION = sc.COURSE_SECTION_NUMBER
        
     left outer join ODSMGR.Z_SPORT_EVENT_TBL e
     on e.SPORT = s.ACTIVITY
     and e.ACADEMIC_PERIOD = s.ACADEMIC_PERIOD

WHERE S.ACADEMIC_PERIOD = '201510'
      and e.EVENT_DATE between mt.START_DATE and mt.END_DATE
      and to_char(e.EVENT_DATE, 'D') in (SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY)
      and to_date(e.DISMISSAL_TIME, 'HH24MI') between to_date(mt.BEGIN_TIME, 'HH24MI') and to_date(mt.END_TIME, 'HH24MI')