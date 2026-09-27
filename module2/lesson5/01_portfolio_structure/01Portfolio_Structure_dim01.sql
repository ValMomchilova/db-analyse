USE [data_camp];
GO

/*==============================================================*/
/* 1. POPULATE DIM_TIME                                         */
/* SQL Server 2008-safe version                                 */
/*==============================================================*/
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

-- choose range according to your OLTP data
SET @StartDate = '2025-01-01';
SET @EndDate   = '2030-12-31';

;WITH DateSeries AS
(
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateSeries
    WHERE DateValue < @EndDate
)
INSERT INTO OLAP.DIM_TIME
(
    DateID,
    DateValue,
    [Year],
    [Month],
    [Day],
    DayName
)
SELECT
    CAST(CONVERT(CHAR(8), DateValue, 112) AS INT) AS DateID,
    DateValue,
    YEAR(DateValue) AS [Year],
    MONTH(DateValue) AS [Month],
    DAY(DateValue) AS [Day],
    DATENAME(WEEKDAY, DateValue) AS DayName
FROM DateSeries
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_TIME T
    WHERE T.DateID = CAST(CONVERT(CHAR(8), DateValue, 112) AS INT)
)
OPTION (MAXRECURSION 0);
GO

/*==============================================================*/
/* 2. POPULATE DIM_LOANPRODUCT                                  */
/* SCD 2 - for now all rows are current                         */
/*==============================================================*/
INSERT INTO OLAP.DIM_LOANPRODUCT
(
    ProductID,
    ProductName,
    ValidFrom,
    ValidTo,
    IsLast
)
SELECT
    LT.LOAN_TYPE_ID AS ProductID,
    LT.LAON_TYPE_NAME AS ProductName,
    CAST('2025-01-01' AS DATE) AS ValidFrom,
    CAST(NULL AS DATE) AS ValidTo,
    1 AS IsLast
FROM DATA.LOAN_TYPE LT
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_LOANPRODUCT D
    WHERE D.ProductID = LT.LOAN_TYPE_ID
      AND D.ValidFrom = CAST('2025-01-01' AS DATE)
);
GO

/*==============================================================*/
/* 3. POPULATE DIM_TENURE_BUCKET                                */
/*==============================================================*/
INSERT INTO OLAP.DIM_TENURE_BUCKET
(
    TenureBucketID,
    BucketName,
    MinMonths,
    MaxMonths
)
SELECT 1, '0-3 months', 0, 3
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_TENURE_BUCKET
    WHERE TenureBucketID = 1
);

INSERT INTO OLAP.DIM_TENURE_BUCKET
(
    TenureBucketID,
    BucketName,
    MinMonths,
    MaxMonths
)
SELECT 2, '4-6 months', 4, 6
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_TENURE_BUCKET
    WHERE TenureBucketID = 2
);

INSERT INTO OLAP.DIM_TENURE_BUCKET
(
    TenureBucketID,
    BucketName,
    MinMonths,
    MaxMonths
)
SELECT 3, '7-12 months', 7, 12
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_TENURE_BUCKET
    WHERE TenureBucketID = 3
);

INSERT INTO OLAP.DIM_TENURE_BUCKET
(
    TenureBucketID,
    BucketName,
    MinMonths,
    MaxMonths
)
SELECT 4, '13+ months', 13, NULL
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_TENURE_BUCKET
    WHERE TenureBucketID = 4
);
GO