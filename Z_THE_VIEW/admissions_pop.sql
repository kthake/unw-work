select *
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
pivot (max(DECISION_DATE) for DECISION in ('03' as D_03,
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
                                           '97' as D_97) ) a
                                           
       