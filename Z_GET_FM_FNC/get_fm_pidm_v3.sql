/**********************************************
Originally created by Keaton Hake on 11/21/2016.
Purpose: Pass a position or orgn code and an organization level
to return the financial manager pidm at that organization level.
Level 1 = president, level 2 = VP's, etc..
Optionally pass a fiscal year when using i_type = 'POSN'
otherwise defaults to current fiscal year.

EXAMPLE: Z_GET_FM_FNC('POSN',2,'P00223','2016') to get VP over position P00223
or Z_GET_FM_FNC('ORGN',4,'2652','N') for the financial manager at level 4 over org 2652

Error values and descriptions:
  -1 = POSN or ORGN not passed for i_type
  -2 = i_level is outside the range of 1-4
  -3 = i_type = 'POSN' but value passed for i_fsyr_coa is not length 4 (i.e. not the length of year format '2017')
  -4 = i_type = 'ORGN' but value passed for i_fsyr_coa is not length 1 since COAs have only length of 1
**********************************************/

CREATE OR REPLACE FUNCTION Z_GET_FM_FNC (  
    i_type IN VARCHAR2, --pass 'POSN' if using a position and 'ORGN' if using an org
    i_level IN SMALLINT,
    i_parm IN VARCHAR2, --pass a position or an org
    i_fsyr_coa IN VARCHAR2 DEFAULT NULL ) --pass fsyr when using i_type = 'POSN' and pass coa when using 'ORGN'
    
RETURN NUMBER 

IS
    l_fsyr VARCHAR2(4);
    l_org VARCHAR2(5);
    l_coa VARCHAR2(1);
    l_pidm NUMBER;

BEGIN
  --get current fiscal year if one is not passed as a parameter
  SELECT NVL(i_fsyr_coa,ATVFISC_CODE)
  INTO l_fsyr
  FROM ATVFISC
  WHERE sysdate between ATVFISC_START_DATE and ATVFISC_END_DATE;
   
  --error checking on values passed
  IF i_type not in ('POSN','ORGN')
     THEN l_pidm := -1;
     ELSIF i_level not between 1 and 4
     THEN l_pidm := -2;
     ELSIF i_type = 'POSN' and length(l_fsyr) <> 4
     THEN l_pidm := -3;
     ELSIF i_type = 'ORGN' and length(l_fsyr) <> 1
     THEN l_pidm := -4;
     ELSE
     --BEGIN POSN TYPE
        IF i_type = 'POSN'
          THEN                          
              SELECT decode(i_level,'1',o.ORGANIZATION_LEVEL_1,
                            '2',o.ORGANIZATION_LEVEL_2,
                            '3',o.ORGANIZATION_LEVEL_3,
                            '4',o.ORGANIZATION_LEVEL_4),
                     o.CHART_OF_ACCOUNTS
              INTO l_org, l_coa
              FROM (
                SELECT POSITION_ORGANIZATION,
                       CHART_OF_ACCOUNTS,
                       PERCENTAGE,
                       row_number() over (order by PERCENTAGE desc, POSITION_ORGANIZATION) "ROW_NUM"
                FROM ODSMGR.MPT_POSN_LABOR_DIST
                WHERE FISCAL_YEAR = l_fsyr
                      and POSITION = i_parm ) p
                inner join ODSMGR.MFT_ORGN_HIERARCHY o
                on o.ORGANIZATION_CODE = p.POSITION_ORGANIZATION
                and o.CHART_OF_ACCOUNTS = p.CHART_OF_ACCOUNTS  
              WHERE ROW_NUM = 1;
        --END POSN TYPE
        --BEGIN ORGN TYPE
          ELSE  
              SELECT DISTINCT decode(i_level,'1',o2.ORGANIZATION_LEVEL_1,
                                             '2',o2.ORGANIZATION_LEVEL_2,
                                             '3',o2.ORGANIZATION_LEVEL_3,
                                             '4',o2.ORGANIZATION_LEVEL_4),
                              o2.CHART_OF_ACCOUNTS
              INTO l_org,
                   l_coa
              FROM ODSMGR.MFT_ORGN_HIERARCHY o2            
              WHERE o2.ORGANIZATION_STATUS = 'A'
                    and o2.CHART_OF_ACCOUNTS = i_fsyr_coa
                    and o2.ORGANIZATION_CODE = i_parm;
        --END ORGN TYPE
        END IF;
    
    SELECT DISTINCT o.FINANCIAL_MANAGER_UID
    INTO l_pidm
    FROM ODSMGR.MFT_ORGN_HIERARCHY o
    WHERE o.ORGANIZATION_STATUS = 'A'
          and o.ORGANIZATION_CODE = l_org
          and o.CHART_OF_ACCOUNTS = l_coa;

  END IF;
  
    RETURN l_pidm;
   
END Z_GET_FM_FNC;

