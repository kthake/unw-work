/**********************************************
Originally created by Keaton Hake on 11/21/2016.
Purpose: Pass a position or orgn code and an organization level
to return the financial manager pidm at that organization level.
Level 1 = president, level 2 = VP's, etc..
Optionally pass a fiscal year when using i_type = 'POSN'
otherwise defaults to current fiscal year.

EXAMPLE: Z_GET_FM_FNC('POSN','P00223',2,null,'2016') to get VP over position P00223
or Z_GET_FM_FNC('ORGN','2652',4,'N')

Error values and descriptions:
  -1 = POSN or ORGN not passed for i_type
  -2 = i_level is outside the range of 1-4
  -3 = i_type = 'ORGN' but a COA was not passed for i_coa
**********************************************/

CREATE OR REPLACE FUNCTION Z_GET_FM_FNC_2 (  
    i_type IN VARCHAR2, --pass 'POSN' if using a position and 'ORGN' if using an org
    i_parm IN VARCHAR2, --pass a position or an org
    i_level IN SMALLINT,
    i_coa IN VARCHAR2 DEFAULT NULL,
    i_fsyr IN VARCHAR2 DEFAULT NULL ) 
    
RETURN NUMBER 

IS
    l_fsyr VARCHAR2(4);
    l_org VARCHAR2(5);
    l_coa VARCHAR2(1);
    l_pidm NUMBER;

BEGIN
  --error checking on values passed
  IF i_type not in ('POSN','ORGN')
     THEN l_pidm := -1;
     ELSIF i_level not between 1 and 4
     THEN l_pidm := -2;
     ELSIF i_type = 'ORGN' and i_coa is null --possibly make this a check of i_coa against FTVCOAS
     THEN l_pidm := -3;
     ELSE
     --BEGIN POSN TYPE
    IF i_type = 'POSN'
      THEN                 --determine fiscal year
        IF i_fsyr is null
          THEN
            SELECT ATVFISC_CODE
            INTO l_fsyr
            FROM ATVFISC
            WHERE sysdate between ATVFISC_START_DATE and ATVFISC_END_DATE;
          ELSE l_fsyr := i_fsyr;
        END IF;
   
        SELECT DISTINCT o.FINANCIAL_MANAGER_UID
        INTO l_pidm
        FROM ODSMGR.MFT_ORGN_HIERARCHY o
        WHERE o.ORGANIZATION_STATUS = 'A'
              and ( o.ORGANIZATION_CODE, o.CHART_OF_ACCOUNTS ) IN
          ( SELECT DISTINCT decode(i_level,'1',o1.ORGANIZATION_LEVEL_1,
                                           '2',o1.ORGANIZATION_LEVEL_2,
                                           '3',o1.ORGANIZATION_LEVEL_3,
                                           '4',o1.ORGANIZATION_LEVEL_4),
                            o1.CHART_OF_ACCOUNTS
            FROM ODSMGR.MPT_POSN_LABOR_DIST p1
                  inner join ODSMGR.MFT_ORGN_HIERARCHY o1
                  on o1.CHART_OF_ACCOUNTS = p1.CHART_OF_ACCOUNTS
                  and o1.ORGANIZATION_CODE = p1.POSITION_ORGANIZATION
                  and o1.ORGANIZATION_STATUS = 'A'
            WHERE p1.FISCAL_YEAR = l_fsyr
                  and p1.POSITION = i_parm
            );
    ELSE  
        SELECT DISTINCT o.FINANCIAL_MANAGER_UID
        INTO l_pidm
        FROM ODSMGR.MFT_ORGN_HIERARCHY o
        WHERE o.ORGANIZATION_STATUS = 'A'
              and( o.ORGANIZATION_CODE, o.CHART_OF_ACCOUNTS ) IN 
              
              ( SELECT DISTINCT decode(i_level,'1',o2.ORGANIZATION_LEVEL_1,
                                               '2',o2.ORGANIZATION_LEVEL_2,
                                               '3',o2.ORGANIZATION_LEVEL_3,
                                               '4',o2.ORGANIZATION_LEVEL_4),
                                o2.CHART_OF_ACCOUNTS
                FROM ODSMGR.MFT_ORGN_HIERARCHY o2            
                WHERE o2.ORGANIZATION_STATUS = 'A'
                      and o2.CHART_OF_ACCOUNTS = i_coa
                      and o2.ORGANIZATION_CODE = i_parm );
    END IF;
    RETURN l_pidm;
  END IF;
    EXCEPTION WHEN TOO_MANY_ROWS 
      THEN l_pidm := 0;
  
  RETURN l_pidm;
   
END Z_GET_FM_FNC_2;

