select  aa.PERSON_UID,
        aa.ID,
        aa.NAME,
        aa.STUDENT_POPULATION_DESC,
        trunc(aa.APPLICATION_DATE) "APPLICATION_DATE",
        aa.LATEST_DECISION_DESC "LATEST_DECISION",
        aa.ACADEMIC_PERIOD_DESC "ACADEMIC_PERIOD",
        aa.ACADEMIC_YEAR_DESC "ACADEMIC_YEAR",
        aa.PRIMARY_SOURCE_DESC "PRIMARY_SOURCE",
        nvl(ps.GENDER_DESC, ' ') "GENDER",
        --RECRUITER
        aa.PROGRAM_DESC "PROGRAM",
        case when aa.LATEST_DECISION = '03'
             then '2 - PreApply'
             when aa.LATEST_DECISION in ('05','07','09','17','18') 
             then '3 - Applicant'
             when aa.LATEST_DECISION = '25'
             then '4 - Admit'
             when aa.LATEST_DECISION in ('35','36') 
             then '5 - Confirmed'
             when aa.LATEST_DECISION = '80'
             then '6 - Registered'
             when aa.LATEST_DECISION  in ('20','50','51','56','57','58','90','91','92','93','94','97') 
             then '8 - Inactive Applicant/Admit'
             when aa.LATEST_DECISION = '81'
             then 'AA Completion after HS'
        end "FUNNEL_STATUS",
        aa.MAJOR_DESC "MAJOR", 
        aa.WITHDRAWAL_REASON_DESC "WITHDRAW_REASON",
        aa.INSTITUTION_ATTENDING_DESC "WITHDRAW_INSTITUTION",
        s.SECOND_SOURCE "SECONDARY_SOURCE",
        s.THIRD_SOURCE,
        aa.DEPARTMENT,
        ac.STATE_PROVINCE "STATE",
        substr(ac.POSTAL_CODE,1,5) "ZIP",
        trunc(aa.LATEST_DECISION_DATE) "LATEST_DECISION_DATE",
        ri.DATE_ADDED "ORIGINAL_INQUIRY_DATE",
        extract(year from ri.DATE_ADDED) "ORIGINAL_INQUIRY_YEAR",
        extract(month from ri.DATE_ADDED) "ORIGINAL_INQUIRY_MONTH",
        nvl(NWC.Z_GET_CONCAT_ADDR_UNWSP_PKG.Z_GET_CURR_ADDR_OF_TYPE_FNC(aa.PERSON_UID,'PR'),' ') "ADDRESS",
        ODSMGR.Z_GET_EMAIL_FNC(aa.PERSON_UID,'PR') "EMAIL",
        ODSMGR.Z_GET_EMAIL_FNC(aa.PERSON_UID,'PA') "PARENT_EMAIL",
        coalesce(NWC.Z_GET_CURRENT_PHONE_FNC(aa.PERSON_UID, 'MOBL'),
                 NWC.Z_GET_CURRENT_PHONE_FNC(aa.PERSON_UID, 'PR'),
                ' ') "PHONE",
        rec.RECRUITER_NAME
        
from ODSMGR.ADMISSIONS_APPLICATION aa

      left outer join ODSMGR.PERSON_SENSITIVE ps
      on ps.PERSON_UID = aa.PERSON_UID
      
      --get source information. I pivot to make two columns for the sources
      left outer join 
      ( select *
        from 
        ( select PERSON_UID, ACADEMIC_PERIOD, APPLICATION_NUMBER, substr(INSTITUTION,1,1) "SUB_INST", INSTITUTION_DESC
          from ODSMGR.ADMISSIONS_SOURCE
          where substr(INSTITUTION,1,1) in ('2','3') )
        pivot ( max(INSTITUTION_DESC) for SUB_INST in ('2' as SECOND_SOURCE, '3' as THIRD_SOURCE ) ) ) s
      on s.PERSON_UID = aa.PERSON_UID
      and s.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD
      and s.APPLICATION_NUMBER = aa.APPLICATION_NUMBER
        
      left outer join ODSMGR.ADDRESS_CURRENT ac
      on ac.ENTITY_UID = aa.PERSON_UID 
      and ac.ADDRESS_TYPE = 'PR'
      
      left outer join ODSMGR.RECRUITMENT_INFORMATION ri
      on ri.PERSON_UID = aa.PERSON_UID
      and ri.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD
      and ri.COLLEGE = aa.COLLEGE
      and ri.CURRICULUM_PRIORITY_NUMBER = '1'
      
      --get recruiter information
      left outer join
      ( select distinct
                adm.PERSON_UID,
                adm.ACADEMIC_PERIOD,
                adm.ADMINISTRATOR_UID "RECRUITER_UID",
                NWC.Z_FORMAT_NAME_FNC(adm.ADMINISTRATOR_UID,'FL') "RECRUITER_NAME"
        from ODSMGR.ADMINISTRATOR adm
              inner join ODSMGR.Z_RECR_XWALK_VW xw
              on xw.RECRUITER_PIDM = adm.ADMINISTRATOR_UID
              and xw.RECRUITER_VENUE = 'TR'
              
         where adm.APPLICATION_RECRUIT_NUMBER =
                (select max(R.RECRUIT_NUMBER)
                  from ODSMGR.RECRUITMENT_INFORMATION R
                  where R.PERSON_UID = adm.PERSON_UID) ) rec
      on rec.PERSON_UID = aa.PERSON_UID
      and rec.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD

