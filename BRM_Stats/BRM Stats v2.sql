with rs as  (select /*+ INLINE */
																PERSON_UID,
                                INSTITUTION,
                                INSTITUTION_DESC
           						from ODSMGR.RECRUITMENT_SOURCE
           						where PRIMARY_SOURCE_IND = 'Y' ),
											
											
     COLLEGE_CHOICE as (select distinct PERSON_UID,
		 													 																			  min(TEST_ACCOMODATION) as value
		 																			 from ODSMGR.TEST
										                       where TEST = 'A05'
																											 and TEST_ACCOMODATION is not null
																											 and TEST_ACCOMODATION <> 'S'
																											 and TEST_DATE is not null
										                       group by PERSON_UID),
									
	   SUPPLEMENTAL as (select distinct /*+ INLINE */
		 																																PERSON_UID
		 																		from ODSMGR.TEST test
																				where TEST_ACCOMODATION = 'S'
																										and TEST_DATE is not null
																										and not exists (select 'x'
																																								from ODSMGR.TEST test1
																																								where test1.PERSON_UID = test.PERSON_UID
																																														and test1.TEST_DATE is not null
																																														and test1.TEST_ACCOMODATION in ('1','2','3','4','5','6') ) ),
																																														
	 COLLEGE_PREFERENCE as (select distinct
	 																														PERSON_UID,
																															TEST_FORM as VALUE
	 																								from ODSMGR.TEST 
																									where TEST_DATE is not null
																															and ( ( TEST_FORM = '1'
																															and not exists (select 'x' 
																																													from ODSMGR.TEST test1
																																													where test1.PERSON_UID = test.PERSON_UID
																																																			and test1.TEST_DATE is not null
																																																			and test1.TEST_FORM in ('2','3') ) )
																															  or (TEST_FORM = '2'
																																/*and not exists (select 'x' 
																																													from ODSMGR.TEST test1
																																													where test1.PERSON_UID = test.PERSON_UID
																																																			and test1.TEST_DATE is not null
																																																			and test1.TEST_FORM in ('1','3') )*/ )
																															  or (TEST_FORM = '3'
																																and not exists (select 'x' 
																																													from ODSMGR.TEST test1
																																													where test1.PERSON_UID = test.PERSON_UID
																																																			and test1.TEST_DATE is not null
																																																			and test1.TEST_FORM in ('1','2') ) ) ) ),
																																																			
		PREV_COL as (select z1.PERSON_UID,
																				pec1.INSTITUTION,
																			  count(distinct pec1.PERSON_UID) over (partition by pec1.INSTITUTION) as TOTAL
														 from Z_ACADEMIC_STUDY_VW z1
														 					left outer join ODSMGR.PREVIOUS_EDUCATION pec1
																			on pec1.PERSON_UID = z1.PERSON_UID
																			and pec1.INSTITUTION_TYPE = 'C'
																			and pec1.INSTITUTION not in ('973400','973410','973420') 
														where z1.ACADEMIC_PERIOD like '20152%'
      																	and z1.COLLEGE = 'TR'
      																	and z1.WITHDRAWN_IND = 'N'
      																	and z1.PRIMARY_PROGRAM_IND = 'Y')

