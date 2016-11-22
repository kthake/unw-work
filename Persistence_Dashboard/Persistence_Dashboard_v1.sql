select distinct count(distinct PERSON_UID) over (partition by LEVEL_1) "LEVEL_1",
                decode(LEVEL_1, 1, 'Completing Academic Goal',
                                2, 'Persisting on UNW Pathway',
                                3, 'Not Registered') "LEVEL_1_DESC",
                case when LEVEL_1 in (1,2) then count(distinct PERSON_UID) over (partition by LEVEL_1_2, LEVEL_1) else null end "LEVEL_1_2",
                case when LEVEL_1 in (1,2) then decode(LEVEL_1_2, '2a', 'Spring Graduates',
                                                             '2b', 'Sept. Nursing Grads',
                                                             '2c', '3 and 2 Engineering Students',
                                                             '2d', 'Study off-campus (not through UNW)',
                                                             '2e', 'Registered as UNW') end "LEVEL_1_3_DESC"
from
(
select distinct z.PERSON_UID,
                case when z.COMPLETION_IND = 'Y' and z.PROGRAM <> 'BS-ENDD' and not exists (select 'registered for upcoming semester'
                                                                                            from ODSMGR.Z_ACADEMIC_STUDY_VW z1
                                                                                            where z1.PERSON_UID = z.PERSON_UID
                                                                                                  and z1.COLLEGE = z.COLLEGE
                                                                                                  and substr(z1.ACADEMIC_PERIOD,1,5) = '20161' )
                     then 1
                     when exists (select 'registered for upcoming semester'
                                  from ODSMGR.Z_ACADEMIC_STUDY_VW z1
                                  where z1.PERSON_UID = z.PERSON_UID
                                        and z1.COLLEGE = z.COLLEGE
                                        and substr(z1.ACADEMIC_PERIOD,1,5) = '20161' )
                           or z.COMPLETION_IND = 'Y' and z.PROGRAM = 'BS-ENDD'
                     then 2
                     else 3
                     end "LEVEL_1", --completing (1), persisting (2), not registered (3)

                case when ( z.COMPLETION_IND = 'Y' and z.PROGRAM <> 'BS-ENDD' and z.MAJOR <> 'NURS')
                          or ( z.COMPLETION_IND = 'Y' and z.MAJOR = 'NURS' and substr(z.GRAD_ACADEMIC_PERIOD_INTENDED,5,1) <> '3' )
                     then '2a'
                     when z.COMPLETION_IND = 'Y' and z.MAJOR = 'NURS' and substr(z.GRAD_ACADEMIC_PERIOD_INTENDED,5,1) = '3' and z.PROGRAM <> 'BS-ENDD'
                     then '2b'
                     when z.COMPLETION_IND = 'Y' and z.PROGRAM = 'BS-ENDD' 
                     then '2c'
                     when z.TOTAL_CREDITS > 0 and z.TOTAL_CREDITS = z.FIN_AID_REG_CREDITS 
                     then '2d'
                     when exists (select 'registered for upcoming semester'
                                  from ODSMGR.Z_ACADEMIC_STUDY_VW z1
                                  where z1.PERSON_UID = z.PERSON_UID
                                        and z1.COLLEGE = z.COLLEGE
                                        and substr(z1.ACADEMIC_PERIOD,1,5) = '20161' 
                                        and (z.TOTAL_CREDITS <> z.FIN_AID_REG_CREDITS) ) 
                     then '2e' 
                     else null end "LEVEL_1_2",
                case when z.TOTAL_CREDITS > 0 and z.TOTAL_CREDITS = z.UNW_OFF_CAMPUS_CREDITS
                then 1
                else 2
                end "LEVEL_1_2_3" --study off campus/abroud through UNW,

from ODSMGR.Z_ACADEMIC_STUDY_VW z

where substr(z.ACADEMIC_PERIOD,1,5) = '20152'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      and case when exists (select 'x' from Z_ACADEMIC_STUDY_VW z1 where z1.PERSON_UID = z.PERSON_UID and substr(z1.ACADEMIC_PERIOD,1,5) = substr(z.ACADEMIC_PERIOD,1,5) and z1.ACADEMIC_PERIOD like '%0')
                  and exists (select 'x' from Z_ACADEMIC_STUDY_VW z1 where z1.PERSON_UID = z.PERSON_UID and substr(z1.ACADEMIC_PERIOD,1,5) = substr(z.ACADEMIC_PERIOD,1,5) and z1.ACADEMIC_PERIOD like '%5')
               then '0'
               else substr(z.ACADEMIC_PERIOD,6,1) end = substr(z.ACADEMIC_PERIOD,6,1)

)

/*
where case when LEVEL_1 = 2 then 2
           else null end = LEVEL_2_2 */