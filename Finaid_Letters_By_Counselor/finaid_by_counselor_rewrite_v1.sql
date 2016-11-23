select distinct aa.PERSON_UID,
       aa.ID,
       NWC.Z_FORMAT_NAME_FNC(aa.PERSON_UID,'FMIL') "FULL_NAME_FMIL",
       NWC.Z_FORMAT_NAME_FNC(aa.PERSON_UID,'LFMI') "FULL_NAME_LFMI",
       ODSMGR.Z_GET_EMAIL_FNC(aa.PERSON_UID, 'PR','BU','NWC') "email_adm",
       ap.STREET_LINE1,
       ap.STREET_LINE2,
       ap.CITY,
       ap.STATE_PROVINCE,
       ap.POSTAL_CODE,
       ap.MAILING_ADDRESS,
       case when ap.NATION_DESC = 'UNITED STATES' then ''
       else ap.NATION_DESC end "Nation",
       TO_CHAR(SYSDATE,'fmMonth DD, YYYY') "Date",
       na.YEAR_IN_COLLEGE,
       Max( decode(na.YEAR_IN_COLLEGE,1,'Freshman',
                                      2,'Freshman',
                                      3,'Sophomore',
                                      4,'Junior',
                                      5,'Senior',
                                      6,'Fifth Year Senior',
                                      7,'First Year Graduate Studies',
                                      8,'Second Year Graduate Studies',
                                      9,'Third Year Graduate Studies',
                                      0,'Beyond Third Year Graduate Studies',
                                        'Unknown') )
          over (partition by na.PERSON_UID) "College_Year",
       decode(na.HOUSING,1,'With Parents',
                         2,'Campus',
                         3,'Off-Campus',
                         4,'With Relatives',
                           'Unknown' ) "Housing_Code_Desc",
       abp.FUND,
       abp.FUND_TITLE,
       nvl(abp.FALL,0) "FALL",
       nvl(abp.SPRING,0) "SPRING",
       nvl(abp.SUMMER,0) "SUMMER",
       nvl(abp.FALL,0) + nvl(abp.SPRING,0) + nvl(abp.SUMMER,0) "TOTAL",
       abp.AID_YEAR,
       abp.AID_YEAR_DESC,
       abp.AID_YEAR_EXPANDED "Aid_Year_Expanded",
       abp.AWARD_STATUS,
       abp.AWARD_OFFER_IND,
       abp.AWARD_ACCEPT_IND,
       abp.AID_GROUPING,
       decode(abp.AID_GROUPING,3,'Loan Eligibility',
                               1,'Gift Aid' ) "AID_GROUP_DESC",
       fas.PACKAGING_GROUP,
       fas.PACKAGING_GROUP_DESC,
       trunc(fas.PACKAGE_COMPLETE_DATE) "Package_Complete_Date",
--       :edFallCr "Fall_Credits",
--       :edSpringCr "Spring_Credits",
--       :edSummerCr "Summer_Credits",
       aa.LATEST_DECISION_DESC "Latest_Descison_Comb",
       xw.RECRUITER_CODE "Recruiter_Code",
       adm.ADMINISTRATOR_UID,
       adm.ADMINISTRATOR_FIRST_NAME ||' '|| adm.ADMINISTRATOR_LAST_NAME "Recruiter_Desc",
       adm.ADMINISTRATOR_FIRST_NAME "Recruiter_First",
       adm.ADMINISTRATOR_LAST_NAME "Recruiter_Last",
       ODSMGR.Z_GET_EMAIL_FNC(adm.ADMINISTRATOR_UID,'NWC') "Recruiter_Email",
       NVL(NWC.Z_GET_CURRENT_PHONE_FNC(fas.PERSON_UID,'PR'),NWC.Z_GET_CURRENT_PHONE_FNC(fas.PERSON_UID,'MOBL') ) "PHONE",
       z_get_fafsa_choices_fnc (fas.PERSON_UID,fas.AID_YEAR,'inline', 'CONC',',') "FAFSA_Choice"
  from ODSMGR.FINAID_APPLICANT_STATUS fas
        inner join 
        ( select *
          from (
          select PERSON_UID,
                 FUND,
                 FUND_TITLE,
                 substr(ACADEMIC_PERIOD,5,1) "TERM",
                 AID_YEAR,
                 AID_YEAR_DESC,
                 ltrim(AID_YEAR_DESC, 'Award Year ') "AID_YEAR_EXPANDED",
                 AWARD_STATUS,
                 AWARD_OFFER_IND,
                 AWARD_ACCEPT_IND,
                 case when FUND between 1500 AND 1599
                      then 3
                      when FUND < 1500 or FUND > 1699
                      then 1 
                 end"AID_GROUPING",
                 AWARD_OFFER_AMOUNT
          from ODSMGR.AWARD_BY_PERSON 
          where AID_YEAR = '1718' ------ VARIABLE
                and FUND not between 1600 and 1699 )
          pivot ( sum(AWARD_OFFER_AMOUNT) for TERM in ('1' as FALL, '2' as SPRING, '3' as SUMMER) ) ) abp
          on abp.PERSON_UID = fas.PERSON_UID
          and abp.AID_YEAR = fas.AID_YEAR
          and trunc(fas.PACKAGE_COMPLETE_DATE) between trunc(sysdate-7) and trunc(sysdate-1)
          
          left outer join ODSMGR.NEED_ANALYSIS na
          on na.PERSON_UID = abp.PERSON_UID
          and na.AID_YEAR = abp.AID_YEAR
          and na.CURRENT_RECORD_IND = 'Y'
 
        left outer join ODSMGR.ADDRESS_PREFERRED ap
        on ap.ENTITY_UID = fas.PERSON_UID
 
        inner join ODSMGR.ADMISSIONS_APPLICATION aa
        on aa.PERSON_UID = fas.PERSON_UID
        and aa.ACADEMIC_YEAR = fas.AID_YEAR
        and aa.COLLEGE = 'TR'
        and aa.LATEST_DECISION in ('25','26','35','36','80')
        
        inner join ( ODSMGR.ADMINISTRATOR adm
                     inner join ODSMGR.Z_RECR_XWALK_VW xw
                     on xw.RECRUITER_PIDM = adm.ADMINISTRATOR_UID
                     and xw.RECRUITER_VENUE = 'TR' )
        on adm.PERSON_UID = aa.PERSON_UID
        and adm.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD
 

 where
--         and adm.ADMINISTRATOR_UID = :lbCounselor.Recruiter_Pidm
         ( aa.PERSON_UID, aa.APPLICATION_NUMBER )  not in
         ( select PERSON_UID,
                  APPLICATION_NUMBER
             from ODSMGR.ADMISSIONS_ATTRIBUTE att
            where att.ADMISSIONS_ATTRIBUTE in ('TAR1','TAR2','TAR3','TAR4','TAR5')
                  and att.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD )
         and aa.CURRICULUM_ORDER =
         ( select min( aa1.CURRICULUM_ORDER ) "Min_CURRICULUM_ORDER"
             from ODSMGR.ADMISSIONS_APPLICATION aa1
            where aa1.PERSON_UID = aa.PERSON_UID
                  and aa1.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD
                  and aa1.COLLEGE = aa.COLLEGE
                  and aa1.APPLICATION_NUMBER = aa.APPLICATION_NUMBER )

order by adm.ADMINISTRATOR_UID,
         trunc(fas.PACKAGE_COMPLETE_DATE),
         NWC.Z_FORMAT_NAME_FNC(aa.PERSON_UID,'LFMI'),
         abp.AID_GROUPING
         