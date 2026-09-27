USE [data_camp];
GO

/*==============================================================*/
/* CREATE SCHEMA ANALYSIS                                       */
/*==============================================================*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Analysis'
)
BEGIN
    EXEC ('CREATE SCHEMA Analysis');
END
GO

/*==============================================================*/
/* DROP VIEW IF EXISTS                                          */
/*==============================================================*/
IF OBJECT_ID('Analysis.VW_INSTALLMENT_STATUS_W', 'V') IS NOT NULL
    DROP VIEW Analysis.VW_INSTALLMENT_STATUS_W;
GO

/*==============================================================*/
/* VIEW: INSTALLMENT STATUS                                     */
/* Window-function version                                      */
/*==============================================================*/
CREATE VIEW Analysis.VW_INSTALLMENT_STATUS_W
AS
WITH PAYMENT_RAW AS
(
    SELECT
        PA.CREDIT_NO,
        PA.INSTALLMENT_NO,
        ISNULL(P.PAYMENT_VALUE_DATE, CAST(P.PAYMENT_EXECUTED_AT AS DATE)) AS PAYMENT_DATE,
        PA.ALLOCATED_AMOUNT,

        SUM(PA.ALLOCATED_AMOUNT) OVER
        (
            PARTITION BY PA.CREDIT_NO, PA.INSTALLMENT_NO
        ) AS PAID_AMOUNT,

        MIN(ISNULL(P.PAYMENT_VALUE_DATE, CAST(P.PAYMENT_EXECUTED_AT AS DATE))) OVER
        (
            PARTITION BY PA.CREDIT_NO, PA.INSTALLMENT_NO
        ) AS FIRST_PAYMENT_DATE,

        ROW_NUMBER() OVER
        (
            PARTITION BY PA.CREDIT_NO, PA.INSTALLMENT_NO
            ORDER BY ISNULL(P.PAYMENT_VALUE_DATE, CAST(P.PAYMENT_EXECUTED_AT AS DATE)), P.PAYMENT_ID
        ) AS RN
    FROM DATA.PAYMENT_ALLOCATION PA
    JOIN DATA.PAYMENT P
        ON P.PAYMENT_ID = PA.PAYMENT_ID
       AND P.CREDIT_NO = PA.CREDIT_NO
),
PAYMENT_DATA AS
(
    SELECT
        CREDIT_NO,
        INSTALLMENT_NO,
        PAID_AMOUNT,
        FIRST_PAYMENT_DATE
    FROM PAYMENT_RAW
    WHERE RN = 1
)
SELECT
    RS.CREDIT_NO AS LOAN_NUMBER,
    RS.INSTALLMENT_NO,
    RS.INSTALLMENT_DATE,
    RS.INSTALLMENT_SUM AS INSTALLMENT_AMOUNT,

    CASE
        WHEN RS.INSTALLMENT_DATE <= CAST(GETDATE() AS DATE) THEN 'Y'
        ELSE 'N'
    END AS DUE_FLAG,

    CASE
        WHEN ISNULL(PD.PAID_AMOUNT, 0) = 0 THEN 'N'
        WHEN PD.PAID_AMOUNT >= RS.INSTALLMENT_SUM THEN 'Y'
        ELSE 'P'
    END AS PAID_STATUS,

    CASE
        WHEN RS.INSTALLMENT_DATE > CAST(GETDATE() AS DATE) THEN 0
        WHEN PD.FIRST_PAYMENT_DATE IS NOT NULL
             AND PD.FIRST_PAYMENT_DATE > RS.INSTALLMENT_DATE
            THEN DATEDIFF(DAY, RS.INSTALLMENT_DATE, PD.FIRST_PAYMENT_DATE)
        WHEN PD.FIRST_PAYMENT_DATE IS NOT NULL
             AND PD.FIRST_PAYMENT_DATE <= RS.INSTALLMENT_DATE
            THEN 0
        ELSE DATEDIFF(DAY, RS.INSTALLMENT_DATE, CAST(GETDATE() AS DATE))
    END AS DAYS_LATE
FROM DATA.REPAYMENT_SCHEDULE RS
LEFT JOIN PAYMENT_DATA PD
    ON PD.CREDIT_NO = RS.CREDIT_NO
   AND PD.INSTALLMENT_NO = RS.INSTALLMENT_NO;
GO

/*==============================================================*/
/* TEST                                                         */
/*==============================================================*/
SELECT *
FROM Analysis.VW_INSTALLMENT_STATUS_W
ORDER BY LOAN_NUMBER, INSTALLMENT_NO;
GO


/*Example using windows to acumulate sum*/

/*
SELECT
    RS.CREDIT_NO,
    RS.INSTALLMENT_NO,
    RS.INSTALLMENT_DATE,
    RS.INSTALLMENT_SUM,

    -- running total (cumulative due)
    SUM(RS.INSTALLMENT_SUM) OVER
    (
        PARTITION BY RS.CREDIT_NO
        ORDER BY RS.INSTALLMENT_DATE, RS.INSTALLMENT_NO
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RUNNING_DUE_AMOUNT

FROM DATA.REPAYMENT_SCHEDULE RS
ORDER BY RS.CREDIT_NO, RS.INSTALLMENT_DATE, RS.INSTALLMENT_NO;
*/