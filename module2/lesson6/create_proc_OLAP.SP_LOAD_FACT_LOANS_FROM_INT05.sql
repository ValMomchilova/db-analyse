USE [data_camp];
GO

IF OBJECT_ID('OLAP.SP_LOAD_FACT_LOANS_FROM_INT', 'P') IS NOT NULL
    DROP PROCEDURE OLAP.SP_LOAD_FACT_LOANS_FROM_INT;
GO

CREATE PROCEDURE OLAP.SP_LOAD_FACT_LOANS_FROM_INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    DELETE FROM OLAP.FACT_LOANS;

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
        DT.DateID,
        DLP.ProductID,
        DLP.ValidFrom,
        CASE
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 0 AND 3 THEN 1
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 4 AND 6 THEN 2
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 7 AND 12 THEN 3
            ELSE 4
        END AS TenureBucketID,

        COUNT(DISTINCT C.CREDIT_NO) AS NumberOfLoans,
        SUM(ISNULL(RS.INSTALLMENT_INTEREST, 0)) AS TotalInterest,
        SUM(ISNULL(RS.INSTALLMENT_PRINCIPLE, 0)) AS TotalPrinciple,
        AVG(CAST(ISNULL(C.CREDIT_ALLSUM, 0) AS DECIMAL(15,2))) AS AverageLoanSize,
        COUNT(DISTINCT C.CLIENT_ID) AS TotalCustomers,

        SUM
        (
            CASE
                WHEN RS.INSTALLMENT_DATE <= @Today
                 AND ISNULL(RS.PAID_AMOUNT, 0) < RS.INSTALLMENT_SUM
                    THEN RS.INSTALLMENT_SUM - ISNULL(RS.PAID_AMOUNT, 0)
                ELSE 0
            END
        ) AS TotalOutstandingBalance,

        SUM(ISNULL(RS.PAID_AMOUNT, 0)) AS TotalDisbursedAmount

    FROM Integration.CREDIT C
    JOIN Integration.REPAYMENT_SCHEDULE RS
        ON C.CREDIT_NO = RS.CREDIT_NO
    JOIN OLAP.DIM_TIME DT
        ON DT.DateValue = C.CREDIT_BEGIN_DATE
    JOIN OLAP.DIM_LOANPRODUCT DLP
        ON DLP.ProductID = C.LOAN_TYPE_ID
       AND C.CREDIT_BEGIN_DATE >= DLP.ValidFrom
       AND (C.CREDIT_BEGIN_DATE <= DLP.ValidTo OR DLP.ValidTo IS NULL)
    GROUP BY
        DT.DateID,
        DLP.ProductID,
        DLP.ValidFrom,
        CASE
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 0 AND 3 THEN 1
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 4 AND 6 THEN 2
            WHEN DATEDIFF(MONTH, C.CREDIT_BEGIN_DATE, C.CREDIT_END_DATE) BETWEEN 7 AND 12 THEN 3
            ELSE 4
        END;
END;
GO