select distinct z.PERSON_UID,
                z.ID,
                case when aa.STUDENT_POPULATION = 'N' and exists( select 'x' from rs where rs.PERSON_UID = z.PERSON_UID and rs.INSTITUTION in ('SHOOPS',	'SPURPO',	'SPHONE',	'SFALLV',	'SAP',	'SPRING',	'SFTBFR',	'SELAPP',	'SPARNT',	'SCONEV') )
                                    then 'First Source Freshman - High'
                         when aa.STUDENT_POPULATION = 'N' and exists( select 'x' from rs where rs.PERSON_UID = z.PERSON_UID and rs.INSTITUTION in ('SVISTI', 'SJOYFL',	'SSBLG',	'SALMNI',	'SWEB',	'SACT',	'SDMEOS',	'SICEWK',	'SVISTI',	'SCAMPC',	'SINCAP') )
                                    then 'First Source Freshman - Medium'
                         when aa.STUDENT_POPULATION = 'T' and  exists( select 'x' from rs where rs.PERSON_UID = z.PERSON_UID and rs.INSTITUTION in ('SDISED',	'SWRDVW',	'SDMNRC',	'SFAFSA',	'SSBLG',	'SVBK',	'SFALLV',	'SELAPP',	'SATHLC') )
                                    then 'First Source Transfer - High'
                         when aa.STUDENT_POPULATION = 'T' and  exists( select 'x' from rs where rs.PERSON_UID = z.PERSON_UID and rs.INSTITUTION in ('SCAMPC',	'SWEB',	'SACT',	'STEREQ',	'SCHRCH',	'SPRING',	'SHISV',	'SPHONE',	'SCFAIR',	'SINCAP') )
                                    then 'First Source Transfer - Medium'
                         else 'First Source - Other' end "First Source",
								COLLEGE_CHOICE.VALUE "ACT College Choice",
								case when exists(select 'x' from SUPPLEMENTAL where SUPPLEMENTAL.PERSON_UID = z.PERSON_UID) then 'Yes' else 'No' end "College Choice Supplemental",
								decode(COLLEGE_PREFERENCE.VALUE, '1', 'Public',
																																										'2', 'Private',
																																										'3', 'Religious') "ACT/SAT College Preference",
												 





               /* BELOW ARE ALL DEMOGRAPHIC FACTORS
               ac.STATE_PROVINCE,
               ac.NATION,
               ac.POSTAL_CODE,
               zip.RADIUS_MILES,
               case when ac.STATE_PROVINCE = 'MN' and zip.RADIUS_MILES <= 40.0 then '7pt Location - MN Metro'
                        when ac.STATE_PROVINCE = 'MN' and zip.RADIUS_MILES > 40.0 then '5pt Location - MN Outstate'
                        when ac.STATE_PROVINCE in ('WI') then '3pt Location WI'
                        when ac.STATE_PROVINCE in ('IA','SD') then '2pt Location - IA/SD'
                        when ac.STATE_PROVINCE in ('ND','NE','MT') then '1pt Location - ND/NE/MT'
                        when ac.STATE_PROVINCE in ('AE','AA','AP') then '-1pt Location Military Address'
                        when ac.NATION = 'CA' then '-4 Location Canada'
                        when ac.STATE_PROVINCE in ( 'AK', 'AL', 'AR','AS', 'AZ', 'CA', 'CM', 'CO', 'CT',  'DC', 'DE', 'FL', 'FM', 'GA',  'GU', 'HI',  'ID', 'IL', 'IN', 'KS', 'KY', 'LA',  'MA', 'MD',  'ME', 'MH', 'MI', 'MO', 'MP', 'MS', 'NC', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR',  'PA', 'PR', 'PW', 'RI', 'SC',  'TN', 'TX',  'UT',  'VA', 'VI', 'VT', 'WA', 'WV', 'WY' )
                                  then '-3 Location Far Away States'
                       when not exists (select 'x' from ODSMGR.ADDRESS_CURRENT ac1 where ac1.ENTITY_UID = ac.ENTITY_UID and ac1.ADDRESS_TYPE = 'PR') then '-6 Location No PR Address'
                       when ac.NATION not in ('US','CA') then '-5 Location - Foreign'
                       else null end "Location"              
                pd.RELIGION||' - '||pd.RELIGION_DESC "Denomination",
                case when pd.RELIGION in ('EF','ND') then '1 - High'
                     when pd.RELIGION in ('BA','BB','BC','BG','BI','BN','BO','BS') then '2 - Med-High'
                     when pd.RELIGION in ('AL','AS','CV','LB','LE','LM','LU','LW') then '3 - Med-Low'
                     when pd.RELIGION in ('GO','ME','MB','SD','AN','EP','MR') then '4 - Low'
                     else 'Other' end "Denomination_Factor",
                pe.INSTITUTION "HS",
                pe.INSTITUTION_DESC "HS_desc",
                case when upper(i.CONTACT_NAME) = 'CHRISTIAN' then i.CONTACT_NAME 
                     when i.INSTITUTION = '969999' or i.CONTACT_NAME = 'HOMESCHOOL' then 'Home School'
                     else null end "School_Type",
                count(distinct pe.PERSON_UID) over (partition by pe.INSTITUTION) "HS_COUNT",
                case when count(distinct pe.PERSON_UID) over (partition by pe.INSTITUTION) >= 10  then '1 - High'
                     when count(distinct pe.PERSON_UID) over (partition by pe.INSTITUTION) between 4 and 9 then '2 - Medium'
                     else '3 - Low' end "High_School_Feed",
                rsc.INSTITUTION "Church",
                rsc.INSTITUTION_DESC "Church_desc",
                count(distinct rsc.PERSON_UID) over (partition by rsc.INSTITUTION) "CHURCH_COUNT",
                case when count(distinct rsc.PERSON_UID) over (partition by rsc.INSTITUTION) > 5 then '1 - High'
                     when count(distinct rsc.PERSON_UID) over (partition by rsc.INSTITUTION) between 3 and 5 then '2 - Medium'
                     else '3 - Low' end "Church_Feed", 
                pec.INSTITUTION "Previous_College",
                pec.INSTITUTION_DESC "Previous_College_Desc", */
            /*   row_number() over(partition by z.PERSON_UID order by  7) "College_COUNT",
               case when count(distinct pec.PERSON_UID) over (partition by pec.INSTITUTION) > 15 then '1 - High'
                         when count(distinct pec.PERSON_UID) over (partition by pec.INSTITUTION) between 10 and 15 then '2 - Medium'
                         else '3 - Low' end "College_Feed" , */
							case when exists (select 'x' from PREV_COL where z.PERSON_UID = PREV_COL.PERSON_UID and PREV_COL.TOTAL > 15 ) then 'High'
											 when exists (select 'x' from PREV_COL where z.PERSON_UID = PREV_COL.PERSON_UID and PREV_COL.TOTAL between 10 and 15 ) then  'Medium'
                 			 else 'Low' end "College_Feed_Test"
                

