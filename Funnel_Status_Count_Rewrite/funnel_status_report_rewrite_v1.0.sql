select aa.PERSON_UID,
       aa.ID,
       aa.NAME,
       aa.STUDENT_POPULATION_DESC,
       trunc(ADMISSIONS_APPLICATION.APPLICATION_DATE) "APPLICATION_DATE",
       aa.LATEST_DECISION_DESC "LATEST_DECISION",
       aa.ACADEMIC_PERIOD_DESC "ACADEMIC_PERIOD",
       aa.ACADEMIC_YEAR_DESC "ACADEMIC_YEAR",
       aa.PRIMARY_SOURCE_DESC "PRIMARY_SOURCE",
       nvl(p.GENDER_DESC, ' ') "GENDER",
       --ADMINISTRATOR.ADMINISTRATOR_FIRST_NAME||' '||ADMINISTRATOR.ADMINISTRATOR_LAST_NAME "Recruiter",
       aa.PROGRAM_DESC "PROGRAM",
       
       
       
from ODSMGR.ADMISSIONS_APPLICATION aa

     left outer join ODSMGR.Z_PERSON_NAME_VW p
     on p.PERSON_UID = aa.PERSON_UID 
     /*
     left outer join (
     select VALUE "DECISION_CODE",
            case when VALUE = '03' then '2 - PreApply'
                 when VALUE in ('05','07','09','17','18') then '3 - Applicant'
                 when VALUE = '25' then '4 - Admit'
                 when VALUE in ('35','36') then '5 - Confirmed'
                 when VALUE = '80' then '6 - Registered'
                 when VALUE in ('20','50','51','56','57','58','90','91','92','93','94','97') then '8 - Inactive Applicant/Admit'
                 else ''
            end "FUNNEL_STATUS"
      from ODSMGR.VALIDATION
      where TABLE_NAME = 'STVAPDC'
      ) v
      on aa.LATEST_DECISION = v.DECISION_CODE
     */
     
     