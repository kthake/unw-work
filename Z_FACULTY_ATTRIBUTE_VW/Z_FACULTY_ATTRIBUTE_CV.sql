SELECT SIRATTR_PIDM "PERSON_UID",
       SIRATTR_TERM_CODE_EFF "ACADEMIC_PERIOD_START",
       SUBSTR (GOKODSF.F_GET_DESC (SIRATTR_TERM_CODE_EFF, 'STVTERM'), 1, 30) "ACADEMIC_PERIOD_START_DESC",
       SUBSTR (
          SOKODSF.F_GET_END_SIRATTR_TERM (SIRATTR_PIDM,
                                          SIRATTR_TERM_CODE_EFF),
          1,
          6) "ACADEMIC_PERIOD_END",
       SUBSTR (
          GOKODSF.F_GET_DESC (
             SOKODSF.F_GET_END_SIRATTR_TERM (SIRATTR_PIDM,
                                             SIRATTR_TERM_CODE_EFF),
             'STVTERM'),
          1,
          30) "ACADEMIC_PERIOD_END_DESC",
       SIRATTR_FATT_CODE "FACULTY_ATTRIBUTE",
       SUBSTR (GOKODSF.F_GET_DESC (SIRATTR_FATT_CODE, 'STVFATT'), 1, 30) "FACULTY_ATTRIBUTE_DESC",
       --faculty attributes that are subject codes are being used to indicate which subjects an instructor can teach and at what level
       --faculty attribute subject example: ACCU - Accounting Undergradute level
       --used GOKODSF.F_GET_DESC to see if the first 3 letters of attribute are in STVSUBJ as validation step.
       CASE
          WHEN     GOKODSF.F_GET_DESC (SUBSTR (SIRATTR_FATT_CODE, 1, 3),
                                       'STVSUBJ')
                      IS NOT NULL
               AND SUBSTR (SIRATTR_FATT_CODE, -1) IN ('U', 'G')
          THEN
             SUBSTR (SIRATTR_FATT_CODE, 1, 3)
       END
          "QUALIFIED_SUBJECT", --subject that faculty member is qualified to teach
       --here we indicate at which level for the specific course the instructor is qualified to teach
       CASE
          WHEN     GOKODSF.F_GET_DESC (SUBSTR (SIRATTR_FATT_CODE, 1, 3),
                                       'STVSUBJ')
                      IS NOT NULL
               AND SUBSTR (SIRATTR_FATT_CODE, -1) IN ('U', 'G')
          THEN
             DECODE (SUBSTR (SIRATTR_FATT_CODE, -1),  'U', 'UG',  'G', 'GR')
       END
          "QUALIFIED_LEVEL", --the level for the associated subject that the faculty member is qualified to teach at
       --SIRCMNT_TEXT is to be utilized to show any comments relating to a specific subject that an instructor can teach
       SIRCMNT_TEXT "FACULTY_COMMENT",
       SYSDATE "CURRENT_DATE"
FROM SIRATTR

     LEFT OUTER JOIN SIRCMNT
        ON     SIRCMNT_PIDM = SIRATTR_PIDM
           AND SIRCMNT_TERM_CODE_EFF = SIRATTR_TERM_CODE_EFF
           AND SUBSTR (SIRCMNT_TEXT, 1, 4) =
                  SUBSTR (SIRATTR_FATT_CODE, 1, 4)
                 