from ODSMGR.Z_ACADEMIC_STUDY_VW z

inner join ODSMGR.PERSON_DETAIL pd
on pd.PERSON_UID = z.PERSON_UID

left outer join ( ODSMGR.PREVIOUS_EDUCATION pe
                  left outer join ODSMGR.INSTITUTION i
                  on i.INSTITUTION = pe.INSTITUTION )
on pe.PERSON_UID = z.PERSON_UID
and pe.INSTITUTION_TYPE = 'H'

left outer join ODSMGR.PREVIOUS_EDUCATION pec
on pec.PERSON_UID = z.PERSON_UID
and pec.INSTITUTION_TYPE = 'C'
and pec.INSTITUTION not in ('973400','973410','973420') --AP, CLEP, DSST (DANTES)

left outer join ODSMGR.RECRUITMENT_SOURCE rsc
on rsc.PERSON_UID = z.PERSON_UID
and substr(rsc.INSTITUTION,1,1) = 'C'

left outer join ODSMGR.ADDRESS_CURRENT ac
on ac.ENTITY_UID = z.PERSON_UID
and ac.ADDRESS_TYPE = 'PR'

                          left outer join ODSMGR.Z_ZIPCODE_RADIUS_TBL_VW zip
                          on zip.ZIPCODE_DESTINATION = substr(ac.POSTAL_CODE,1,5)
                          and zip.ZIPCODE_BASE = '55113'
                          and ac.NATION = 'US'
                          
inner join ODSMGR.ADMISSIONS_APPLICATION aa
on z.PERSON_UID = aa.PERSON_UID
and aa.COLLEGE = z.COLLEGE
and aa.STUDENT_LEVEL = z.STUDENT_LEVEL

left outer join COLLEGE_CHOICE
on COLLEGE_CHOICE.PERSON_UID = z.PERSON_UID

left outer join COLLEGE_PREFERENCE
on COLLEGE_PREFERENCE.PERSON_UID = z.PERSON_UID



where z.ACADEMIC_PERIOD like '20152%'
      and z.COLLEGE = 'TR'
      and z.WITHDRAWN_IND = 'N'
      and z.PRIMARY_PROGRAM_IND = 'Y'
      and aa.PRIMARY_PROGRAM_IND = 'Y'
      and ( rsc.RECRUIT_SOURCE_ACTIVITY_DATE  =  (select max(rsc1.RECRUIT_SOURCE_ACTIVITY_DATE)
                                                               from ODSMGR.RECRUITMENT_SOURCE rsc1
                                                               where rsc1.PERSON_UID = rsc.PERSON_UID
                                                                           and substr(rsc1.INSTITUTION,1,1) = 'C' )
                or rsc.ACADEMIC_PERIOD is null)                
      and aa.APPLICATION_NUMBER = (select max(aa1.APPLICATION_NUMBER)
                                                           from ADMISSIONS_APPLICATION aa1
                                                           where aa1.PERSON_UID = aa.PERSON_UID
                                                                       and aa1.COLLEGE = aa.COLLEGE
                                                                       and aa1.STUDENT_LEVEL = aa.STUDENT_LEVEL )
																																			 
order by 1