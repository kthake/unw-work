--updated 8/2/2016 KTH - 
--Changed all instances of views to their base tables except for z_total_credits_by_collage_vw
--Primary program indicator/program number wwere being calculated incorrectly and are now being selected from MST_BASE_STUDENT
--Changed cohort logic
--Updated base student population selection so query runs much faster. Now only takes just under 2 minutes to run the whole script

SELECT DISTINCT
          Z.PERSON_UID,
          MGKFUNC.F_GET_PERSON_INFO (Z.PERSON_UID, 'ID') "ID",
          NWC.Z_FORMAT_NAME_FNC (Z.PERSON_UID, 'LFMI') "NAME",
          Z.ACADEMIC_YEAR,
          Z.ACADEMIC_YEAR_DESC,
          Z.ACADEMIC_PERIOD,
          GOKODSF.F_GET_DESC (Z.ACADEMIC_PERIOD, 'STVTERM')
             "ACADEMIC_PERIOD_DESC",
          Z.ACADEMIC_PERIOD_MOD,
          Z.BLOCK_SCHEDULE,
          GOKODSF.F_GET_DESC (Z.BLOCK_SCHEDULE, 'STVBLCK')
             "BLOCK_SCHEDULE_DESC",
          Z.STUDENT_LEVEL,
          GOKODSF.F_GET_DESC (Z.STUDENT_LEVEL, 'STVLEVL')
             "STUDENT_LEVEL_DESC",
          Z.COLLEGE,
          GOKODSF.F_GET_DESC (Z.COLLEGE, 'STVCOLL') "COLLEGE_DESC",
          Z.STUDENT_TYPE,
          GOKODSF.F_GET_DESC (Z.STUDENT_TYPE, 'STVSTYP') "STUDENT_TYPE_DESC",
          I.DEGREE,
          I.DEGREE_DESC,
          I.PROGRAM,
          I.PROGRAM_DESC,
          I.PROGRAM_NUMBER,
          I.PRIMARY_PROGRAM_IND,
          I.PROGRAM_CLASSIFICATION,
          I.PROGRAM_CLASSIFICATION_DESC,
          I.GRAD_ACADEMIC_PERIOD_INTENDED,
          I.GRAD_ACAD_PERIOD_INTENDED_DESC,
          I.MAJOR,
          I.MAJOR_DESC,
          I.SECOND_MAJOR,
          I.SECOND_MAJOR_DESC,
          I.DEPARTMENT,
          I.DEPARTMENT_DESC,
          I.FIRST_CONCENTRATION,
          I.FIRST_CONCENTRATION_DESC,
          I.FIRST_MINOR,
          I.FIRST_MINOR_DESC,
          I.SECOND_MINOR,
          I.SECOND_MINOR_DESC,
          I.THIRD_MINOR,
          I.THIRD_MINOR_DESC,
          F.COHORT,
          F.COHORT_DESC,
          SOKODSF.F_CLASS_CALC_FNC (Z.PERSON_UID,
                                    Z.STUDENT_LEVEL,
                                    Z.ACADEMIC_PERIOD)
             "STUDENT_CLASSIFICATION",
          GOKODSF.F_GET_DESC (
             SOKODSF.F_CLASS_CALC_FNC (Z.PERSON_UID,
                                       Z.STUDENT_LEVEL,
                                       Z.ACADEMIC_PERIOD),
             'STVCLAS')
             "STUDENT_CLASSIFICATION_DESC",
          SOKODSF.F_CLASS_CODE (Z.PERSON_UID,
                                Z.STUDENT_LEVEL,
                                Z.ACADEMIC_PERIOD)
             "STUDENT_CLASSIFICATION_BOAP",
          GOKODSF.F_GET_DESC (
             SOKODSF.F_CLASS_CODE (Z.PERSON_UID,
                                   Z.STUDENT_LEVEL,
                                   Z.ACADEMIC_PERIOD),
             'STVCLAS')
             "STUDENT_CLASS_BOAP_DESC",
          H.ADVISOR_UID "PRIMARY_ADVISOR_PERSON_UID",
          NWC.Z_FORMAT_NAME_FNC (H.ADVISOR_UID, 'LFMI')
             "PRIMARY_ADVISOR_NAME_LFMI",
          NVL (D.ACADEMIC_STANDING,
               MSKFUNC.F_ACADEMIC_STAND_DATA (Z.PERSON_UID,
                                              Z.ACADEMIC_PERIOD,
                                              Z.STUDENT_LEVEL,
                                              'ACADEMIC_STANDING'))
             "ACADEMIC_STANDING",
          NVL (D.ACADEMIC_STANDING_DESC,
               MSKFUNC.F_ACADEMIC_STAND_DATA (Z.PERSON_UID,
                                              Z.ACADEMIC_PERIOD,
                                              Z.STUDENT_LEVEL,
                                              'ACADEMIC_STANDING_DESC'))
             "ACADEMIC_STANDING_DESC",
          NVL (D.ACADEMIC_STANDING_END_DT,
               MSKFUNC.F_ACADEMIC_STAND_DATA (Z.PERSON_UID,
                                              Z.ACADEMIC_PERIOD,
                                              Z.STUDENT_LEVEL,
                                              'ACADEMIC_STANDING_END_DT'))
             "ACADEMIC_STANDING_END_DATE",
          D.ACADEMIC_STANDING_END,
          D.ACAD_STANDING_END_DESC "ACADEMIC_STANDING_END_DESC",
          (SELECT Z_STVDEPT_TBL.UNW_COLLEGE
             FROM ODSMGR.Z_STVDEPT_TBL
            WHERE Z_STVDEPT_TBL.STVDEPT_CODE = I.DEPARTMENT)
             "UNW_COLLEGE",
          CEIL (
               (SELECT COUNT (
                          DISTINCT CASE
                                      WHEN     GS.COLLEGE IN ('TR', 'DE')
                                           AND SUBSTR (GS.ACADEMIC_PERIOD,
                                                       5,
                                                       1) IN
                                                  ('1', '2')
                                      THEN
                                         SUBSTR (GS.ACADEMIC_PERIOD, 1, 5)
                                      WHEN GS.COLLEGE IN ('FC', 'GS')
                                      THEN
                                         SUBSTR (GS.ACADEMIC_PERIOD, 1, 5)
                                      ELSE
                                         NULL
                                   END)
                  FROM ODSMGR.MST_GENERAL_STUDENT GS
                       INNER JOIN ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TCBC
                          ON     GS.PERSON_UID = TCBC.PERSON_UID
                             AND SUBSTR (GS.ACADEMIC_PERIOD, 1, 5) =
                                    TCBC.ACADEMIC_PERIOD_MOD
                             AND TCBC.COURSE_COUNT_REG + TCBC.COURSE_COUNT_W >
                                    0
                 WHERE     GS.PERSON_UID = Z.PERSON_UID
                       AND TCBC.ACADEMIC_PERIOD_MOD <=
                              SUBSTR (Z.ACADEMIC_PERIOD, 1, 5)
                       AND GS.COLLEGE = Z.COLLEGE
                       AND GS.PRIMARY_PROGRAM_IND = 'Y')
             / CASE WHEN Z.COLLEGE IN ('TR', 'DE') THEN 2 ELSE 3 END)
             "YEAR_AT_UNW",
          I.CATALOG "CATALOG_ACADEMIC_PERIOD",
          I.CATALOG_ACADEMIC_PERIOD_DESC "CATALOG_ACADEMIC_PERIOD_DESC",
          Z.TOTAL_CREDITS,
          Z.TRAD_CREDITS,
          Z.DE_CREDITS,
          Z.FC_CREDITS,
          Z.GS_CREDITS,
          Z.FIN_AID_REG_CREDITS,
          Z.UNW_OFF_CAMPUS_CREDITS,
          Z.CIS_CREDITS,
          Z.ECOL_CREDITS,
          Z.PSEO_ONLINE_CREDITS,
          Z.PSOS_CREDITS,
          Z.UOL_ADULT_CREDITS,
          Z.AUDIT_CREDITS,
          Z.TOTAL_CREDITS_W,
          G.ADDITIONAL_ID "MARSS_NUMBER",
          CASE
             WHEN NVL (Z.TOTAL_CREDITS, 0) = 0
             THEN
                'NT'
             WHEN (Z.STUDENT_LEVEL = 'GR' AND Z.TOTAL_CREDITS >= 9)
             THEN
                'FT'
             WHEN (Z.STUDENT_LEVEL = 'UG' AND Z.TOTAL_CREDITS >= 12)
             THEN
                'FT'
             ELSE
                'PT'
          END
             "FTPT_IND",
          CASE
             WHEN Z.TOTAL_CREDITS = 0 AND Z.TOTAL_CREDITS_W > 0 THEN 'Y'
             ELSE 'N'
          END
             "WITHDRAWN_IND",
          NVL (
             (SELECT 'Y'
                FROM DUAL
               WHERE    EXISTS
                           (SELECT AO.STATUS
                              FROM ODSMGR.MST_ACADEMIC_OUTCOME AO
                             WHERE     Z.PERSON_UID = AO.PERSON_UID
                                   AND AO.STATUS IN ('AP', 'AW')
                                   AND (AO.ACADEMIC_PERIOD_GRADUATION <
                                           (CASE
                                               WHEN SUBSTR (
                                                       Z.ACADEMIC_PERIOD,
                                                       5,
                                                       1) = '1'
                                               THEN
                                                  Z.ACADEMIC_PERIOD + 10
                                               WHEN SUBSTR (
                                                       Z.ACADEMIC_PERIOD,
                                                       5,
                                                       1) = '2'
                                               THEN
                                                  Z.ACADEMIC_PERIOD + 90
                                               WHEN SUBSTR (
                                                       Z.ACADEMIC_PERIOD,
                                                       5,
                                                       1) = '3'
                                               THEN
                                                  Z.ACADEMIC_PERIOD + 80
                                            END))
                                   AND AO.COLLEGE = Z.COLLEGE
                                   AND AO.PROGRAM = I.PROGRAM)
                     OR EXISTS
                           (SELECT SA.PERSON_UID
                              FROM ODSMGR.MST_STUDENT_ATTRIBUTE SA
                             WHERE     SA.PERSON_UID = Z.PERSON_UID
                                   AND Z.ACADEMIC_PERIOD_MOD BETWEEN SUBSTR(SA.ACADEMIC_PERIOD_START,1,5) AND SUBSTR(SA.ACADEMIC_PERIOD_END,1,5)
                                   AND SA.STUDENT_ATTRIBUTE = 'REGR')),
             'N')
             "COMPLETION_IND"
  FROM -------------------------------------------------BEGIN MAIN STUDENT POPULATION SELECTION
		  (
           SELECT DISTINCT
                  B.SGBSTDN_PIDM "PERSON_UID",
                     A.ACADEMIC_PERIOD_MOD
                  || CASE
                        WHEN B.SGBSTDN_COLL_CODE_1 IN ('FC', 'GS') THEN '5'
                        ELSE '0'
                     END
                     "ACADEMIC_PERIOD", --HERE WE CREATE THE ACADEMIC PERIOD 0 END FOR TR,DE AND 5 END FOR FC,GS
                  A.ACADEMIC_PERIOD_MOD,
                  B.SGBSTDN_LEVL_CODE "STUDENT_LEVEL",
                  B.SGBSTDN_COLL_CODE_1 "COLLEGE",
                  B.SGBSTDN_STYP_CODE "STUDENT_TYPE",
                  B.SGBSTDN_BLCK_CODE "BLOCK_SCHEDULE",
                  B.SGBSTDN_TERM_CODE_EFF "ACADEMIC_PERIOD_START",
                  A.ACADEMIC_YEAR,
                  A.ACADEMIC_YEAR_DESC,
                  A.TOTAL_CREDITS,
                  A.TRAD_CREDITS,
                  A.DE_CREDITS,
                  A.FC_CREDITS,
                  A.GS_CREDITS,
                  A.FIN_AID_REG_CREDITS,
                  A.UNW_OFF_CAMPUS_CREDITS,
                  A.CIS_CREDITS,
                  A.ECOL_CREDITS,
                  A.PSEO_ONLINE_CREDITS,
                  A.PSOS_CREDITS,
                  A.UOL_ADULT_CREDITS,
                  A.AUDIT_CREDITS,
                  A.TOTAL_CREDITS_W
             FROM ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW A
                  INNER JOIN SATURN.SGBSTDN B
                  ON B.SGBSTDN_PIDM = A.PERSON_UID
                  AND A.COURSE_COUNT_REG + A.COURSE_COUNT_W > 0
                     
            WHERE      B.SGBSTDN_TERM_CODE_EFF =
                               (SELECT MAX (B2.SGBSTDN_TERM_CODE_EFF)
                                  FROM SATURN.SGBSTDN B2
                                       LEFT OUTER JOIN SATURN.SGBSTDN B3 --MOVED FROM SUBQUERY TO JOIN TO SPEED UP QUERY. ONLY USED IN SECTION NVL2(B3.SGBSTDN_PIDM,'5','0')
                                       ON B3.SGBSTDN_PIDM = B2.SGBSTDN_PIDM
                                       AND SUBSTR (B3.SGBSTDN_TERM_CODE_EFF,1,5) = SUBSTR (B2.SGBSTDN_TERM_CODE_EFF,1,5)
                                       AND B3.SGBSTDN_COLL_CODE_1 IN ('GS','FC')
                                       AND SUBSTR (B3.SGBSTDN_TERM_CODE_EFF,-1) = '5'
                                       
                                 WHERE     B2.SGBSTDN_PIDM = B.SGBSTDN_PIDM
                                       AND SUBSTR (B2.SGBSTDN_TERM_CODE_EFF,
                                                   1,
                                                   5) <=
                                              A.ACADEMIC_PERIOD_MOD
                                       AND (       B2.SGBSTDN_COLL_CODE_1 IN
                                                      ('TR', 'DE')
                                               AND SUBSTR (B2.SGBSTDN_TERM_CODE_EFF,
                                                           -1) =
                                                      '0'
                                            OR (    B2.SGBSTDN_COLL_CODE_1 IN
                                                       ('GS', 'FC')
                                                AND SUBSTR (B2.SGBSTDN_TERM_CODE_EFF,
                                                            -1) = NVL2(B3.SGBSTDN_PIDM,'5','0') )))
            
                      AND A.PERSON_UID NOT IN (1305,
                                               908505,
                                               962030,
                                               923031,
                                               962032)               --DUMMY PIDMS
          ) Z,  
          -------------------------------------------------END MAIN STUDENT POPULATION SELECTION
		  
     --GRAB ADDITIONAL DATA, IF EXISTS
          MST_ACADEMIC_STANDING D,                    --TO GET ACADEMIC STANDING
          --JOIN 'E' WAS DELETED
          (SELECT PERSON_UID,
                  ACADEMIC_PERIOD_START,
                  ACADEMIC_PERIOD_END,
                  COHORT,
                  COHORT_DESC
           FROM ODSMGR.MST_STUDENT_COHORT SC1
           WHERE COHORT_ACTIVE_IND = 'Y'
                 AND SC1.COHORT = (SELECT MAX(COHORT)
                                   FROM ODSMGR.MST_STUDENT_COHORT SC2
                                   WHERE SC2.PERSON_UID = SC1.PERSON_UID
                                         AND SC2.ACADEMIC_PERIOD_START = SC1.ACADEMIC_PERIOD_START
                                         AND SC2.ACADEMIC_PERIOD_END = SC1.ACADEMIC_PERIOD_END
                                         AND SC2.COHORT_ACTIVE_IND = SC1.COHORT_ACTIVE_IND)
          ) F,                                        --TO GET COHORT
          ODSMGR.Z_MGT_ADDTNL_IDENTIFICATION G,       --TO GET MARSS NUMBER
          ODSMGR.MST_ADVISOR H,                       --TO GET PRIMARY ADVISOR
          ODSMGR.MST_BASE_STUDENT I --TO GET PROGRAM, MAJORS, DEGREE, PROGRAM_CLASSIFICATION, PRIMARY PROGRAM IND, CATALOG, DEPARTMENT, MINORS, INTENDED GRAD TERM

    WHERE Z.ACADEMIC_PERIOD_MOD >= '20071'
          --MST_ACADEMIC_STANDING
	        AND D.PERSON_UID(+) = Z.PERSON_UID
          AND D.ACADEMIC_PERIOD(+) = Z.ACADEMIC_PERIOD
          --MST_STUDENT_COHORT
          AND F.PERSON_UID(+) = Z.PERSON_UID
          AND Z.ACADEMIC_PERIOD BETWEEN F.ACADEMIC_PERIOD_START(+)
                                    AND F.ACADEMIC_PERIOD_END(+)
          --Z_MGT_ADDTNL_IDENTIFICATION
          AND G.PIDM(+) = Z.PERSON_UID
          AND G.ADDITIONAL_ID_CODE(+) = 'MARS'
          --MST_ADVISOR
          AND H.PERSON_UID(+) = Z.PERSON_UID
          AND Z.ACADEMIC_PERIOD BETWEEN H.ACADEMIC_PERIOD_START(+)
                                    AND H.ACADEMIC_PERIOD_END(+)
          AND H.PRIMARY_ADVISOR_IND(+) = 'Y'
          --MST_BASE_STUDENT
          AND I.PERSON_UID(+) = Z.PERSON_UID
          AND I.ACADEMIC_PERIOD_START(+) = Z.ACADEMIC_PERIOD_START
         