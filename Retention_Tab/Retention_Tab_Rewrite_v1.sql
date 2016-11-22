/* Notes: -Base view is Z_ACADEMIC_STUDY_VW with alias "z". This picks up all "returnable" students"
          -Join to another instance of Z_ACADEMIC_STUDY_VW to check if registered for "upcoming" term
          -There are two instances of joins to Z_YEAR_TYPE_DEFINITION_VW alias' y1 and y2
            -y1 joins to the returnable academic period. Essentially the "prior" term. We mainly need the term start date for the retention comments
            -y2 is the "upcoming" term which is calculated by ODSMGR.Z_GET_SEMESTER_FNC
              -Upcoming term is as follows:
                -For TR and DE
                  -Fall to Spring
                  -Spring to Fall
                -For FC and GS
                  -always the next semester (ie Fall to Spring. Spring to Summer. Summer to fall)
          -Joins to SPORTS, HOLD can cuase multiple rows for student
*/
select distinct
       z.PERSON_UID,
       z.ID,
       z.NAME,
       rtrim(z.CATALOG_ACADEMIC_PERIOD_DESC, ' FOCUS/CGS') "TERM_ENTERED_PROGRAM",
       z.COLLEGE_DESC "VENUE",
       case when z.STUDENT_TYPE in ('N','G','D') then '1 - New to Level'
            when z.STUDENT_TYPE in ('T','W') then '2 - Transfer'
            when z.STUDENT_TYPE = 'C' then '3 - Continuing'
            when z.STUDENT_TYPE = 'R' then '4 - Re-enrolling'
            when z.STUDENT_TYPE in ('V','Q') then '5 - New to Venue'
            when z.STUDENT_TYPE in ('O','A','U','S') then '6 - NonDegree-Seeking'
            else z.STUDENT_TYPE_DESC
       end "STUDENT_TYPE",
       nvl2(z1.PERSON_UID,'Returned', 'Not Returned') "Status",
       case when z.MAJOR = 'NURS' and z.PROGRAM = 'PNURS' then 'Pre-Nursing'
            else z.MAJOR_DESC 
       end "MAJOR",
       z.DEPARTMENT_DESC "DEPARTMENT",
       z.DEPARTMENT "DEPT_CODE",
       z.COHORT,
       decode(z.STUDENT_CLASSIFICATION, 'FR', '1 - Freshman',
                                        'SO', '2 - Sophomore',
                                        'JR', '3 - Junior',
                                        'SR', '4 - Senior',
                                               z.STUDENT_CLASSIFICATION_DESC) "STUDENT_CLASSIFICATION",
       z.PRIMARY_ADVISOR_NAME_LFMI "ADVISOR",
       ODSMGR.Z_GET_USER_FNC(z.PRIMARY_ADVISOR_PERSON_UID, 'USER') "ADVISOR_EXTERNAL_USER",
       z.STUDENT_LEVEL,
       --decode(:Visibility.ACAD_STAND,1,z.ACADEMIC_STANDING,'*Restricted*') "ACADEMIC_STANDING",
       z.YEAR_AT_UNW,
       d.UNW_COLLEGE,
       z.ACADEMIC_STANDING_DESC "ACADEMIC_STANDING",
       z.FTPT_IND,
       decode(z.COMPLETION_IND,'Y','Y',' ') "COMPLETION_IND",
       decode(z.WITHDRAWN_IND,'Y','Y',' ') "WITHDRAWN_IND",
       z.PROGRAM_DESC "PROGRAM",
       sa.STUDENT_ATTRIBUTE,
       case when sa.STUDENT_ATTRIBUTE is not null
            then sa.STUDENT_ATTRIBUTE_DESC
            when r.PERSON_UID is not null
            then decode(substr(r.COMMENT_TXT,1,4),'NRNF','Not Returning - No Form',
                                                  'STOC','Studying Off-Campus',
                                                  'CBNG','Completed But Not Graduated')
            else '*Pending'
        end "NOT_RETURNING_IND",
        nvl(es.ENROLLMENT_CHOICE,' ') "ENROLLMENT_CHOICE",
        NWC.Z_GET_CURRENT_PHONE_FNC(z.PERSON_UID, 'PR') "PR_PHONE",
        NWC.Z_GET_CURRENT_PHONE_FNC(z.PERSON_UID, 'MOBL') "CELL_PHONE",
        lower(ODSMGR.Z_GET_EMAIL_FNC(z.PERSON_UID, 'PR')) "PR_EMAIL",
        ODSMGR.Z_GET_EMAIL_FNC(z.PERSON_UID, 'NWC') "UNW_EMAIL",
        NWC.Z_GET_CONCAT_ADDR_UNWSP_PKG.Z_GET_CURR_ADDR_OF_TYPE_FNC(z.PERSON_UID, 'PR') "PR_ADDRESS",
        nvl(NWC.Z_GET_CONCAT_ADDR_UNWSP_PKG.Z_GET_CURR_ADDR_OF_TYPE_FNC(z.PERSON_UID, 'DR'), 'Commuter') "CURRENT_HOUSING",
        nvl(sp.ACTIVITY_DESC,' ') "SPORT",
        case when substr(h.ROOM,1,1) <> 'O'
             then 'Y'
             else 'N'
        end "HOUSING_ASSIGNED", --for upcoming term
        na.FIRST_GEN_IND,
        case when ra.ACCOUNT_UID is not null 
             then 'No Balance'
             when rad.ACCOUNT_UID is not null 
             then 'Payment Plan'
             else 'Outstanding Balance'
        end "ACCOUNT_BALANCE", --VERIFY AGAINST DASHBAORD!!!
        st.VETERAN_TYPE_DESC,
        pd.GENDER,
        pd.CURRENT_AGE,
        case when exists (select 'Awarded'
                          from ODSMGR.AWARD_BY_AID_YEAR ay
                          where ay.PERSON_UID = z.PERSON_UID
                                and ay.AID_YEAR = y2.YEAR_CODE
                                and ay.PACKAGE_COMPLETE_DATE is not null )
             then 'Awarded'
             when exists (select 'Verification'
                          from ODSMGR.FINAID_TRACKING_REQUIREMENT ftr
                               inner join ODSMGR.FINAID_APPLICANT_STATUS fas
                               on fas.PERSON_UID = ftr.PERSON_UID
                               and fas.AID_YEAR = ftr.AID_YEAR
                          where ftr.PERSON_UID = z.PERSON_UID
                                and ftr.AID_YEAR = y2.YEAR_CODE
                                and ftr.STATUS = 'R'
                                and upper(substr(fas.TRACKING_GROUP_DESC,1,2)) = 'TR' )
            then 'Verification'
            when exists (select 'FAFSA received'
                         from ODSMGR.FINAID_TRACKING_REQUIREMENT ftr1
                         where ftr1.PERSON_UID = z.PERSON_UID
                               and ftr1.AID_YEAR = y2.YEAR_CODE
                               and ftr1.REQUIREMENT = '1FAFSA'
                               and ftr1.STATUS = 'S' )
            then 'FAFSA received'
            else 'Not Submitted'
        end "FAFSA_STATUS",
        nvl(h.HOLD_DESC, 'No Reg Holds') "REGISTRATION_HOLDS",
        case when exists (select 'x' from ODSMGR.HOLD h1
                          where h1.PERSON_UID = z.PERSON_UID
                                and h1.HOLD = 'RC'
                                and h1.ACTIVE_HOLD_IND = 'Y') 
             then 'No' 
             else 'Yes'
        end "CLEARED_TO_REGISTER",
        nvl( (select distinct 'Y'
              from NWC.Z_RETENTION_COMMENTS_TBL rc
              where rc.PERSON_UID = z.PERSON_UID
                    and trunc(rc.COMMENT_DATE) between y1.TERM_START_DATE and y2.DROP_ADD_DATE ),
            'N') "RETENTION_COMMENTS_IND"

