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
/* VIEW: RISK ANALYSIS BY CONTRACT                              */
/*==============================================================*/
CREATE OR ALTER VIEW Analysis.VW_RISK_ANALYSIS_BY_CONTRACT
AS
WITH DUE_INSTALLMENTS AS
(
    SELECT
        VIS.LOAN_NUMBER,
        VIS.INSTALLMENT_NO,
        VIS.INSTALLMENT_DATE,
        VIS.DAYS_LATE,
        ROW_NUMBER() OVER
        (
            PARTITION BY VIS.LOAN_NUMBER
            ORDER BY VIS.INSTALLMENT_DATE DESC, VIS.INSTALLMENT_NO DESC
        ) AS RN
    FROM Analysis.VW_INSTALLMENT_STATUS VIS
    WHERE VIS.DUE_FLAG = 'Y'
),
LAST_3_INSTALLMENTS AS
(
    SELECT
        LOAN_NUMBER,
        INSTALLMENT_NO,
        INSTALLMENT_DATE,
        DAYS_LATE
    FROM DUE_INSTALLMENTS
    WHERE RN <= 3
),
AVG_DELAY AS
(
    SELECT
        LOAN_NUMBER,
        AVG(CAST(DAYS_LATE AS DECIMAL(10,2))) AS AVG_LAST_3_INSTALLMENT_DELAY
    FROM LAST_3_INSTALLMENTS
    GROUP BY LOAN_NUMBER
)
SELECT
    C.CREDIT_NO AS LOAN_NUMBER,
    C.CREDIT_ALLSUM AS LOAN_AMOUNT,
    ISNULL(A.AVG_LAST_3_INSTALLMENT_DELAY, 0) AS AVG_LAST_3_INSTALLMENT_DELAY,
    CASE
        WHEN ISNULL(A.AVG_LAST_3_INSTALLMENT_DELAY, 0) = 0 THEN 'Low'
        WHEN A.AVG_LAST_3_INSTALLMENT_DELAY BETWEEN 1 AND 5 THEN 'Minor'
        WHEN A.AVG_LAST_3_INSTALLMENT_DELAY BETWEEN 6 AND 10 THEN 'Moderate'
        WHEN A.AVG_LAST_3_INSTALLMENT_DELAY BETWEEN 11 AND 20 THEN 'High'
        ELSE 'Significant'
    END AS DELAY_RISK
FROM DATA.CREDIT C
LEFT JOIN AVG_DELAY A
    ON C.CREDIT_NO = A.LOAN_NUMBER;
GO


/* TESTS                                                        */
/*==============================================================*/

select * from Analysis.VW_RISK_ANALYSIS_BY_CONTRACT
GO