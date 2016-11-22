SELECT person_uid,
            academic_year,
            academic_year_desc,
            SUBSTR (academic_period, 1, 5) "ACADEMIC_PERIOD_MOD",
            GOKODSF.F_GET_DESC(SUBSTR (academic_period, 1, 5)||'0', 'STVTERM') "ACADEMIC_PERIOD_DESC_MOD",
            SUM (CASE
                    WHEN     registration_status IN ('RE', 'RW')
                         AND sub_academic_period IN ('Q1','Q2','Q3','Q4','1','E','NE') -- added 'NE' CHG00044084
                         AND transfer_course_ind = 'N'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                         AND subject <> 'REG'
                         AND course_department <> 'OFFC'
     
                    THEN
                       course_credits
                    ELSE 0
                 END)
               "TRAD_CREDITS",
            SUM (CASE
                    WHEN    registration_status IN ('RE', 'RW')
                         AND transfer_course_ind = 'N'
                         AND (   sub_academic_period IN ('DE','DEI','DEO','IN1','IN2','IN3','IN4')
                              OR sub_academic_period LIKE 'H%'
                              OR sub_academic_period LIKE 'S%')
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                         AND subject <> 'REG'
                         AND course_department <> 'OFFC'
                    THEN
                       course_credits
                    ELSE 0
                 END)
               "DE_CREDITS",
            SUM (
                     CASE
                        WHEN     registration_status IN ('RE', 'RW')
                             AND course_college = 'FC'
                             AND course_level = 'UG'
                             AND transfer_course_ind = 'N'
                             AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                             AND subject <> 'REG'
                             AND course_department <> 'OFFC'
                             

                        THEN
                           course_credits
                        ELSE 0
                     END

               )
               "FC_CREDITS",
            SUM (
               CASE
                  WHEN     registration_status IN ('RE', 'RW')
                       AND course_college = 'GS'
                       AND course_level = 'GR'
                       AND transfer_course_ind = 'N'
                       AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                       AND subject <> 'REG'
                       AND course_department <> 'OFFC'  
                  THEN
                     course_credits
                  ELSE 0
               END)
               "GS_CREDITS",
            SUM (
               CASE
                  WHEN    registration_status IN ('RE', 'RW')
                       AND transfer_course_ind = 'N'
                       AND grade_type  NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                  THEN
                     course_credits
                  WHEN     registration_status IN ('OD')
                       AND transfer_course_ind = 'N'
                       AND grade_type  NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                  THEN
                     course_billing_credits
                  ELSE 0
               END)
               "TOTAL_CREDITS",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND sub_academic_period IN ('Q1','Q2','Q3','Q4','1','E','NE') -- 'NE' added CHG00044084
                         AND transfer_course_ind = 'N'
                         AND grade_type  NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "TRAD_CREDITS_W",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND (   sub_academic_period IN ('DE','DEI','DEO','IN1','IN2','IN3','IN4')
                              OR sub_academic_period LIKE 'H%'
                              OR sub_academic_period LIKE 'S%')
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                         AND subject <> 'REG' 
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "DE_CREDITS_W",
            SUM (
                       CASE
                          WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                               AND course_college = 'FC'
                               AND course_level = 'UG'
                               AND transfer_course_ind = 'N'
                               AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
                          THEN
                             credits_attempted
                          ELSE 0
                       END
                 )
               "FC_CREDITS_W",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND course_college = 'GS'
                         AND course_level = 'GR'
                         AND transfer_course_ind = 'N'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses 
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "GS_CREDITS_W",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses
    
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "TOTAL_CREDITS_W",
            SUM (
               CASE
                  WHEN    registration_status IN ('RE', 'RW')
                       AND transfer_course_ind = 'N'
                       AND sub_academic_period IN ('DE', 'DEI', 'DEO')
                       AND SUBSTR (academic_period, 6, 1) = '0'
                       AND (   course_section_number LIKE 'E%'
                            OR course_section_number LIKE 'X%')
                       AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses      
                  THEN
                     course_credits
                  ELSE 0
               END)
               "ECOL_CREDITS",
            SUM (
               CASE
                  WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                       AND transfer_course_ind = 'N'
                       AND sub_academic_period IN ('DE', 'DEI', 'DEO')
                       AND SUBSTR (academic_period, 6, 1) = '0'
                       AND (   course_section_number LIKE 'E%'
                            OR course_section_number LIKE 'X%')
                       AND grade_type  NOT IN ('T', 'A') --Exclude Transfer and Audit Courses    
                  THEN
                     credits_attempted
                  ELSE 0
               END)
               "ECOL_CREDITS_W",
            SUM (
               CASE
                  WHEN    registration_status IN ('RE', 'RW')
                       AND transfer_course_ind = 'N'
                       AND sub_academic_period IN ('DE', 'DEI', 'DEO')
                       AND SUBSTR (academic_period, 6, 1) = '0'
                       AND course_section_number LIKE 'P%'
                       AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses      
                  THEN
                     course_credits
                  ELSE 0
               END)
               "PSEO_CREDITS",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND sub_academic_period IN ('DE', 'DEI', 'DEO')
                         AND SUBSTR (academic_period, 6, 1) = '0'
                         AND course_section_number LIKE 'P%'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses    
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "PSEO_CREDITS_W",
            SUM (
               CASE
                  WHEN    registration_status IN ('RE', 'RW')
                       AND transfer_course_ind = 'N'
                       AND sub_academic_period LIKE 'S%'
                       AND SUBSTR (academic_period, 6, 1) = '0'
                       AND course_section_number LIKE 'S%'
                       AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses 
                  THEN
                     course_credits
                  ELSE 0
               END)
               "PSOS_CREDITS",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND sub_academic_period LIKE 'S%'
                         AND SUBSTR (academic_period, 6, 1) = '0'
                         AND course_section_number LIKE 'S%'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses    
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "PSOS_CREDITS_W",
            SUM (
               CASE
                  WHEN     registration_status IN ('RE', 'RW')
                       AND transfer_course_ind = 'N'
                       AND sub_academic_period LIKE 'H%'
                       AND SUBSTR (academic_period, 6, 1) = '0'
                       AND course_section_number LIKE 'H%'
                       AND grade_type <>'T'  --NOT IN ('T', 'A') --Exclude Transfer and Audit Courses    
                  THEN
                     course_credits
                  ELSE 0
               END)
               "CIS_CREDITS",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND sub_academic_period LIKE 'H%'
                         AND SUBSTR (academic_period, 6, 1) = '0'
                         AND course_section_number LIKE 'H%'
                         AND grade_type <>'T' --NOT IN ('T', 'A') --Exclude Transfer and Audit Courses     
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "CIS_CREDITS_W",
            SUM (CASE
                    WHEN    registration_status IN ('RE', 'RW')
                         AND transfer_course_ind = 'N'
                         AND sub_academic_period IN ('DE','DEI','DEO','IN1','IN2','IN3''IN4')
                         AND SUBSTR (academic_period, 6, 1) = '0'
                         AND course_section_number LIKE 'D%'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses   
                    THEN
                       course_credits
                    ELSE 0
                 END)
               "UOL_ADULT_CREDITS",
            SUM (CASE
                    WHEN     registration_status IN ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                         AND transfer_course_ind = 'N'
                         AND sub_academic_period IN ('DE','DEI','DEO','IN1','IN2','IN3','IN4')
                         AND SUBSTR (academic_period, 6, 1) = '0'
                         AND course_section_number LIKE 'D%'
                         AND grade_type NOT IN ('T', 'A') --Exclude Transfer and Audit Courses 
                    THEN
                       credits_attempted
                    ELSE 0
                 END)
               "UOL_ADULT_CREDITS_W",
            SUM (
               CASE
                  WHEN subject ='REG'
                  THEN course_credits
                  ELSE 0
               END)
               "FIN_AID_REG_CREDITS",
            SUM (CASE 
                  WHEN grade_type = 'A' 
                  THEN course_credits 
                  ELSE 0 
                END)
               "AUDIT_CREDITS",

            SUM (CASE WHEN course_department = 'OFFC'
                       AND subject <> 'REG'
                       AND registration_status IN ('RE', 'RW')
                  THEN course_credits
                  WHEN course_department = 'OFFC'
                       AND subject <> 'REG'
                       AND registration_status = 'OD' -- Off Campus Studies Drop
                  THEN course_billing_credits
                  ELSE 0
                  END

               )
               "UNW_OFF_CAMPUS_CREDITS",
               SUM( case 
                    when registration_status in ('RE','RW','OD','AU')
                      and transfer_course_ind = 'N'
                    then 1
                    else 0
                    end )
               "COURSE_COUNT_REG",
               SUM( case when registration_status in ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                     and transfer_course_ind = 'N'
                     then 1
                     else 0
                     end )
               "COURSE_COUNT_W"
       FROM ODSSRC.Z_STUDENT_COURSE_CV

   GROUP BY person_uid,
            academic_year,
            academic_year_desc,
            SUBSTR (academic_period, 1, 5),
            GOKODSF.F_GET_DESC(SUBSTR (academic_period, 1, 5)||'0', 'STVTERM')
            
   ORDER BY person_uid,
            academic_year,
            academic_year_desc,
            SUBSTR (academic_period, 1, 5),
            GOKODSF.F_GET_DESC(SUBSTR (academic_period, 1, 5)||'0', 'STVTERM')