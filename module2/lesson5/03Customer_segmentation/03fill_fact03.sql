USE [data_camp];
GO

DECLARE @SnapshotDate DATE;
DECLARE @DateID INT;

SET @SnapshotDate = CAST(GETDATE() AS DATE);
SET @DateID = CAST(CONVERT(CHAR(8), @SnapshotDate, 112) AS INT);

/*==============================================================*/
/* CLEAN TODAY SNAPSHOT                                         */
/*==============================================================*/
DELETE FROM OLAP.FACT_CUSTOMER_SEGMENTATION
WHERE DateID = @DateID;
GO

USE [data_camp];
GO

DECLARE @SnapshotDate DATE;
DECLARE @DateID INT;

SET @SnapshotDate = CAST(GETDATE() AS DATE);
SET @DateID = CAST(CONVERT(CHAR(8), @SnapshotDate, 112) AS INT);

/*==============================================================*/
/* POPULATE FACT_CUSTOMER_SEGMENTATION                          */
/*==============================================================*/
WITH CUSTOMER_BASE AS
(
    SELECT
        C.CLIENT_ID,
        C.EDU_CODE,
        C.CLIENT_INCOME,

        DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, @SnapshotDate)
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, @SnapshotDate), C.CLIENT_BIRTHDATE) > @SnapshotDate
                THEN 1
            ELSE 0
          END AS AGE_YEARS
    FROM DATA.CLIENT C
),
CUSTOMER_SEGMENT AS
(
    SELECT
        CB.CLIENT_ID,
        CB.EDU_CODE,
        AG.AgeGroupID,
        IG.IncomeGroupID
    FROM CUSTOMER_BASE CB
    JOIN OLAP.DIM_AGE_GROUP AG
        ON CB.AGE_YEARS >= AG.MinAge
       AND (CB.AGE_YEARS <= AG.MaxAge OR AG.MaxAge IS NULL)
    JOIN OLAP.DIM_INCOME_GROUP IG
        ON CB.CLIENT_INCOME >= IG.MinIncome
       AND (CB.CLIENT_INCOME <= IG.MaxIncome OR IG.MaxIncome IS NULL)
),
CUSTOMER_LOAN_METRICS AS
(
    SELECT
        C.CLIENT_ID,
        COUNT(C.CREDIT_NO) AS NumberOfLoans,
        SUM(C.CREDIT_ALLSUM) AS AmountOfLoans
    FROM DATA.CREDIT C
    GROUP BY C.CLIENT_ID
),
CUSTOMER_OUTSTANDING AS
(
    SELECT
        C.CLIENT_ID,
        SUM
        (
            CASE
                WHEN RS.INSTALLMENT_DATE <= @SnapshotDate
                 AND ISNULL(RS.PAID_AMOUNT, 0) < RS.INSTALLMENT_SUM
                    THEN RS.INSTALLMENT_SUM - ISNULL(RS.PAID_AMOUNT, 0)
                ELSE 0
            END
        ) AS TotalOutstandingAmount
    FROM DATA.CREDIT C
    JOIN DATA.REPAYMENT_SCHEDULE RS
        ON C.CREDIT_NO = RS.CREDIT_NO
    GROUP BY C.CLIENT_ID
)
INSERT INTO OLAP.FACT_CUSTOMER_SEGMENTATION
(
    DateID,
    CustomerID,
    EducationID,
    EducationValidFrom,
    AgeGroupID,
    IncomeGroupID,
    NumberOfLoans,
    AmountOfLoans,
    NumberOfCustomers,
    TotalOutstandingAmount,
    AverageOutstandingAmount
)
SELECT
    @DateID AS DateID,
    CS.CLIENT_ID AS CustomerID,
    DE.EducationID,
    DE.ValidFrom AS EducationValidFrom,
    CS.AgeGroupID,
    CS.IncomeGroupID,

    ISNULL(CLM.NumberOfLoans, 0) AS NumberOfLoans,
    ISNULL(CLM.AmountOfLoans, 0) AS AmountOfLoans,
    1 AS NumberOfCustomers,
    ISNULL(CO.TotalOutstandingAmount, 0) AS TotalOutstandingAmount,
    ISNULL(CO.TotalOutstandingAmount, 0) AS AverageOutstandingAmount
FROM CUSTOMER_SEGMENT CS
JOIN OLAP.DIM_EDUCATION DE
    ON DE.EducationID = CS.EDU_CODE
   AND @SnapshotDate >= DE.ValidFrom
   AND (@SnapshotDate <= DE.ValidTo OR DE.ValidTo IS NULL)
LEFT JOIN CUSTOMER_LOAN_METRICS CLM
    ON CS.CLIENT_ID = CLM.CLIENT_ID
LEFT JOIN CUSTOMER_OUTSTANDING CO
    ON CS.CLIENT_ID = CO.CLIENT_ID;
GO

SELECT *
FROM OLAP.FACT_CUSTOMER_SEGMENTATION
ORDER BY CustomerID;