where aa.ACADEMIC_PERIOD = '201610'

union all

select  ri.PERSON_UID,
        ri.ID,
        ri.NAME,
        ri.STUDENT_POPULATION_DESC,
        ri.DATE_ADDED,
        ri.RECRUIT_TYPE_DESC,
        ri.ACADEMIC_PERIOD_DESC,
        ri.ACADEMIC_YEAR_DESC,
        ri.PRIMARY_SOURCE_DESC,
        nvl(ps.GENDER_DESC,' '),
        ri.PROGRAM_DESC,
        decode(ri.RECRUIT_TYPE,'IQ','1 - Inquiry',
                               'SU','9 - Name Purchase',
                                    '7 - Inactive Inquiry' ),
        ri.MAJOR_DESC,
        'N/A',
        'N/A',
        'N/A',
        'N/A',
        ri.DEPARTMENT_DESC,
        ac.STATE_PROVINCE "STATE",
        substr(ac.POSTAL_CODE,1,5) "ZIP",
        ri.DATE_ADDED,
        ri.DATE_ADDED,
        extract(year from ri.DATE_ADDED),
        extract(month from ri.DATE_ADDED),
        nvl(NWC.Z_GET_CONCAT_ADDR_UNWSP_PKG.Z_GET_CURR_ADDR_OF_TYPE_FNC(ri.PERSON_UID,'PR'),' ') "ADDRESS",
        ODSMGR.Z_GET_EMAIL_FNC(ri.PERSON_UID,'PR') "EMAIL",
        ODSMGR.Z_GET_EMAIL_FNC(ri.PERSON_UID,'PA') "PARENT_EMAIL",
        coalesce(NWC.Z_GET_CURRENT_PHONE_FNC(ri.PERSON_UID, 'MOBL'),
                 NWC.Z_GET_CURRENT_PHONE_FNC(ri.PERSON_UID, 'PR'),
                ' ') "PHONE",
        rec.RECRUITER_NAME
from ODSMGR.RECRUITMENT_INFORMATION ri

      left outer join ODSMGR.PERSON_SENSITIVE ps
      on ps.PERSON_UID = ri.PERSON_UID
      
      left outer join ODSMGR.ADDRESS_CURRENT ac
      on ac.ENTITY_UID = ri.PERSON_UID 
      and ac.ADDRESS_TYPE = 'PR'
      
      left outer join
      ( select distinct
                adm.PERSON_UID,
                adm.ACADEMIC_PERIOD,
                adm.ADMINISTRATOR_UID "RECRUITER_UID",
                NWC.Z_FORMAT_NAME_FNC(adm.ADMINISTRATOR_UID,'FL') "RECRUITER_NAME",
                adm.APPLICATION_RECRUIT_NUMBER
        from ODSMGR.ADMINISTRATOR adm
              inner join ODSMGR.Z_RECR_XWALK_VW xw
              on xw.RECRUITER_PIDM = adm.ADMINISTRATOR_UID
              and xw.RECRUITER_VENUE = 'TR') rec
      on ri.PERSON_UID = rec.PERSON_UID
      and ri.ACADEMIC_PERIOD = rec.ACADEMIC_PERIOD
      and ri.RECRUIT_NUMBER = rec.APPLICATION_RECRUIT_NUMBER
      
where ri.ACADEMIC_PERIOD = '201610'
      and ri.RECRUIT_TYPE not in ('ZZ','TA')
      and ri.COLLEGE = 'TR'
      and ri.CURRICULUM_PRIORITY_NUMBER = 1