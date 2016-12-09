select BANINST1.F_GETSPRIDENID(r.PERSON_UID) "ID",
       r.PERSON_UID,
       SGBSTDN_TERM_CODE_EFF,
       SGBSTDN_COLL_CODE_1,
       SGBSTDN_STYP_CODE
from {{BAN_REG_POP_VW}} r

      left outer join SATURN.SGBSTDN s
      on SGBSTDN_PIDM = r.PERSON_UID
      
where ACADEMIC_PERIOD_MOD = '20161'
      and REGISTERED_IND = 'Y'
      and SGBSTDN_STYP_CODE <> 'C'
      and SGBSTDN_COLL_CODE_1 <> 'DE'
      and not exists ( select distinct 'x'
                       from SATURN.SHRTTRM
                       where SHRTTRM_PIDM = r.PERSON_UID
                             and substr(SHRTTRM_TERM_CODE,1,5) = r.ACADEMIC_PERIOD_MOD )
      and SGBSTDN_TERM_CODE_EFF =
            (select SGBSTDN_TERM_CODE_EFF
             from SATURN.SGBSTDN s1
             where s1.SGBSTDN_PIDM = s.SGBSTDN_PIDM
                   and substr(SGBSTDN_TERM_CODE_EFF,1,5) <= r.ACADEMIC_PERIOD_MOD
             order by SGBSTDN_TERM_CODE_EFF desc
             fetch first 1 row only )