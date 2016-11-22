select distinct z.PERSON_UID,
                z.ID,
                coalesce(CHOICE_1,CHOICE_2,CHOICE_3,CHOICE_4,CHOICE_5,
                         CHOICE_6,CHOICE_7,CHOICE_8,CHOICE_9,CHOICE_10) "FAFSA_Position",
                decode(fas.PACKAGE_COMPLETE_DATE, null, 'Not Received', 'Received') "Finaid Packaged",
                case when exists (select 'x'
                                  from ODSMGR.AWARD_BY_AID_YEAR award
                                  where award.PERSON_UID = z.PERSON_UID
                                        and award.AID_YEAR = aa.ACADEMIC_YEAR
                                        and award.FUND in (1101,1102,1108,1109,1110,1143,4466,1216) )
                          then 'High'
                          else 'Low' end "Aid Source Probability",
                          
                case when exists (select 'x'
                                  from ODSMGR.Z_RECRUITMENT_ATTRIBUTE_VW ra
                                  where ra.PERSON_UID = z.PERSON_UID
                                        and ra.RECRUITING_ATTRIBUTE in ('TAR1','TAR2') )
                       or exists (select 'x'
                                  from ODSMGR.Z_ADMISSIONS_ATTRIBUTE_VW zaav
                                  where zaav.PERSON_UID = z.PERSON_UID
                                        and zaav.ADMISSIONS_ATTRIBUTE in ('TAR1','TAR2') )
                     then 'Good'
                     when exists (select 'x'
                                  from ODSMGR.Z_RECRUITMENT_ATTRIBUTE_VW ra
                                  where ra.PERSON_UID = z.PERSON_UID
                                        and ra.RECRUITING_ATTRIBUTE in ('TAR4','TAR5') )
                       or exists (select 'x'
                                  from ODSMGR.Z_ADMISSIONS_ATTRIBUTE_VW zaav
                                  where zaav.PERSON_UID = z.PERSON_UID
                                    and zaav.ADMISSIONS_ATTRIBUTE in ('TAR4','TAR5') )
                      then 'Not Good' end "Award_Reaction"
                                                                                    
from ODSMGR.Z_ACADEMIC_STUDY_VW z
                     
inner join ODSMGR.ADMISSIONS_APPLICATION aa
on z.PERSON_UID = aa.PERSON_UID
and aa.COLLEGE = z.COLLEGE
and aa.STUDENT_LEVEL = z.STUDENT_LEVEL

      left outer join (                            -----------should this part be joined on admit year or by a certain academic period
       select RCRAPP1_PIDM as PERSON_UID,
        RCRAPP1_AIDY_CODE as AID_YEAR,
        decode(RCRAPP1_FED_COLL_CHOICE_1, '002371', '1', null) as CHOICE_1,
        decode(RCRAPP1_FED_COLL_CHOICE_2, '002371', '2', null) as CHOICE_2,
        decode(RCRAPP1_FED_COLL_CHOICE_3, '002371', '3', null) as CHOICE_3,
        decode(RCRAPP3_FED_COLL_CHOICE_4, '002371', '4', null) as CHOICE_4,
        decode(RCRAPP3_FED_COLL_CHOICE_5, '002371', '5', null) as CHOICE_5,
        decode(RCRAPP3_FED_COLL_CHOICE_6, '002371', '6', null) as CHOICE_6,
        decode(RCRAPP3_FED_COLL_CHOICE_7, '002371', '7', null) as CHOICE_7,
        decode(RCRAPP3_FED_COLL_CHOICE_8, '002371', '8', null) as CHOICE_8,
        decode(RCRAPP3_FED_COLL_CHOICE_9, '002371', '9', null) as CHOICE_9,
        decode(RCRAPP3_FED_COLL_CHOICE_10,'002371', '10', null) as CHOICE_10
      from ODSMGR.Z_RCRAPP1_VW fa1
           left outer join ODSMGR.Z_RCRAPP3_VW fa3
           on fa3.RCRAPP3_PIDM = fa1.RCRAPP1_PIDM
           and fa3.RCRAPP3_AIDY_CODE = fa1.RCRAPP1_AIDY_CODE
           and fa3.RCRAPP3_SEQ_NO = fa1.RCRAPP1_SEQ_NO
      where nvl(RCRAPP1_CURR_REC_IND, 'N') = 'Y'
            and ('002371' in (RCRAPP1_FED_COLL_CHOICE_1, RCRAPP1_FED_COLL_CHOICE_2, RCRAPP1_FED_COLL_CHOICE_3)
              or '002371' in (RCRAPP3_FED_COLL_CHOICE_4, RCRAPP3_FED_COLL_CHOICE_5, RCRAPP3_FED_COLL_CHOICE_6, 
                              RCRAPP3_FED_COLL_CHOICE_7, RCRAPP3_FED_COLL_CHOICE_8, RCRAPP3_FED_COLL_CHOICE_9, RCRAPP3_FED_COLL_CHOICE_10) ) ) FAFSA
      on FAFSA.PERSON_UID = aa.PERSON_UID
      and FAFSA.AID_YEAR = aa.ACADEMIC_YEAR
      
      left outer join ODSMGR.FINAID_APPLICANT_STATUS fas
      on fas.PERSON_UID = aa.PERSON_UID
      and fas.AID_YEAR = aa.ACADEMIC_YEAR
      and fas.PACKAGE_COMPLETE_DATE is not null


where z.ACADEMIC_PERIOD like '20152%'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      and aa.PRIMARY_PROGRAM_IND = 'Y'               
      and aa.APPLICATION_NUMBER = (select max(aa1.APPLICATION_NUMBER)
                                                           from ADMISSIONS_APPLICATION aa1
                                                           where aa1.PERSON_UID = aa.PERSON_UID
                                                                       and aa1.COLLEGE = aa.COLLEGE
                                                                       and aa1.STUDENT_LEVEL = aa.STUDENT_LEVEL )
																																			 
order by 1