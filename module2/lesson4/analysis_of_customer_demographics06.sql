CREATE OR ALTER VIEW Analysis.VW_CUSTOMER_DEMOGRAPHICS
AS
WITH CUSTOMER_ENRICHED AS
(
    SELECT
        C.CLIENT_ID,
        E.EDU_NAME AS EDUCATION,

        DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, GETDATE())
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, C.CLIENT_BIRTHDATE, GETDATE()), C.CLIENT_BIRTHDATE) > GETDATE()
                THEN 1
            ELSE 0
          END AS AGE_YEARS
    FROM DATA.CLIENT C
    LEFT JOIN DATA.EDUCATION E
        ON C.EDU_CODE = E.EDU_CODE
),
CUSTOMER_GROUPED AS
(
    SELECT
        EDUCATION,
        CASE
            WHEN AGE_YEARS < 18 THEN 'Up to 18'
            WHEN AGE_YEARS BETWEEN 18 AND 30 THEN '18-30'
            WHEN AGE_YEARS BETWEEN 31 AND 40 THEN '31-40'
            WHEN AGE_YEARS BETWEEN 41 AND 50 THEN '41-50'
            WHEN AGE_YEARS BETWEEN 51 AND 60 THEN '51-60'
            ELSE 'Above 60'
        END AS AGE_GROUP
    FROM CUSTOMER_ENRICHED
)
SELECT
    EDUCATION,
    AGE_GROUP,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMER_GROUPED
GROUP BY CUBE (EDUCATION, AGE_GROUP);
GO

/*==============================================================*/
/* TESTS                                                        */
/*==============================================================*/

select * from Analysis.VW_CUSTOMER_DEMOGRAPHICS
GO