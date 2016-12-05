select base.PERSON_UID,
COUNT(BASE.PERSON_UID)
--       p.ID,
--       base.ACADEMIC_PERIOD_MOD,
--       adm.COLLEGE,
--       p.GENDER,
--       p.BIRTH_DATE,
--       nullif(least(nvl(adm.D25,END_OF_TIME),nvl(adm.D33,END_OF_TIME)),END_OF_TIME) "MIN_ACCEPTED_DATE",
--       nullif(least(nvl(adm.D35,END_OF_TIME),nvl(adm.D36,END_OF_TIME)),END_OF_TIME) "MIN_CONFIRMED_DATE",
--       nullif(least(nvl(adm.D50,END_OF_TIME),nvl(adm.D51,END_OF_TIME),nvl(adm.D56,END_OF_TIME),nvl(adm.D57,END_OF_TIME),nvl(adm.D58,END_OF_TIME)),END_OF_TIME) "MIN_DEFER_DATE",
--       nullif(least(nvl(adm.D90,END_OF_TIME),nvl(adm.D91,END_OF_TIME),nvl(adm.D92,END_OF_TIME),nvl(adm.D93,END_OF_TIME),nvl(adm.D94,END_OF_TIME),nvl(adm.D97,END_OF_TIME)),END_OF_TIME) "MIN_WITHDRAW_DATE",
--       reg.REGISTERED_IND

from
  (
  select distinct PERSON_UID, ACADEMIC_PERIOD_MOD
  from {{KTH_REG_POP_VW}} 

  union
  select distinct PERSON_UID, ACADEMIC_PERIOD_MOD
  from {{KTH_ADM_POP_VW}} 
  ) base
  
  left outer join ODSMGR.Z_PERSON_NAME_VW p
  on p.PERSON_UID = base.PERSON_UID
  
  left outer join {{KTH_REG_POP_VW}} reg
  on reg.PERSON_UID = base.PERSON_UID
  and reg.ACADEMIC_PERIOD_MOD = base.ACADEMIC_PERIOD_MOD
  
  left outer join {{KTH_ADM_POP_VW}} adm
  on adm.PERSON_UID = base.PERSON_UID
  
where base.ACADEMIC_PERIOD_MOD = '20161'
      and adm.ACADEMIC_PERIOD_MOD = 
            ( select max(ACADEMIC_PERIOD_MOD)
              from {{KTH_ADM_POP_VW}} adm1
              where adm1.PERSON_UID = base.PERSON_UID
                    and adm1.ACADEMIC_PERIOD_MOD <= base.ACADEMIC_PERIOD_MOD )
                    
                  GROUP BY BASE.PERSON_UID