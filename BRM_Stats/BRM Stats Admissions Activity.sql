select distinct z.person_uid, 
                z.id, 
                z.major_desc "Major_1", 
                z.department_desc "Department_1", 
                z1.major_desc "Major_2", 
                z1.department_desc "Department_2",
                case when z.department in ('BIBL','CMIN') or z1.department in ('BIBL','CMIN') then 'High Lift'
                     when z.department in ('MLAN','HIST','ELIT','EDUC','COMM') or z1.department in ('MLAN','HIST','ELIT','EDUC','COMM') then 'Medium Lift'
                     when z.department in ('AGDE','BUSA','MUSC','PSYC') or z1.department in ('AGDE','BUSA','MUSC','PSYC') then 'Low Lift'
                     else ' ' end "Major_Lift",
                case when pe.SCHOOL_GPA > 3.66 then 'High HS GPA'
                     when pe.SCHOOL_GPA between 3.0 and 3.66 then 'Medium HS GPA'
                     when pe.SCHOOL_GPA < 3.0 then 'Low GPA'
                     else ' ' end "HS GPA Level",
                case when aa.APPLICATION_INFO6 = 'Y' and aa.APPLICATION_INFO5 < 75 then 'Level 4 or 5'
                     else ' ' end "Institutional Rating Freshmen"

from ODSMGR.Z_ACADEMIC_STUDY_VW z
     left outer join ODSMGR.Z_ACADEMIC_STUDY_VW z1
     on z1.PERSON_UID = z.PERSON_UID
     and z1.ACADEMIC_PERIOD = z.ACADEMIC_PERIOD
     and z1.PRIMARY_PROGRAM_IND = 'N'
     
     left outer join ODSMGR.PREVIOUS_EDUCATION pe
     on pe.PERSON_UID = z.PERSON_UID
     and pe.INSTITUTION_TYPE = 'H'

     left outer join ODSMGR.ADMISSIONS_APPLICATION aa
     on aa.PERSON_UID = z.PERSON_UID
     and aa.COLLEGE = z.COLLEGE
     and aa.STUDENT_LEVEL = z.STUDENT_LEVEL
     
where z.ACADEMIC_PERIOD like '20152%'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      and aa.APPLICATION_NUMBER = (select max(aa1.APPLICATION_NUMBER)
                                                           from ADMISSIONS_APPLICATION aa1
                                                           where aa1.PERSON_UID = aa.PERSON_UID
                                                                       and aa1.COLLEGE = aa.COLLEGE
                                                                       and aa1.STUDENT_LEVEL = aa.STUDENT_LEVEL )
																																			 