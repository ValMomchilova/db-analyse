USE [data_camp];
GO

/*==============================================================*/
/* 1. POPULATE DIM_AGE_GROUP                                    */
/*==============================================================*/
INSERT INTO OLAP.DIM_AGE_GROUP
(AgeGroupID, AgeGroupName, MinAge, MaxAge)
SELECT 1, 'Young Adults', 0, 24
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_AGE_GROUP WHERE AgeGroupID = 1);

INSERT INTO OLAP.DIM_AGE_GROUP
(AgeGroupID, AgeGroupName, MinAge, MaxAge)
SELECT 2, 'Early Professionals', 25, 35
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_AGE_GROUP WHERE AgeGroupID = 2);

INSERT INTO OLAP.DIM_AGE_GROUP
(AgeGroupID, AgeGroupName, MinAge, MaxAge)
SELECT 3, 'Mid-Career Adults', 36, 45
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_AGE_GROUP WHERE AgeGroupID = 3);

INSERT INTO OLAP.DIM_AGE_GROUP
(AgeGroupID, AgeGroupName, MinAge, MaxAge)
SELECT 4, 'Mature Professionals', 46, 60
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_AGE_GROUP WHERE AgeGroupID = 4);

INSERT INTO OLAP.DIM_AGE_GROUP
(AgeGroupID, AgeGroupName, MinAge, MaxAge)
SELECT 5, 'Seniors', 61, NULL
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_AGE_GROUP WHERE AgeGroupID = 5);
GO

/*==============================================================*/
/* 2. POPULATE DIM_INCOME_GROUP                                 */
/*==============================================================*/
INSERT INTO OLAP.DIM_INCOME_GROUP
(IncomeGroupID, IncomeGroupName, MinIncome, MaxIncome)
SELECT 1, 'Low Income Segment', 0, 999.99
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_INCOME_GROUP WHERE IncomeGroupID = 1);

INSERT INTO OLAP.DIM_INCOME_GROUP
(IncomeGroupID, IncomeGroupName, MinIncome, MaxIncome)
SELECT 2, 'Lower-Middle Income', 1000, 2500
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_INCOME_GROUP WHERE IncomeGroupID = 2);

INSERT INTO OLAP.DIM_INCOME_GROUP
(IncomeGroupID, IncomeGroupName, MinIncome, MaxIncome)
SELECT 3, 'Middle Income', 2500.01, 5000
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_INCOME_GROUP WHERE IncomeGroupID = 3);

INSERT INTO OLAP.DIM_INCOME_GROUP
(IncomeGroupID, IncomeGroupName, MinIncome, MaxIncome)
SELECT 4, 'Upper-Middle Income', 5000.01, 10000
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_INCOME_GROUP WHERE IncomeGroupID = 4);

INSERT INTO OLAP.DIM_INCOME_GROUP
(IncomeGroupID, IncomeGroupName, MinIncome, MaxIncome)
SELECT 5, 'High Income Segment', 10000.01, NULL
WHERE NOT EXISTS (SELECT 1 FROM OLAP.DIM_INCOME_GROUP WHERE IncomeGroupID = 5);
GO

/*==============================================================*/
/* 3. POPULATE DIM_EDUCATION                                    */
/* SCD2 initial load - all current                              */
/*==============================================================*/
INSERT INTO OLAP.DIM_EDUCATION
(
    EducationID,
    EducationName,
    ValidFrom,
    ValidTo,
    IsLast
)
SELECT
    E.EDU_CODE,
    E.EDU_NAME,
    CAST('2025-01-01' AS DATE),
    NULL,
    1
FROM DATA.EDUCATION E
WHERE NOT EXISTS
(
    SELECT 1
    FROM OLAP.DIM_EDUCATION D
    WHERE D.EducationID = E.EDU_CODE
      AND D.ValidFrom = CAST('2025-01-01' AS DATE)
);
GO

/*==============================================================*/
/* CHECKS                                                       */
/*==============================================================*/
SELECT * FROM OLAP.DIM_AGE_GROUP ORDER BY AgeGroupID;
SELECT * FROM OLAP.DIM_INCOME_GROUP ORDER BY IncomeGroupID;
SELECT * FROM OLAP.DIM_EDUCATION ORDER BY EducationID, ValidFrom;
GO