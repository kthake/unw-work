select SUM (CASE WHEN registration_status IN ('RE', 'RW')
                      AND transfer_course_ind = 'N'
                      AND grade_type <> 'T' --Exclude Transfer
                 THEN course_credits
                 WHEN registration_status IN ('OD')
                      AND transfer_course_ind = 'N'
                      AND grade_type <> 'T' --Exclude Transfer
                 THEN course_billing_credits
                 ELSE 0
            END) "TOTAL_CREDITS",
            
       SUM ( CASE WHEN subject IN ('REG') THEN course_credits
                 ELSE 0
                 END) "FIN_AID_REG_CREDITS",
       SUM ( CASE WHEN course_department = 'OFFC'
                       AND subject <> 'REG'
                       AND registration_status IN ('RE', 'RW')
                  THEN course_credits
                  WHEN course_department = 'OFFC'
                       AND subject <> 'REG'
                       AND registration_status = 'OD' -- Off Campus Studies Drop
                  THEN course_billing_credits
                  ELSE 0
                  END) "UNW_OFF_CAMPUS_CREDITS",
      
       SUM( case when registration_status in ('RE','RW','OD')
                      and transfer_course_ind = 'N'
                      then 1
                      else 0
                      end ) "COURSE_COUNT_REG",
       
       SUM( case when registration_status in ('3X','6X','AW','FW','FX','PW','PX','WC','WW','WX')
                     and transfer_course_ind = 'N'
                     then 1
                     else 0
                     end ) "COURSE_COUNT_W"
             
FROM ODSSRC.Z_STUDENT_COURSE_CV


