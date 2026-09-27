USE [data_camp];
GO

/*==============================================================*/
/* CREATE SCHEMA ANALYSIS IF MISSING                            */
/*==============================================================*/
IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Analysis'
)
BEGIN
    EXEC('CREATE SCHEMA Analysis');
END
GO

/*==============================================================*/
/* VIEW: RISK ANALYSIS - DELAY BEHAVIOR BY AGE GROUP            */
/*==============================================================*/
CREATE OR ALTER VIEW Analysis.VW_RISK_ANALYSIS_DELAY_BEHAVIOR
AS
WITH CONTRACT_LEVEL AS
(
    SELECT
        C.CLIENT_ID,
        R.LOAN_NUMBER,
        R.AVG_LAST_3_INSTALLMENT_DELAY
    FROM Analysis.VW_RISK_ANALYSIS_BY_CONTRACT R
    JOIN DATA.CREDIT C
        ON C.CREDIT_NO = R.LOAN_NUMBER
),
CLIENT_LEVEL AS
(
    SELECT
        CLIENT_ID,
        AVG(CAST(AVG_LAST_3_INSTALLMENT_DELAY AS DECIMAL(10,2))) AS CLIENT_AVG_DELAY
    FROM CONTRACT_LEVEL
    GROUP BY CLIENT_ID
),
CLIENT_WITH_AGE AS
(
    SELECT
        CL.CLIENT_ID,
        CL.CLIENT_AVG_DELAY,
        DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, GETDATE())
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, GETDATE()), C.CLIENT_BIRTHDATE) > GETDATE()
                THEN 1
            ELSE 0
          END AS AGE_YEARS
    FROM CLIENT_LEVEL CL
    JOIN DATA.CLIENT C
        ON C.CLIENT_ID = CL.CLIENT_ID
),
CLIENT_WITH_GROUP AS
(
    SELECT
        CLIENT_ID,
        CLIENT_AVG_DELAY,
        CASE
            WHEN AGE_YEARS < 18 THEN 'Up to 18'
            WHEN AGE_YEARS BETWEEN 18 AND 30 THEN '18-30'
            WHEN AGE_YEARS BETWEEN 31 AND 40 THEN '31-40'
            WHEN AGE_YEARS BETWEEN 41 AND 50 THEN '41-50'
            WHEN AGE_YEARS BETWEEN 51 AND 60 THEN '51-60'
            ELSE 'Above 60'
        END AS AGE_GROUP
    FROM CLIENT_WITH_AGE
)
SELECT
    AGE_GROUP,
    AVG(CAST(CLIENT_AVG_DELAY AS DECIMAL(10,2))) AS AVG_LAST_3_INSTALLMENT_DELAY,
    CASE
        WHEN AVG(CAST(CLIENT_AVG_DELAY AS DECIMAL(10,2))) = 0 THEN 'Low'
        WHEN AVG(CAST(CLIENT_AVG_DELAY AS DECIMAL(10,2))) BETWEEN 1 AND 5 THEN 'Minor'
        WHEN AVG(CAST(CLIENT_AVG_DELAY AS DECIMAL(10,2))) BETWEEN 6 AND 10 THEN 'Moderate'
        WHEN AVG(CAST(CLIENT_AVG_DELAY AS DECIMAL(10,2))) BETWEEN 11 AND 20 THEN 'High'
        ELSE 'Significant'
    END AS DELAY_RISK
FROM CLIENT_WITH_GROUP
GROUP BY AGE_GROUP;
GO

/* TESTS                                                        */
/*==============================================================*/

select * from Analysis.VW_RISK_ANALYSIS_DELAY_BEHAVIOR
GO