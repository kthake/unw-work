select a1.PERSON_UID,
       a1.DATA_ORIGIN,
       decode(substr(a1.DATA_ORIGIN,1,1),1,'1-Registered Trad',
                                         2,'2-Registered PSOC',
                                         3,'3-Deposited Potential PSOC',
                                         4,'4-Deposited Trad but not registered') "DATA_ORIGIN_DESC",
       a1.ID,
       a1.NAME_LFMI,
       a1.GENDER,
       a1.BIRTH_DATE,
       a1.UNW_EMAIL,
       a1.CELL_PHONE,
       a1.PR_ADDRESS,
       a1.HOUSING_STATUS,
       a1.BUILDING_CODE,
       a1.BUILDING,
       a1.SECTION_ID,
       a1.ROOM,
       nvl(NWC.Z_FORMAT_NAME_FNC(a1.RD_PIDM,'PL'),' ') "RD_NAME",
       nvl(NWC.Z_FORMAT_NAME_FNC(a1.RA_PIDM,'PL'),' ') "RA_NAME",
       a1.RA_ROOM,
       a1.ARRIVAL_DOOR,
       a1.CHECKED_IN_DATE,
       a1.STUDENT_TYPE,
       a1.COLLEGE
from
--------------------------------------------------------------------------START a1
  (
  select a.PERSON_UID,
         listagg(a.DATA_ORIGIN,'; ') within group (order by a.DATA_ORIGIN asc) over (partition by a.PERSON_UID) "DATA_ORIGIN",
         --RMS_ID
         MGKFUNC.F_GET_PERSON_INFO(a.PERSON_UID,'ID') "ID",
         p.FULL_NAME_LFMI "NAME_LFMI",
         p.GENDER,
         p.BIRTH_DATE,
         substr(listagg(a.STUDENT_TYPE,'; ') within group (order by a.STUDENT_TYPE asc) over (partition by a.PERSON_UID),2,1) "STUDENT_TYPE",
         substr(listagg(a.COLLEGE,'; ') within group (order by a.COLLEGE asc) over (partition by a.PERSON_UID),2,2) "COLLEGE",
         ODSMGR.Z_GET_EMAIL_FNC(a.PERSON_UID,'NWC') "UNW_EMAIL",
         NWC.Z_GET_CURRENT_PHONE_FNC(a.PERSON_UID,'MOBL') "CELL_PHONE",
         NWC.Z_GET_CONCAT_ADDR_UNWSP_PKG.Z_GET_CURR_ADDR_OF_TYPE_FNC(a.PERSON_UID,'PR') "PR_ADDRESS",
         nvl(r.BLDG_CODE,' ') "BUILDING_CODE",
         nvl(MGKFUNC.F_GET_DESC('STVBLDG', r.BLDG_CODE),' ') "BUILDING",
         nvl(r.PARTITION,' ') "SECTION_ID",
         nvl(h.ROOM,' ') "ROOM", --add indication of DE?
         NWC.Z_GET_POSITION_INCUMBENT_FNC(b.RD_POSITION) "RD_PIDM",
         act.PERSON_UID "RA_PIDM",
         nvl(h1.ROOM,' ') "RA_ROOM",
         nvl(to_char(to_date(h.ARRIVAL_DATE, 'mm/dd/yyyy hh:mi:ss am'),'mm/dd/yyyy'), ' ') "CHECKED_IN_DATE",
         nvl(d.SLRRDEF_RDEF_CODE,' ') "ARRIVAL_DOOR",
         decode(substr(h.ROOM,1,2),null,'NOT BOOKED',
                                   'OF','COMMUTER',
                                   'OU','OUT',
                                   'WL','WAIT-LIST',
                                        'RESIDENT') "HOUSING_STATUS"



  from
--------------------------------------------------------------------------START a
    (
    --GET STUDENTS REGISTERED FOR UPCOMING TERM

    select distinct z.PERSON_UID,
                    '1'||z.STUDENT_TYPE "STUDENT_TYPE",
                    '1'||z.COLLEGE "COLLEGE",
                    z.ACADEMIC_PERIOD_MOD,
                    case when z.COLLEGE = 'DE' and z.TRAD_CREDITS > 0
                         then 2
                         else 1
                    end "DATA_ORIGIN"

    from ODSMGR.Z_ACADEMIC_STUDY_VW z
    where z.ACADEMIC_PERIOD_MOD = :ddTerm.MOD
          and z.WITHDRAWN_IND = 'N'
          and z.PRIMARY_PROGRAM_IND = 'Y'
          and ( z.COLLEGE = 'TR'
             or (z.COLLEGE = 'DE' and z.TRAD_CREDITS > 0) )

    union

    --GET NEW STUDENTS THAT MAY NOT BE REGISTERED IN TRAD AND POTENTIAL PSOC STUDENTS
    select distinct aa.PERSON_UID,
                    '2'||aa.STUDENT_POPULATION,
                    '2'||aa.COLLEGE,
                    substr(aa.ACADEMIC_PERIOD,1,5),
                    nvl2(att.PERSON_UID,3,4)
    from ODSMGR.ADMISSIONS_APPLICATION aa

          left outer join ODSMGR.ADMISSIONS_ATTRIBUTE att
          on att.PERSON_UID = aa.PERSON_UID
          and att.ACADEMIC_PERIOD = aa.ACADEMIC_PERIOD
          and att.APPLICATION_NUMBER = aa.APPLICATION_NUMBER
          and att.ADMISSIONS_ATTRIBUTE = 'PSOC'

    where substr(aa.ACADEMIC_PERIOD,1,5) = :ddTerm.MOD
          and ( aa.COLLEGE = 'TR'
                or (aa.COLLEGE = 'DE' and att.PERSON_UID is not null ) )
          and aa.LATEST_DECISION between '35' and '80'
          and substr(aa.LATEST_DECISION,1,1) <> '5'
    ) a
--------------------------------------------------------------------------END a

    left outer join ODSMGR.Z_PERSON_NAME_VW p  --GENDER AND BIRTHDATE
    on p.PERSON_UID = a.PERSON_UID

    left outer join ODSMGR.Z_RMS_HOUSING_VW h --RMS DATA
    on h.PERSON_UID = a.PERSON_UID
    and substr(h.BANNER_TERM_CODE,1,5) = a.ACADEMIC_PERIOD_MOD

                    left outer join ODSMGR.Z_ROOM_DEFINITION_VW r --BUILDING AND PARTITION/SECTION ID
                    on r.ROOM_NUMBER = h.ROOM

                                    left outer join ODSMGR.Z_BUILDING_VW b --RD POSITION CODE
                                    on b.BUILDING = r.BLDG_CODE

                                    left outer join (ODSMGR.STUDENT_ACTIVITY act  --GET RA INFORMATION
                                                     inner join (ODSMGR.Z_RMS_HOUSING_VW h1
                                                                 inner join ODSMGR.Z_ROOM_DEFINITION_VW r1
                                                                 on r1.ROOM_NUMBER = h1.ROOM)
                                                     on h1.PERSON_UID = act.PERSON_UID
                                                     and act.ACTIVITY = 'RA'
                                                     and substr(h1.BANNER_TERM_CODE,1,5) = substr(act.ACADEMIC_PERIOD,1,5) )
                                    on substr(act.ACADEMIC_PERIOD,1,5) = substr(h.BANNER_TERM_CODE,1,5)
                                    and r1.PARTITION = r.PARTITION

                    left outer join SATURN.SLRRDEF d  --ARRIVAL DOOR
                    on d.SLRRDEF_ROOM_NUMBER = h.ROOM
                    and substr(MGKFUNC.F_GET_DESC('STVRDEF',d.SLRRDEF_RDEF_CODE),1,7) = 'Arrival'

  ) a1
--------------------------------------------------------------------------END a1

where :bt_view is not null