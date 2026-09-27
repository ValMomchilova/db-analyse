USE [data_camp];
GO

/*==============================================================*/
/* DROP VIEW IF EXISTS                                          */
/*==============================================================*/
IF OBJECT_ID('Analysis.VW_PORTFOLIO_ANALYSIS', 'V') IS NOT NULL
    DROP VIEW Analysis.VW_PORTFOLIO_ANALYSIS;
GO

/*==============================================================*/
/* VIEW: PORTFOLIO ANALYSIS                                     */
/*==============================================================*/
CREATE VIEW Analysis.VW_PORTFOLIO_ANALYSIS
AS
WITH CREDIT_ENRICHED AS
(
    SELECT
        C.CREDIT_NO,
        LT.LAON_TYPE_NAME AS LOAN_TYPE,
        YEAR(C.CREDIT_BEGIN_DATE) AS CONTRACT_YEAR,
        C.CREDIT_SUM AS LOAN_AMOUNT,
        (C.CREDIT_ALLSUM - C.CREDIT_SUM) AS TOTAL_INTEREST,

        DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) AS LOAN_DURATION_MONTHS,

        CASE
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 0 AND 3
                THEN '0-3 months'
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 4 AND 6
                THEN '4-6 months'
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 7 AND 12
                THEN '7-12 months'
            ELSE '13+ months'
        END AS LOAN_DURATION_GROUP
    FROM DATA.CREDIT C
    JOIN DATA.LOAN_TYPE LT
        ON C.LOAN_TYPE_ID = LT.LOAN_TYPE_ID
)
SELECT
    LOAN_TYPE,
    CONTRACT_YEAR,
    LOAN_DURATION_GROUP,
    COUNT(*) AS NUMBER_OF_LOANS,
    SUM(TOTAL_INTEREST) AS TOTAL_INTEREST,
    SUM(LOAN_AMOUNT) AS TOTAL_LOAN_AMOUNT
FROM CREDIT_ENRICHED
GROUP BY
    LOAN_TYPE,
    CONTRACT_YEAR,
    LOAN_DURATION_GROUP;
GO