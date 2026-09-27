USE [data_camp];
GO

/*==============================================================*/
/* CLEAN FACT TABLE                                             */
/*==============================================================*/
DELETE FROM OLAP.FACT_LOANS;
GO

/*==============================================================*/
/* POPULATE FACT_LOANS                                          */
/*==============================================================*/
WITH CREDIT_BASE AS
(
    SELECT
        C.CREDIT_NO,
        C.CLIENT_ID,
        C.LOAN_TYPE_ID AS ProductID,
        C.CREDIT_BEGIN_DATE,
        CAST(CONVERT(CHAR(8), C.CREDIT_BEGIN_DATE, 112) AS INT) AS DateID,
        DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) AS LoanDurationMonths,
        CASE
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 0 AND 3 THEN 1
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 4 AND 6 THEN 2
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 7 AND 12 THEN 3
            ELSE 4
        END AS TenureBucketID
    FROM DATA.CREDIT C
),
INSTALLMENT_AGG AS
(
    SELECT
        RS.CREDIT_NO,
        SUM(RS.INSTALLMENT_INTEREST) AS TotalInterest,
        SUM(RS.INSTALLMENT_PRINCIPLE) AS TotalPrinciple,
        SUM(RS.INSTALLMENT_SUM) AS LoanSize
    FROM DATA.REPAYMENT_SCHEDULE RS
    GROUP BY RS.CREDIT_NO
),
OUTSTANDING_AGG AS
(
    SELECT
        RS.CREDIT_NO,
        SUM
        (
            CASE
                WHEN RS.INSTALLMENT_DATE <= CAST(GETDATE() AS DATE)
                 AND ISNULL(RS.PAID_AMOUNT, 0) < RS.INSTALLMENT_SUM
                    THEN RS.INSTALLMENT_SUM - ISNULL(RS.PAID_AMOUNT, 0)
                ELSE 0
            END
        ) AS TotalOutstandingBalance
    FROM DATA.REPAYMENT_SCHEDULE RS
    GROUP BY RS.CREDIT_NO
),
PAYMENT_AGG AS
(
    SELECT
        P.CREDIT_NO,
        SUM(P.PAYMENT_AMOUNT) AS TotalDisbursedAmount
    FROM DATA.PAYMENT P
    GROUP BY P.CREDIT_NO
)
INSERT INTO OLAP.FACT_LOANS
(
    DateID,
    ProductID,
    ValidFrom,
    TenureBucketID,
    NumberOfLoans,
    TotalInterest,
    TotalPrinciple,
    AverageLoanSize,
    TotalCustomers,
    TotalOutstandingBalance,
    TotalDisbursedAmount
)
SELECT
    CB.DateID,
    CB.ProductID,
    DLP.ValidFrom,
    CB.TenureBucketID,

    COUNT(*) AS NumberOfLoans,
    SUM(ISNULL(IA.TotalInterest, 0)) AS TotalInterest,
    SUM(ISNULL(IA.TotalPrinciple, 0)) AS TotalPrinciple,
    AVG(CAST(ISNULL(IA.LoanSize, 0) AS DECIMAL(15,2))) AS AverageLoanSize,
    COUNT(DISTINCT CB.CLIENT_ID) AS TotalCustomers,
    SUM(ISNULL(OA.TotalOutstandingBalance, 0)) AS TotalOutstandingBalance,
    SUM(ISNULL(PA.TotalDisbursedAmount, 0)) AS TotalDisbursedAmount
FROM CREDIT_BASE CB
JOIN OLAP.DIM_LOANPRODUCT DLP
    ON DLP.ProductID = CB.ProductID
   AND CB.CREDIT_BEGIN_DATE >= DLP.ValidFrom
   AND (CB.CREDIT_BEGIN_DATE <= DLP.ValidTo OR DLP.ValidTo IS NULL)
LEFT JOIN INSTALLMENT_AGG IA
    ON IA.CREDIT_NO = CB.CREDIT_NO
LEFT JOIN OUTSTANDING_AGG OA
    ON OA.CREDIT_NO = CB.CREDIT_NO
LEFT JOIN PAYMENT_AGG PA
    ON PA.CREDIT_NO = CB.CREDIT_NO
GROUP BY
    CB.DateID,
    CB.ProductID,
    DLP.ValidFrom,
    CB.TenureBucketID;
GO

/*==============================================================*/
/* CHECK RESULT                                                 */
/*==============================================================*/
SELECT
    T.DateValue,
    P.ProductName,
    B.BucketName,
    F.NumberOfLoans,
    F.TotalInterest,
    F.TotalPrinciple,
    F.AverageLoanSize,
    F.TotalCustomers,
    F.TotalOutstandingBalance,
    F.TotalDisbursedAmount
FROM OLAP.FACT_LOANS F
JOIN OLAP.DIM_TIME T
    ON F.DateID = T.DateID
JOIN OLAP.DIM_LOANPRODUCT P
    ON F.ProductID = P.ProductID
   AND F.ValidFrom = P.ValidFrom
JOIN OLAP.DIM_TENURE_BUCKET B
    ON F.TenureBucketID = B.TenureBucketID
ORDER BY
    T.DateValue,
    P.ProductName,
    B.TenureBucketID;
GO

/*
The fact table aggregates loan data at the time of loan origination, grouped by product, start date, and tenure bucket. Metrics such as outstanding balance and disbursed amount are calculated using repayment and payment data, while SCD Type 2 logic ensures correct historical product mapping.
*/