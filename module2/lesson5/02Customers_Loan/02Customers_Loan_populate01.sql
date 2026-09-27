USE [data_camp];
GO

DECLARE @SnapshotDate DATE;
DECLARE @DateID INT;

SET @SnapshotDate = CAST(GETDATE() AS DATE);
SET @DateID = CAST(CONVERT(CHAR(8), @SnapshotDate, 112) AS INT);

/* remove existing snapshot for today, so script is rerunnable */
DELETE FROM OLAP.FACT_CUSTOMER_LOANS
WHERE DateID = @DateID;

WITH INSTALLMENT_BASE AS
(
    SELECT
        C.CLIENT_ID,
        C.CREDIT_NO,
        RS.INSTALLMENT_NO,
        RS.INSTALLMENT_DATE,
        RS.INSTALLMENT_SUM,
        ISNULL(RS.PAID_AMOUNT, 0) AS PAID_AMOUNT,
        VIS.DUE_FLAG,
        VIS.PAID_STATUS,
        VIS.DAYS_LATE
    FROM DATA.CREDIT C
    JOIN DATA.REPAYMENT_SCHEDULE RS
        ON C.CREDIT_NO = RS.CREDIT_NO
    JOIN Analysis.VW_INSTALLMENT_STATUS VIS
        ON RS.CREDIT_NO = VIS.LOAN_NUMBER
       AND RS.INSTALLMENT_NO = VIS.INSTALLMENT_NO
),
LOAN_AGG AS
(
    SELECT
        CLIENT_ID,
        COUNT(*) AS NumberOfLoans,
        SUM(CREDIT_ALLSUM) AS AmountOfLoans
    FROM DATA.CREDIT
    GROUP BY CLIENT_ID
),
OUTSTANDING_AGG AS
(
    SELECT
        CLIENT_ID,
        SUM
        (
            CASE
                WHEN DUE_FLAG = 'Y'
                 AND PAID_AMOUNT < INSTALLMENT_SUM
                    THEN INSTALLMENT_SUM - PAID_AMOUNT
                ELSE 0
            END
        ) AS TotalOutstandingAmount
    FROM INSTALLMENT_BASE
    GROUP BY CLIENT_ID
),
DPD_AGG AS
(
    SELECT
        CLIENT_ID,

        CASE
            WHEN COUNT(CASE WHEN DUE_FLAG = 'Y' THEN 1 END) = 0 THEN 0
            ELSE
                CAST
                (
                    COUNT
                    (
                        CASE
                            WHEN DUE_FLAG = 'Y'
                             AND PAID_STATUS = 'Y'
                             AND DAYS_LATE = 0
                                THEN 1
                        END
                    ) AS DECIMAL(10,4)
                )
                /
                COUNT(CASE WHEN DUE_FLAG = 'Y' THEN 1 END)
                * 100
        END AS RepaymentConsistencyPct,

        AVG
        (
            CASE
                WHEN DUE_FLAG = 'Y'
                    THEN CAST(DAYS_LATE AS DECIMAL(10,2))
            END
        ) AS AverageDPD,

        MAX
        (
            CASE
                WHEN DUE_FLAG = 'Y'
                    THEN DAYS_LATE
                ELSE 0
            END
        ) AS MaximumDPD
    FROM INSTALLMENT_BASE
    GROUP BY CLIENT_ID
),
LOANS_30_DPD AS
(
    SELECT
        CLIENT_ID,
        COUNT(*) AS LoansWith30DPD
    FROM
    (
        SELECT DISTINCT
            CLIENT_ID,
            CREDIT_NO
        FROM INSTALLMENT_BASE
        WHERE DUE_FLAG = 'Y'
          AND DAYS_LATE >= 30
    ) X
    GROUP BY CLIENT_ID
)
INSERT INTO OLAP.FACT_CUSTOMER_LOANS
(
    DateID,
    CustomerID,
    NumberOfLoans,
    AmountOfLoans,
    TotalOutstandingAmount,
    RepaymentConsistencyPct,
    AverageDPD,
    MaximumDPD,
    LoansWith30DPD
)
SELECT
    @DateID AS DateID,
    DC.CustomerID,
    ISNULL(LA.NumberOfLoans, 0),
    ISNULL(LA.AmountOfLoans, 0),
    ISNULL(OA.TotalOutstandingAmount, 0),
    ISNULL(DA.RepaymentConsistencyPct, 0),
    ISNULL(DA.AverageDPD, 0),
    ISNULL(DA.MaximumDPD, 0),
    ISNULL(L30.LoansWith30DPD, 0)
FROM OLAP.DIM_CUSTOMER DC
LEFT JOIN LOAN_AGG LA
    ON DC.CustomerID = LA.CLIENT_ID
LEFT JOIN OUTSTANDING_AGG OA
    ON DC.CustomerID = OA.CLIENT_ID
LEFT JOIN DPD_AGG DA
    ON DC.CustomerID = DA.CLIENT_ID
LEFT JOIN LOANS_30_DPD L30
    ON DC.CustomerID = L30.CLIENT_ID;
GO

SELECT *
FROM OLAP.FACT_CUSTOMER_LOANS
ORDER BY CustomerID;
GO