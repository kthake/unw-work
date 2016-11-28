select  count(distinct z.PERSON_UID) "TOTAL",
        count(distinct z1.PERSON_UID) "RETURNED",
        count(distinct case when z.COMPLETION_IND = 'Y' and z1.PERSON_UID is null
                            then null
                            when z.STUDENT_TYPE = 'O' or z.PROGRAM = 'ADDTL'
                            then null
                            else z.PERSON_UID
                       end) "RETURNABLE",
        count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 10
                            then r.PERSON_UID
                       end) * 0.1 "RED",                   
        count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 50
                            then r.PERSON_UID
                       end) * 0.5 "YELLOW",
        count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 90
                            then r.PERSON_UID
                       end) * 0.9 "GREEN"
                       
from ODSMGR.Z_ACADEMIC_STUDY_VW z

      left outer join ODSMGR.Z_ACADEMIC_STUDY_VW z1
      on z1.PERSON_UID = z.PERSON_UID
      and z1.ACADEMIC_PERIOD_MOD = '20162'
      and z1.PRIMARY_PROGRAM_IND = 'Y'
      
      left outer join NWC.Z_RETENTION_IND_TBL r
      on r.PERSON_UID = z.PERSON_UID
      and substr(r.ACADEMIC_PERIOD,1,5) = '20162'
      
where z.ACADEMIC_PERIOD_MOD = '20161'
      and z.COLLEGE = 'TR'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      
 