with HS_FEED as ( 
      select count(distinct z1.PERSON_UID) as TOTAL, 
             pe1.INSTITUTION
      from ODSMGR.Z_ACADEMIC_STUDY_VW z1
      inner join ODSMGR.PREVIOUS_EDUCATION pe1
      on pe1.PERSON_UID = z1.PERSON_UID
      where z1.ACADEMIC_PERIOD like '20152%'
           and pe1.INSTITUTION_TYPE = 'H'
           and z1.COLLEGE = 'TR'
           and z1.WITHDRAWN_IND = 'N'
      group by pe1.INSTITUTION ),
      
      CHURCH_FEED as (
      select count(distinct z1.PERSON_UID) as TOTAL,
             rs.INSTITUTION
      from ODSMGR.Z_ACADEMIC_STUDY_VW z1
      inner join ODSMGR.RECRUITMENT_SOURCE rs
      on rs.PERSON_UID = z1.PERSON_UID
      where z1.ACADEMIC_PERIOD like '20152%'
            and substr(rs.INSTITUTION,1,1) = 'C'
            and rs.ACADEMIC_PERIOD = (select max(rs1.ACADEMIC_PERIOD)
                                      from ODSMGR.RECRUITMENT_SOURCE rs1
                                      where rs1.PERSON_UID = rs.PERSON_UID
                                            and rs1.ACADEMIC_PERIOD <= '201525') 
      group by rs.INSTITUTION )
      


select distinct z.PERSON_UID,
                z.ID,
                z.ACADEMIC_PERIOD,
                pd.RELIGION||' - '||pd.RELIGION_DESC "Denomination",
                case when pd.RELIGION in ('EF','ND') then '1 - High'
                     when pd.RELIGION in ('BA','BB','BC','BG','BI','BN','BO','BS') then '2 - Med-High'
                     when pd.RELIGION in ('AL','AS','CV','LB','LE','LM','LU','LW') then '3 - Med-Low'
                     when pd.RELIGION in ('GO','ME','MB','SD','AN','EP','MR') then '4 - Low'
                     else 'Other' end "Denomination_Factor",
                pe.INSTITUTION_DESC,
                case when HS_FEED.TOTAL >= 10  then '1 - High'
                     when HS_FEED.TOTAL between 4 and 9 then '2 - Medium'
                     else '3 - Low' end "High_School_Feed",
                CHURCH_FEED.TOTAL
                      
                

from ODSMGR.Z_ACADEMIC_STUDY_VW z

inner join ODSMGR.PERSON_DETAIL pd
on pd.PERSON_UID = z.PERSON_UID

left outer join ODSMGR.PREVIOUS_EDUCATION pe
on pe.PERSON_UID = z.PERSON_UID
and pe.INSTITUTION_TYPE = 'H'

left outer join ODSMGR.RECRUITMENT_SOURCE rs
on rs.PERSON_UID = z.PERSON_UID,

HS_FEED,
CHURCH_FEED


where z.ACADEMIC_PERIOD like '20152%'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and HS_FEED.INSTITUTION = pe.INSTITUTION
      and CHURCH_FEED.INSTITUTION = rs.INSTITUTION

order by 5 asc