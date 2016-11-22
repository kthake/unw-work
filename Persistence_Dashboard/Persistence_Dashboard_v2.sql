select count(c.PERSON_UID) "TOTAL", --COMPLETING, PERSISTING, UNREGISTERED
       sum(case when LEVEL_1 = 1 then 1 else 0 end) "COMPLETING",
          sum(case when LEVEL_1 = 1 and LEVEL_2 = 1 then 1 else 0 end) "C_NORMAL",
          sum(case when LEVEL_1 = 1 and LEVEL_2 = 2 then 1 else 0 end) "C_SUMMER_NURSING",
       sum(case when LEVEL_1 = 2 then 1 else 0 end) "PERSISTING",
          sum(case when LEVEL_1 = 2 and LEVEL_2 = 3 then 1 else 0 end) "P_ENGINEERING",
          sum(case when LEVEL_1 = 2 and LEVEL_2 = 4 then 1 else 0 end) "P_OFF_CAMPUS_NOT_UNW",
          sum(case when LEVEL_1 = 2 and LEVEL_2 = 5 then 1 else 0 end) "P_REG_AT_UNW",
              sum(case when LEVEL_1 = 2 and LEVEL_2 = 5 and LEVEL_3 = 1 then 1 else 0 end) "P_REG_AT_UNW_OFF_CAMPUS",
              sum(case when LEVEL_1 = 2 and LEVEL_2 = 5 and LEVEL_3 = 2 then 1 else 0 end) "P_REG_AT_UNW_STANDARD",
       sum(case when LEVEL_1 = 3 then 1 else 0 end) "UNREGISTERED"

from
(
select b.*,
       case when LEVEL_1 = 2 and LEVEL_2 = 5 and OFF_CAMPUS_STUDIES = 2 
            then 1 --off campus studies through UNW
            when LEVEL_1 = 2 and LEVEL_2 = 5 and OFF_CAMPUS_STUDIES is null 
            then 2 --standard registration
            else null
            end "LEVEL_3"
from
(
select a.*,
       case when LEVEL_1 = 1 and ( (PROGRAM <> 'BS-ENDD' and MAJOR <> 'NURS') or (MAJOR = 'NURS' and SUMMER_GRAD_IND = 'N') )
            then 1 --normal grads
            when LEVEL_1 = 1 and MAJOR = 'NURS' and SUMMER_GRAD_IND = 'Y'
            then 2 --summer nursing grads
            when LEVEL_1 = 2 and PROGRAM = 'BS-ENDD' and COMPLETION_IND = 'Y'
            then 3 --UofM engineering students
            when LEVEL_1 = 2 and OFF_CAMPUS_STUDIES = 1
            then 4 --off campus studies not through UNW
            when LEVEL_1 = 2 and (OFF_CAMPUS_STUDIES <> 1 or OFF_CAMPUS_STUDIES is null)
            then 5 --registerd at UNW
            else null --not registered
            end "LEVEL_2"
from
(
select now.PERSON_UID,
       now.ACADEMIC_PERIOD,
       now.PROGRAM,
       now.MAJOR,
       now.COMPLETION_IND,
       case when substr(now.GRAD_ACADEMIC_PERIOD_INTENDED,5,1) = 3 then 'Y' else 'N' end "SUMMER_GRAD_IND",
       nvl2(next.PERSON_UID, 'Y', 'N') "REGISTERED_UPCOMING_IND",
       case when next.FIN_AID_REG_CREDITS > 0 and next.FIN_AID_REG_CREDITS = next.TOTAL_CREDITS
            then 1 --off campus not through UNW
            when next.UNW_OFF_CAMPUS_CREDITS > 0 and next.UNW_OFF_CAMPUS_CREDITS = next.TOTAL_CREDITS
            then 2 --off campus through UNW
            else null end "OFF_CAMPUS_STUDIES",
       case when now.COMPLETION_IND = 'Y' and now.PROGRAM <> 'BS-ENDD' and next.PERSON_UID is null
            then 1 --graduates
            when next.PERSON_UID is not null or (now.COMPLETION_IND = 'Y' and now.PROGRAM = 'BS-ENDD' )
            then 2 --returning students
            else 3 --not registered students
            end "LEVEL_1"
            
from Z_ACADEMIC_STUDY_VW now

     left outer join Z_ACADEMIC_STUDY_VW next
     on next.PERSON_UID = now.PERSON_UID
     and next.ACADEMIC_PERIOD = '201610'
     and next.PRIMARY_PROGRAM_IND = 'Y'
     and next.WITHDRAWN_IND = 'N'
     
where now.ACADEMIC_PERIOD = '201520'
      and now.COLLEGE = 'TR'
      and now.PRIMARY_PROGRAM_IND = 'Y'
      and now.WITHDRAWN_IND = 'N'
) a
) b
) c