from ODSMGR.Z_ACADEMIC_STUDY_VW z --prior term/the term to see if students persisted from

    --to get prior term start date for retention comments
    left outer join ODSMGR.Z_YEAR_TYPE_DEFINITION_VW y1
    on y1.ACADEMIC_PERIOD = z.ACADEMIC_PERIOD
    and y1.YEAR_TYPE = 'ACYR'
     
    --to get upcoming term drop/add date for retention comments
    left outer join ODSMGR.Z_YEAR_TYPE_DEFINITION_VW y2 
    on y2.ACADEMIC_PERIOD = ODSMGR.Z_GET_SEMESTER_FNC(z.COLLEGE, 1+case when z.COLLEGE in ('TR','DE') and substr(z.ACADEMIC_PERIOD_MOD,-1) = '2' then 1 else 0 end, z.ACADEMIC_PERIOD)
    and y2.YEAR_TYPE = 'ACYR'

    --to see if student is registered for upcoming term
    left outer join ODSMGR.Z_ACADEMIC_STUDY_VW z1  
    on z1.PERSON_UID = z.PERSON_UID
    and z1.COLLEGE = z.COLLEGE
    and z1.ACADEMIC_PERIOD = y2.ACADEMIC_PERIOD
    and z1.WITHDRAWN_IND = 'N'
    and z1.PRIMARY_PROGRAM_IND = 'Y'
     
    --to get retention comments that start with codes NRNF, STOC, CBNG
    left outer join NWC.Z_RETENTION_COMMENTS_TBL r 
    on z.PERSON_UID = r.PERSON_UID
    and r.COMMENT_DATE between y1.TERM_START_DATE and y2.DROP_ADD_DATE
    and substr(r.COMMENT_TXT,1,4) in ('NRNF','STOC','CBNG')
    
    --to get UNW college
    left outer join ODSMGR.Z_STVDEPT_VW d
    on d.STVDEPT_CODE = z.DEPARTMENT
    
    --to get not returning attrbitues
    left outer join ODSMGR.STUDENT_ATTRIBUTE sa 
    on sa.PERSON_UID = z.PERSON_UID
    and sa.ACADEMIC_PERIOD = y2.ACADEMIC_PERIOD
    and ( sa.STUDENT_ATTRIBUTE in ('RETN','RETU')
     or ( substr(sa.STUDENT_ATTRIBUTE,1,2) in ('RF','RS','RM')
          and substr(sa.STUDENT_ATTRIBUTE,3,1) between '1' and '9' ) )
    
    --to get enrollment survery data
    left outer join (  
    select es1.PERSON_UID, 
           es1.ACADEMIC_PERIOD, 
           decode(es1.ENROLLMENT_CHOICE,'Y','Plan to attend UNW',
                                        'U','Unsure about attending',
                                        'N','Not planning to attend UNW',
                                        'O','Studying off-campus',
                                        'G','Will be graduating after current term') "ENROLLMENT_CHOICE"
    from ODSMGR.Z_ENROLLMENT_SURVEY_VW es1
    where es1.ACTIVITY_DATE =
          (select max(es2.ACTIVITY_DATE)
           from ODSMGR.Z_ENROLLMENT_SURVEY_VW es2
           where es2.PERSON_UID = es1.PERSON_UID
                 and es2.ACADEMIC_PERIOD = es1.ACADEMIC_PERIOD)
    ) es
    on es.PERSON_UID = z.PERSON_UID
    and substr(es.ACADEMIC_PERIOD,1,5) = z1.ACADEMIC_PERIOD_MOD
    
    --to get SPORT data
    left outer join ODSMGR.SPORT sp
    on sp.PERSON_UID = z.PERSON_UID
    and sp.ACADEMIC_YEAR = z.ACADEMIC_YEAR
    
    --to get if housed for upcoming semester
    left outer join ODSMGR.Z_RMS_HOUSING_VW h
    on h.PERSON_UID = z.PERSON_UID
    and h.BANNER_TERM_CODE = y2.ACADEMIC_PERIOD
    
    --to get first generation college student info
    left outer join  ( 
    select PERSON_UID,
           AID_YEAR,
           max(case when '3' in (MOTHER_HIGHEST_GRADE, FATHER_HIGHEST_GRADE)
                    then 'N'
                    when (FATHER_HIGHEST_GRADE in ('1','2') and MOTHER_HIGHEST_GRADE in ('1','2')) 
                      or (FATHER_HIGHEST_GRADE in ('1','2') and MOTHER_HIGHEST_GRADE is null) 
                      or (FATHER_HIGHEST_GRADE is null and MOTHER_HIGHEST_GRADE in ('1','2'))
                    then 'Y'
               end) "FIRST_GEN_IND" 
    from ODSMGR.NEED_ANALYSIS
    group by PERSON_UID, AID_YEAR
    ) na
    on na.PERSON_UID = z.PERSON_UID
    and na.AID_YEAR = z.ACADEMIC_YEAR
    
    --to get 'No Balance' for ACCOUNT_BALANCE
    left outer join ODSMGR.RECEIVABLE_ACCOUNT ra 
    on ra.ACCOUNT_UID = z.PERSON_UID
    and ra.ACCOUNT_BALANCE = 0
    
    --to get 'Payment Plan' for ACCOUNT_BALANCE
    left outer join ODSMGR.Z_RECV_ACCT_DETL_2_VW rad
    on rad.ACCOUNT_UID = z.PERSON_UID
    and substr(rad.ACADEMIC_PERIOD,1,5) = z.ACADEMIC_PERIOD_MOD
    and rad.DETAIL_CODE = 'BPPS'
    
    --to get vetern status
    left outer join ODSMGR.STUDENT st 
    on st.PERSON_UID = z.PERSON_UID
    and substr(st.ACADEMIC_PERIOD,1,5) = z.ACADEMIC_PERIOD_MOD
    and st.VETERAN_TYPE is not null
    
    --to get gender and current age
    left outer join ODSMGR.PERSON_DETAIL pd 
    on pd.PERSON_UID = z.PERSON_UID
    
    --to get registration holds
    left outer join ODSMGR.HOLD h  
    on h.PERSON_UID = z.PERSON_UID
    and h.HOLD <> 'RC'
    and h.ACTIVE_HOLD_IND = 'Y'
    and h.REGISTRATION_HOLD_IND = 'Y'
    
    
where z.ACADEMIC_PERIOD_MOD = '20152'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      and z.COLLEGE = 'TR'
--      and ( (:Visibility.ADVISORS = 1
--              and :FacultyChair.Exists <> 1
--              and z.PRIMARY_ADVISOR_PERSON_UID = ODSMGR.Z_GET_USER_FNC(:$User.Name,'PIDM'))
--                or :Visibility.ADVISORS is null
--                or (:rb_RetentionVenue.Value in ('FC','GS') and (:Visibility.ADVISORS is null or :Visibility.ADVISORS = 1)))
      
      