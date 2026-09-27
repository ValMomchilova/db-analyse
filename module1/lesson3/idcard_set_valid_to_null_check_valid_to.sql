USE [data_camp];
GO

/*==============================================================*/
/* 1. ALLOW NULL FOR INDEFINITE VALIDITY                        */
/*==============================================================*/
ALTER TABLE DATA.CLIENT
ALTER COLUMN CLIENT_IDCARD_VALIDTO DATE NULL;
GO

/*==============================================================*/
/* 2. OPTIONAL DATA NORMALIZATION                               */
/* For clients 58+ at issue date, set VALIDTO = NULL            */
/*==============================================================*/
UPDATE DATA.CLIENT
SET CLIENT_IDCARD_VALIDTO = NULL
WHERE
    (
        DATEDIFF(YEAR, CLIENT_BIRTHDATE, CLIENT_IDCARD_ISSUED)
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, CLIENT_BIRTHDATE, CLIENT_IDCARD_ISSUED), CLIENT_BIRTHDATE) > CLIENT_IDCARD_ISSUED
                THEN 1
            ELSE 0
          END
    ) >= 58;
GO

/*==============================================================*/
/* 3. DROP FUNCTION IF EXISTS                                   */
/*==============================================================*/
IF OBJECT_ID('DATA.FN_TEST_IDCARD_VALIDITY', 'FN') IS NOT NULL
    DROP FUNCTION DATA.FN_TEST_IDCARD_VALIDITY;
GO

/*==============================================================*/
/* 4. CREATE FUNCTION                                           */
/*==============================================================*/
CREATE FUNCTION DATA.FN_TEST_IDCARD_VALIDITY
(
    @BIRTHDATE DATE,
    @ISSUED DATE,
    @VALIDTO DATE
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @AGE_AT_ISSUE INT;

    SET @AGE_AT_ISSUE =
        DATEDIFF(YEAR, @BIRTHDATE, @ISSUED)
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, @BIRTHDATE, @ISSUED), @BIRTHDATE) > @ISSUED
                THEN 1
            ELSE 0
          END;

    RETURN
        CASE
            WHEN @AGE_AT_ISSUE < 14 THEN
                'INVALID: UNDER 14'

            WHEN @AGE_AT_ISSUE BETWEEN 14 AND 17 THEN
                CASE
                    WHEN @VALIDTO = DATEADD(YEAR, 4, @ISSUED)
                        THEN 'VALID'
                    ELSE 'INVALID'
                END

            WHEN @AGE_AT_ISSUE BETWEEN 18 AND 57 THEN
                CASE
                    WHEN @VALIDTO = DATEADD(YEAR, 10, @ISSUED)
                        THEN 'VALID'
                    ELSE 'INVALID'
                END

            WHEN @AGE_AT_ISSUE >= 58 THEN
                CASE
                    WHEN @VALIDTO IS NULL
                        THEN 'VALID'
                    ELSE 'INVALID'
                END

            ELSE 'INVALID'
        END;
END
GO

/*==============================================================*/
/* 5. DROP VIEW IF EXISTS                                       */
/*==============================================================*/
IF OBJECT_ID('DATA.VW_CLIENT_IDCARD_VALIDITY_REPORT', 'V') IS NOT NULL
    DROP VIEW DATA.VW_CLIENT_IDCARD_VALIDITY_REPORT;
GO

/*==============================================================*/
/* 6. CREATE VIEW                                               */
/*==============================================================*/
CREATE VIEW DATA.VW_CLIENT_IDCARD_VALIDITY_REPORT
AS
SELECT
    C.CLIENT_ID AS INTERNAL_CLIENT_ID,
    C.CLIENT_NAME,
    C.CLIENT_SURNAME,
    C.CLIENT_LASTNAME,
    C.CLIENT_IDCARD_NO,
    C.CLIENT_IDCARD_ISSUED,
    C.CLIENT_IDCARD_VALIDTO,
    DATA.FN_TEST_IDCARD_VALIDITY
    (
        C.CLIENT_BIRTHDATE,
        C.CLIENT_IDCARD_ISSUED,
        C.CLIENT_IDCARD_VALIDTO
    ) AS IDCARD_VALIDITY_TEST_RESULT
FROM DATA.CLIENT C;
GO

/*==============================================================*/
/* 7. TEST QUERY                                                */
/*==============================================================*/
SELECT *
FROM DATA.VW_CLIENT_IDCARD_VALIDITY_REPORT
ORDER BY INTERNAL_CLIENT_ID;
GO