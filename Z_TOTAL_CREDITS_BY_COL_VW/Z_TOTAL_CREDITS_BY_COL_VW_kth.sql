DROP VIEW ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW;

/* Formatted on 3/30/2016 3:15:30 PM (QP5 v5.256.13226.35538) */
CREATE OR REPLACE FORCE VIEW ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW
(
   PERSON_UID,
   ACADEMIC_YEAR,
   ACADEMIC_YEAR_DESC,
   ACADEMIC_PERIOD_MOD,
   ACADEMIC_PERIOD_DESC_MOD,
   TRAD_CREDITS,
   DE_CREDITS,
   FC_CREDITS,
   GS_CREDITS,
   --FCGS_TOTAL_CREDITS, removed KTH
   TOTAL_CREDITS,
   TRAD_CREDITS_W,
   DE_CREDITS_W,
   FC_CREDITS_W,
   GS_CREDITS_W,
   --FCGS_TOTAL_CREDITS_W, removed KTH
   TOTAL_CREDITS_W,
   ECOL_CREDITS,
   ECOL_CREDITS_W,
   PSEO_ONLINE_CREDITS,
   PSEO_ONLINE_CREDITS_W,
   PSOS_CREDITS,
   PSOS_CREDITS_W,
   CIS_CREDITS,
   CIS_CREDITS_W,
   UOL_ADULT_CREDITS,
   UOL_ADULT_CREDITS_W,
   --TRAD_CR_LOAD_CREDITS, removed KTH
   --TRAD_CR_LOAD_CREDITS_W, removed KTH
   --TUIT_FREE_TRANSFER_CREDITS, removed KTH
   --TUIT_FREE_TRANSFER_CREDITS_W, removed KTH
   --FORMER_PSEO_STUDENT_CREDITS, removed KTH
   --FORMER_PSEO_STUDENT_CREDITS_W, removed KTH 
   FIN_AID_REG_CREDITS,
   AUDIT_CREDITS,
   UNW_OFF_CAMPUS_CREDITS,
   COURSE_COUNT_REG, --addition KTH
   COURSE_COUNT_W  --addition KTH
   /*,
   COURSE_COUNT_REG,
   COURSE_COUNT_W
   */
)
AS
   SELECT person_uid,
          academic_year,
          academic_year_desc,
          academic_period_mod,
          academic_period_desc_mod,
          trad_credits,
          de_credits,
          fc_credits,
          gs_credits,
          --fcgs_total_credits, removed KTH
          total_credits,
          trad_credits_w,
          de_credits_w,
          fc_credits_w,
          gs_credits_w,
          --fcgs_total_credits_w, removed KTH
          total_credits_w,
          ecol_credits,
          ecol_credits_w,
          pseo_credits, --updated KTH
          pseo_credits_w, --updated KTH
          psos_credits,
          psos_credits_w,
          cis_credits,
          cis_credits_w,
          uol_adult_credits,
          uol_adult_credits_w,
          --trad_cr_load_credits, removed KTH 
          --trad_cr_load_credits_w, removed KTH
          --tuit_free_transfer_credits, removed KTH
          --tuit_free_transfer_credits_w, removed KTH
          --former_pseo_student_credits, removed KTH
          --former_pseo_student_credits_w, removed KTH
          fin_aid_reg_credits,
          audit_credits,
          unw_off_campus_credits,
          course_count_reg, --addition KTH
          course_count_w --addition KTH
          /* JWHEELER 3/30/2016 remove last two columns from view
             now getting this column data from odssrc.z_total_credits_by_col_cv,
          (SELECT SUM (
                     CASE
                        WHEN     registration_status IN ('RE', 'RW')
                             AND transfer_course_ind = 'N'
                             AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                             AND course_identification NOT LIKE 'FOC%' -- Exclude  those registered in classes in a study abroad program
                             AND course_identification NOT LIKE 'REG%' -- Exclude  those registered in classes in a study abroad program
                        THEN
                           1
                        WHEN     registration_status IN ('RE', 'RW')
                             AND transfer_course_ind = 'N'
                             AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                             AND course_identification = 'REG3000' -- Include off campus credits
                        THEN
                           1
                        WHEN     registration_status IN ('OD')
                             AND transfer_course_ind = 'N'
                             AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                             AND course_identification = 'REG3000' -- Include off campus credits
                        THEN
                           1
                        ELSE
                           0
                     END)
             FROM mst_student_course
            WHERE     person_uid = otab.person_uid
                  AND SUBSTR (academic_period, 1, 5) =
                         otab.academic_period_mod
                  AND (CASE
                          WHEN SUBSTR (academic_period, 5, 1) = 1
                          THEN
                             'Fall ' || SUBSTR (academic_period, 1, 4)
                          WHEN SUBSTR (academic_period, 5, 1) = 2
                          THEN
                                'Spring '
                             || (SUBSTR (academic_period, 1, 4) + 1)
                          WHEN SUBSTR (academic_period, 5, 1) = 3
                          THEN
                                'Summer '
                             || (SUBSTR (academic_period, 1, 4) + 1)
                       END) = otab.academic_period_desc_mod),
          (SELECT SUM (CASE
                          WHEN     registration_status IN ('3X',
                                                           '6X',
                                                           'AW',
                                                           'FW',
                                                           'FX',
                                                           'PW',
                                                           'PX',
                                                           'WC',
                                                           'WW',
                                                           'WX')
                               AND transfer_course_ind = 'N'
                               AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                               AND course_identification NOT LIKE 'FOC%' -- Exclude  those registered in classes in a study abroad program
                               AND course_identification NOT LIKE 'REG%' -- Exclude  those registered in classes in a study abroad program
                          THEN
                             1
                          ELSE
                             0
                       END)
             FROM mst_student_course
            WHERE     person_uid = otab.person_uid
                  AND SUBSTR (academic_period, 1, 5) =
                         otab.academic_period_mod
                  AND (CASE
                          WHEN SUBSTR (academic_period, 5, 1) = 1
                          THEN
                             'Fall ' || SUBSTR (academic_period, 1, 4)
                          WHEN SUBSTR (academic_period, 5, 1) = 2
                          THEN
                                'Spring '
                             || (SUBSTR (academic_period, 1, 4) + 1)
                          WHEN SUBSTR (academic_period, 5, 1) = 3
                          THEN
                                'Summer '
                             || (SUBSTR (academic_period, 1, 4) + 1)
                       END) = otab.academic_period_desc_mod) 
                       */
     FROM z_tot_crd_by_col_tbl otab;

   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."PERSON_UID" IS 'PIDM';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ACADEMIC_YEAR" IS 'Term';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ACADEMIC_YEAR_DESC" IS 'Term Description';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ACADEMIC_PERIOD_MOD" IS 'Term without final 0/5';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ACADEMIC_PERIOD_DESC_MOD" IS 'Description of shortened term code';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."TRAD_CREDITS" IS 'Traditional Credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."DE_CREDITS" IS 'DE Credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."FC_CREDITS" IS 'FOCUS Credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."GS_CREDITS" IS 'Graduate Credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."TOTAL_CREDITS" IS 'Total of all registered credits. Includes TR,DE,FC,GS credits and excludes transfer and audit courses';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."TRAD_CREDITS_W" IS 'TRAD withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."DE_CREDITS_W" IS 'DE withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."FC_CREDITS_W" IS 'FC withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."GS_CREDITS_W" IS 'Graduate withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."TOTAL_CREDITS_W" IS 'Total Credits withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ECOL_CREDITS" IS 'Early College credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."ECOL_CREDITS_W" IS 'Early College withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."PSEO_ONLINE_CREDITS" IS 'PSEO Online credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."PSEO_ONLINE_CREDITS_W" IS 'PSEO Online withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."PSOS_CREDITS" IS 'PSOS credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."PSOS_CREDITS_W" IS 'PSOS withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."CIS_CREDITS" IS 'CIS Credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."CIS_CREDITS_W" IS 'CIS withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."UOL_ADULT_CREDITS" IS 'UOL Adult credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."UOL_ADULT_CREDITS_W" IS 'UOL Adult withdrawn credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."FIN_AID_REG_CREDITS" IS 'All courses with subject of REG';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."AUDIT_CREDITS" IS 'Audit credits';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."UNW_OFF_CAMPUS_CREDITS" IS 'Credits with course department of OFFC';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."COURSE_COUNT_REG" IS 'Total number of courses registered. This includes audits, REG, and OFFC courses';
   COMMENT ON COLUMN "ODSMGR"."Z_TOTAL_CREDITS_BY_COL_VW"."COURSE_COUNT_W" IS 'total number of courses withdrawn'; 


CREATE OR REPLACE PUBLIC SYNONYM Z_TOTAL_CREDITS_BY_COL FOR ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW;


GRANT SELECT ON ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TO BANWORX;

GRANT SELECT ON ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TO DEVROLE;

GRANT SELECT ON ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TO NWC;

GRANT SELECT ON ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TO ODSQRY_RPTROLE;

GRANT SELECT ON ODSMGR.Z_TOTAL_CREDITS_BY_COL_VW TO ODS_RPTROLE;
