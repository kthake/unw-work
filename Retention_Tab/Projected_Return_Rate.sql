select TYPE, 
       VALUE,
       ROWNUM "SORT"
from
  (
  select round(RETURNED/RETURNABLE,4) * 100 "ACTUAL_RETURN_RATE",
         round((RETURNED + RED + YELLOW + GREEN)/RETURNABLE,4) * 100 "PROJECTED_RETURN_RATE",
         RED + YELLOW + GREEN "TOTAL_POTENTIAL_RETURNS",
         RETURNED + RED + YELLOW + GREEN "PROJECTED_RETURNED",
         a.*
  from
    (
    select  --count(distinct z.PERSON_UID) "TOTAL",
            count(distinct z1.PERSON_UID) "RETURNED",
            count(distinct case when z.COMPLETION_IND = 'Y' and z1.PERSON_UID is null
                                then null
                                when z.STUDENT_TYPE = 'O' or z.PROGRAM = 'ADDTL'
                                then null
                                else z.PERSON_UID
                           end) "RETURNABLE",
            floor(count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 10
                                      then r.PERSON_UID
                                 end) * 0.1 ) "RED",                   
            floor(count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 50
                                      then r.PERSON_UID
                                 end) * 0.5 ) "YELLOW",
            floor(count(distinct case when z1.PERSON_UID is null and r.RETURN_RATING = 90
                                      then r.PERSON_UID
                                 end) * 0.9 ) "GREEN"
                           
    from ODSMGR.Z_ACADEMIC_STUDY_VW z

          left outer join ODSMGR.Z_ACADEMIC_STUDY_VW z1
          on z1.PERSON_UID = z.PERSON_UID
          and z1.ACADEMIC_PERIOD_MOD = '20162'
          and z1.PRIMARY_PROGRAM_IND = 'Y'
          
          left outer join NWC.Z_RETENTION_IND_TBL r
          on r.PERSON_UID = z.PERSON_UID
          and substr(r.ACADEMIC_PERIOD,1,5) = '20162'
          
    where z.ACADEMIC_PERIOD_MOD = '20161'
          and z.COLLEGE = 'TR'
          and z.PRIMARY_PROGRAM_IND = 'Y'
          
    ) a
  ) b
unpivot (VALUE for type in (RETURNABLE as 'Returnable',
                            RETURNED as 'Returned',
                            PROJECTED_RETURNED as 'Projected Returned',
                            ACTUAL_RETURN_RATE as 'Actual Return Rate',
                            PROJECTED_RETURN_RATE as 'Porjected Return Rate',
                            GREEN as 'Green', 
                            YELLOW as 'Yellow', 
                            RED as 'Red', 
                            TOTAL_POTENTIAL_RETURNS as 'Total Potential Returns') )

union 
select '---------------------',
       null,
       5.5
from dual

order by 3