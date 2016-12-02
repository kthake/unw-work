with reg as (
            select /*+ MATERIALIZE */  
                  a.*,
                  case when AUDIT_COUNT > 0 and REGISTERED_COUNT = 0
                       then 'Y'
                  end "AUDIT_ONLY_IND",
                  case when REGISTERED_COUNT > 0
                       then 'Y'
                  end "REGISTERED_IND",
                  case when WITHDRAWN_COUNT > 0 and AUDIT_COUNT + REGISTERED_COUNT = 0
                       then 'Y'
                  end "WITHDRAWN_IND",
                  case when DROP_COUNT > 0 and AUDIT_COUNT + REGISTERED_COUNT + WITHDRAWN_COUNT = 0
                       then 'Y'
                  end "DROP_IND"
            from
              (
              select distinct s.PERSON_UID,
                              substr(s.ACADEMIC_PERIOD,1,5) "ACADEMIC_PERIOD_MOD",
                              s.COURSE_REFERENCE_NUMBER,
                              decode(s.REGISTRATION_STATUS,'AD','D', --DROP
                                                           'AU','A', --AUDIT
                                                           'AW','W', --WITHDRAWN
                                                           'DC','D',
                                                           'DD','D',
                                                           'DW','D',
                                                           'DX','D',
                                                           'FX','W',
                                                           'OD','D',
                                                           'PP','NA', --UNSURE
                                                           'PW','W',
                                                           'PX','W',
                                                           'RE','R', --REGISTERED
                                                           'RW','R',
                                                           'WC','W',
                                                           'WL','W',
                                                           'WP','NA',
                                                           'WX','W') "REG_GROUP"
                              
              from MST_STUDENT_COURSE s
              where s.TRANSFER_COURSE_IND = 'N'
              )
            pivot ( count(COURSE_REFERENCE_NUMBER) for  REG_GROUP in ('A' as AUDIT_COUNT,
                                                                      'R' as REGISTERED_COUNT,
                                                                      'W' as WITHDRAWN_COUNT,
                                                                      'D' as DROP_COUNT,
                                                                      'NA' as OTHERS_COUNT)
                  ) a
            ),
            
     adm as (
            select /*+ MATERIALIZE */  
                   a.*,
                   to_date('01/01/2999','mm/dd/yyyy') "END_OF_TIME"
            from
              (
              select distinct PERSON_UID,
                              substr(ACADEMIC_PERIOD,1,5) "ACADEMIC_PERIOD_MOD",
                              COLLEGE,
                              DECISION_DATE,
                              DECISION,
                              SUBSTR(SOKODSF.F_SARAPPD_INFO(PERSON_UID, ACADEMIC_PERIOD, APPLICATION_NUMBER, 1, 'DECISION'), 1, 2) "LATEST_DECISION"
                              
              from ODSMGR.Z_ADMISSIONS_DECISION_TBL
              where LATEST_APPLICATION_IND = 'Y'
                )
            pivot (min(DECISION_DATE) for DECISION in ('03' as D_03,
                                                       '05' as D_05,
                                                       '07' as D_07,
                                                       '08' as D_08,
                                                       '09' as D_09,
                                                       '17' as D_17,
                                                       '18' as D_18,
                                                       '20' as D_20,
                                                       '25' as D_25,
                                                       '33' as D_33,
                                                       '35' as D_35,
                                                       '36' as D_36,
                                                       '50' as D_50,
                                                       '51' as D_51,
                                                       '56' as D_56,
                                                       '57' as D_57,
                                                       '58' as D_58,
                                                       '80' as D_80,
                                                       '81' as D_81,
                                                       '90' as D_90,
                                                       '91' as D_91,
                                                       '92' as D_92,
                                                       '93' as D_93,
                                                       '94' as D_94,
                                                       '97' as D_97 )
                  ) a
            )

select base.PERSON_UID,
       p.ID,
       base.ACADEMIC_PERIOD_MOD,
       adm.COLLEGE,
       --nvl2(reg.PERSON_UID,'REG','ADM') "DATA_ORIGIN",
       p.GENDER,
       p.BIRTH_DATE,
       nullif(least(nvl(adm.D_25,END_OF_TIME),nvl(adm.D_33,END_OF_TIME)),END_OF_TIME) "MIN_ACCEPTED_DATE",
       nullif(least(nvl(adm.D_35,END_OF_TIME),nvl(adm.D_36,END_OF_TIME)),END_OF_TIME) "MIN_CONFIRMED_DATE",
       nullif(least(nvl(adm.D_50,END_OF_TIME),nvl(adm.D_51,END_OF_TIME),nvl(adm.D_56,END_OF_TIME),nvl(adm.D_57,END_OF_TIME),nvl(adm.D_58,END_OF_TIME)),END_OF_TIME) "MIN_DEFER_DATE",
       nullif(least(nvl(adm.D_90,END_OF_TIME),nvl(adm.D_91,END_OF_TIME),nvl(adm.D_92,END_OF_TIME),nvl(adm.D_93,END_OF_TIME),nvl(adm.D_94,END_OF_TIME),nvl(adm.D_97,END_OF_TIME)),END_OF_TIME) "MIN_WITHDRAW_DATE"

from
  (
  select distinct PERSON_UID, ACADEMIC_PERIOD_MOD
  from reg

  union
  select distinct PERSON_UID, ACADEMIC_PERIOD_MOD
  from adm
  ) base
  
  left outer join ODSMGR.Z_PERSON_NAME_VW p
  on p.PERSON_UID = base.PERSON_UID
  
  left outer join reg
  on reg.PERSON_UID = base.PERSON_UID
  and reg.ACADEMIC_PERIOD_MOD = base.ACADEMIC_PERIOD_MOD
  
  left outer join adm
  on adm.PERSON_UID = base.PERSON_UID
  
where base.ACADEMIC_PERIOD_MOD = '20161'
      and adm.ACADEMIC_PERIOD_MOD = 
            ( select max(ACADEMIC_PERIOD_MOD)
              from adm adm1
              where adm1.PERSON_UID = base.PERSON_UID
                    and adm1.ACADEMIC_PERIOD_MOD <= base.ACADEMIC_PERIOD_MOD )