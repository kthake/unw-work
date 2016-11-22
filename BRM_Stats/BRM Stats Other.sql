select distinct z.person_uid, z.name,
                (select distinct 'x' 
                 from ODSMGR.RELATIONSHIP r
                      inner join ODSMGR.ACADEMIC_OUTCOME ao
                      on ao.PERSON_UID = r.RELATED_UID
                      and ao.STATUS = 'AW'
                 where r.ENTITY_UID = z.PERSON_UID
                       and r.RELATED_CROSS_REFERENCE = 'PRN' ) "Alumni Kid",
                       
                (select distinct 'x'
                 from ODSMGR.RELATIONSHIP r     
                       inner join ODSMGR.Z_EMPLOYEE_VW e
                       on e.PERSON_UID = r.RELATED_UID
                       and e.EMPLOYEE_STATUS = 'A'
                 where r.ENTITY_UID = z.PERSON_UID
                       and r.RELATED_CROSS_REFERENCE = 'PRN' ) "Employee Kid",
                       
                (select distinct 'x' 
                 from ODSMGR.RELATIONSHIP r
                      inner join ODSMGR.ADMISSIONS_APPLICATION aa
                      on aa.PERSON_UID = r.RELATED_UID
                 where r.ENTITY_UID = z.PERSON_UID
                       and aa.ACADEMIC_PERIOD < z.ACADEMIC_PERIOD
                       and r.RELATED_CROSS_REFERENCE = 'SIB' ) "Sibling",
                
                case when exists (select distinct 'x'
                                  from ODSMGR.RECRUITMENT_ATTRIBUTE ra
                                  where ra.PERSON_UID = z.PERSON_UID
                                        and ra.RECRUITING_ATTRIBUTE = 'TMK')
                       or exists (select distinct 'x'
                                  from ODSMGR.ADMISSIONS_ATTRIBUTE aa
                                  where aa.PERSON_UID = z.PERSON_UID
                                        and aa.ADMISSIONS_ATTRIBUTE = 'TMK')
                     then 'x' else null end "Missionary Kid",
                     
                case when exists (select distinct 'x'
                                  from ODSMGR.RECRUITMENT_ATTRIBUTE ra
                                  where ra.PERSON_UID = z.PERSON_UID
                                        and ra.RECRUITING_ATTRIBUTE in ('TS90','TS91','TS92','TS93','TS94','TS95','TS96','TS97','TS98','TS99','TS1') )
                       or exists (select distinct 'x'
                                  from ODSMGR.ADMISSIONS_ATTRIBUTE aa
                                  where aa.PERSON_UID = z.PERSON_UID
                                        and aa.ADMISSIONS_ATTRIBUTE in ('TS90','TS91','TS92','TS93','TS94','TS95','TS96','TS97','TS98','TS99','TS1') )
                     then 'x' else null end "SMART Approach >= .90",
                 
                (select distinct 'x'
                 from ODSMGR.Z_ACADEMIC_STUDY_VW z1
                 where z1.PERSON_UID = z.PERSON_UID
                       and z1.COLLEGE = 'DE'
                       and z1.WITHDRAWN_IND = 'N'
                       and z1.PROGRAM in ('UNDECLARED-E','UNDECLARED-P') ) "Former UNW PSEO"
from Z_ACADEMIC_STUDY_VW z

where z.ACADEMIC_PERIOD like '20152%'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      