USE [data_camp];
GO

/*==============================================================*/
/* DROP PROCEDURE IF EXISTS                                     */
/*==============================================================*/
IF OBJECT_ID('DATA.SP_VERIFY_CLIENT_EGN', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_VERIFY_CLIENT_EGN;
GO

/*==============================================================*/
/* DROP FUNCTIONS IF THEY EXIST                                 */
/*==============================================================*/
IF OBJECT_ID('DATA.FN_EGN_IS_VALID', 'FN') IS NOT NULL
    DROP FUNCTION DATA.FN_EGN_IS_VALID;
GO

IF OBJECT_ID('DATA.FN_EGN_DECODE_BIRTHDATE', 'FN') IS NOT NULL
    DROP FUNCTION DATA.FN_EGN_DECODE_BIRTHDATE;
GO

IF OBJECT_ID('DATA.FN_EGN_DECODE_GENDER', 'FN') IS NOT NULL
    DROP FUNCTION DATA.FN_EGN_DECODE_GENDER;
GO

/*==============================================================*/
/* FUNCTION: FN_EGN_DECODE_BIRTHDATE                            */
/* Returns decoded birthdate or NULL if format/date invalid     */
/* SQL Server 2008 safe                                          */
/*==============================================================*/
CREATE FUNCTION DATA.FN_EGN_DECODE_BIRTHDATE
(
    @EGN VARCHAR(10)
)
RETURNS DATE
AS
BEGIN
    DECLARE
        @YY INT,
        @MM INT,
        @DD INT,
        @FULL_YEAR INT,
        @REAL_MONTH INT,
        @DATE_STR VARCHAR(10),
        @RESULT DATE;

    IF @EGN IS NULL OR LEN(@EGN) <> 10 OR @EGN LIKE '%[^0-9]%'
        RETURN NULL;

    SET @YY = CAST(SUBSTRING(@EGN, 1, 2) AS INT);
    SET @MM = CAST(SUBSTRING(@EGN, 3, 2) AS INT);
    SET @DD = CAST(SUBSTRING(@EGN, 5, 2) AS INT);

    IF @MM BETWEEN 1 AND 12
    BEGIN
        SET @FULL_YEAR = 1900 + @YY;
        SET @REAL_MONTH = @MM;
    END
    ELSE IF @MM BETWEEN 21 AND 32
    BEGIN
        SET @FULL_YEAR = 1800 + @YY;
        SET @REAL_MONTH = @MM - 20;
    END
    ELSE IF @MM BETWEEN 41 AND 52
    BEGIN
        SET @FULL_YEAR = 2000 + @YY;
        SET @REAL_MONTH = @MM - 40;
    END
    ELSE
        RETURN NULL;

    SET @DATE_STR =
        RIGHT('0000' + CAST(@FULL_YEAR AS VARCHAR(4)), 4) + '-' +
        RIGHT('00' + CAST(@REAL_MONTH AS VARCHAR(2)), 2) + '-' +
        RIGHT('00' + CAST(@DD AS VARCHAR(2)), 2);

    IF ISDATE(@DATE_STR) = 0
        RETURN NULL;

    SET @RESULT = CAST(@DATE_STR AS DATE);
    RETURN @RESULT;
END
GO

/*==============================================================*/
/* FUNCTION: FN_EGN_DECODE_GENDER                               */
/* Returns M / F or NULL if format invalid                      */
/*==============================================================*/
CREATE FUNCTION DATA.FN_EGN_DECODE_GENDER
(
    @EGN VARCHAR(10)
)
RETURNS CHAR(1)
AS
BEGIN
    DECLARE @RESULT CHAR(1);

    IF @EGN IS NULL OR LEN(@EGN) <> 10 OR @EGN LIKE '%[^0-9]%'
        RETURN NULL;

    IF CAST(SUBSTRING(@EGN, 9, 1) AS INT) % 2 = 0
        SET @RESULT = 'M';
    ELSE
        SET @RESULT = 'F';

    RETURN @RESULT;
END
GO

/*==============================================================*/
/* FUNCTION: FN_EGN_IS_VALID                                    */
/* Validates format, encoded date, checksum                     */
/* Returns 1 = valid, 0 = invalid                               */
/*==============================================================*/
CREATE FUNCTION DATA.FN_EGN_IS_VALID
(
    @EGN VARCHAR(10)
)
RETURNS BIT
AS
BEGIN
    DECLARE
        @CTRL INT,
        @CALC_SUM INT,
        @CALC_CTRL INT;

    IF @EGN IS NULL OR LEN(@EGN) <> 10 OR @EGN LIKE '%[^0-9]%'
        RETURN 0;

    IF DATA.FN_EGN_DECODE_BIRTHDATE(@EGN) IS NULL
        RETURN 0;

    SET @CTRL = CAST(SUBSTRING(@EGN, 10, 1) AS INT);

    SET @CALC_SUM =
          CAST(SUBSTRING(@EGN,1,1) AS INT) * 2
        + CAST(SUBSTRING(@EGN,2,1) AS INT) * 4
        + CAST(SUBSTRING(@EGN,3,1) AS INT) * 8
        + CAST(SUBSTRING(@EGN,4,1) AS INT) * 5
        + CAST(SUBSTRING(@EGN,5,1) AS INT) * 10
        + CAST(SUBSTRING(@EGN,6,1) AS INT) * 9
        + CAST(SUBSTRING(@EGN,7,1) AS INT) * 7
        + CAST(SUBSTRING(@EGN,8,1) AS INT) * 3
        + CAST(SUBSTRING(@EGN,9,1) AS INT) * 6;

    SET @CALC_CTRL = @CALC_SUM % 11;

    IF @CALC_CTRL = 10
        SET @CALC_CTRL = 0;

    IF @CALC_CTRL <> @CTRL
        RETURN 0;

    RETURN 1;
END
GO

/*==============================================================*/
/* PROCEDURE: SP_VERIFY_CLIENT_EGN                              */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_VERIFY_CLIENT_EGN
    @CLIENT_ID INT,
    @RESULT_CODE INT OUTPUT,
    @RESULT_MESSAGE VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CLIENT_EGN VARCHAR(10),
        @CLIENT_BIRTHDATE DATE,
        @CLIENT_GENDER CHAR(1),
        @DECODED_BIRTHDATE DATE,
        @DECODED_GENDER CHAR(1),
        @IS_VALID BIT,
        @NEEDS_BIRTHDATE_CORRECTION BIT,
        @NEEDS_GENDER_CORRECTION BIT;

    SET @NEEDS_BIRTHDATE_CORRECTION = 0;
    SET @NEEDS_GENDER_CORRECTION = 0;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM DATA.CLIENT
            WHERE CLIENT_ID = @CLIENT_ID
        )
        BEGIN
            SET @RESULT_CODE = -2;
            SET @RESULT_MESSAGE = 'Client not found.';
            RETURN;
        END

        SELECT
            @CLIENT_EGN = CLIENT_EGN,
            @CLIENT_BIRTHDATE = CLIENT_BIRTHDATE,
            @CLIENT_GENDER = CLIENT_GENDER
        FROM DATA.CLIENT
        WHERE CLIENT_ID = @CLIENT_ID;

        SET @IS_VALID = DATA.FN_EGN_IS_VALID(@CLIENT_EGN);

        IF @IS_VALID = 0
        BEGIN
            SET @RESULT_CODE = -1;
            SET @RESULT_MESSAGE = 'Invalid EGN. Client data requires manual correction.';
            RETURN;
        END

        SET @DECODED_BIRTHDATE = DATA.FN_EGN_DECODE_BIRTHDATE(@CLIENT_EGN);
        SET @DECODED_GENDER = DATA.FN_EGN_DECODE_GENDER(@CLIENT_EGN);

        IF @CLIENT_BIRTHDATE <> @DECODED_BIRTHDATE
            SET @NEEDS_BIRTHDATE_CORRECTION = 1;

        IF @CLIENT_GENDER IS NULL OR @CLIENT_GENDER <> @DECODED_GENDER
            SET @NEEDS_GENDER_CORRECTION = 1;

        UPDATE DATA.CLIENT
        SET
            CLIENT_BIRTHDATE = CASE
                                  WHEN @NEEDS_BIRTHDATE_CORRECTION = 1 THEN @DECODED_BIRTHDATE
                                  ELSE CLIENT_BIRTHDATE
                               END,
            CLIENT_GENDER = CASE
                               WHEN @NEEDS_GENDER_CORRECTION = 1 THEN @DECODED_GENDER
                               ELSE CLIENT_GENDER
                            END
        WHERE CLIENT_ID = @CLIENT_ID;

        IF @NEEDS_BIRTHDATE_CORRECTION = 0 AND @NEEDS_GENDER_CORRECTION = 0
        BEGIN
            SET @RESULT_CODE = 0;
            SET @RESULT_MESSAGE = 'EGN verified successfully. No corrections needed.';
        END
        ELSE
        BEGIN
            SET @RESULT_CODE = 1;
            SET @RESULT_MESSAGE = 'EGN verified successfully. Client data corrected from valid EGN.';
        END

        SELECT
            @CLIENT_ID AS CLIENT_ID,
            @CLIENT_EGN AS CLIENT_EGN,
            @IS_VALID AS EGN_IS_VALID,
            @DECODED_BIRTHDATE AS DECODED_BIRTHDATE,
            @DECODED_GENDER AS DECODED_GENDER,
            CASE WHEN @NEEDS_BIRTHDATE_CORRECTION = 1 THEN 'YES' ELSE 'NO' END AS BIRTHDATE_CORRECTED,
            CASE WHEN @NEEDS_GENDER_CORRECTION = 1 THEN 'YES' ELSE 'NO' END AS GENDER_CORRECTED,
            @RESULT_CODE AS RESULT_CODE,
            @RESULT_MESSAGE AS RESULT_MESSAGE;
    END TRY
    BEGIN CATCH
        SET @RESULT_CODE = -9;
        SET @RESULT_MESSAGE = ERROR_MESSAGE();
    END CATCH
END
GO

-- TEST
/*
DECLARE @RC INT, @MSG VARCHAR(255);

EXEC DATA.SP_VERIFY_CLIENT_EGN
    @CLIENT_ID = 4,
    @RESULT_CODE = @RC OUTPUT,
    @RESULT_MESSAGE = @MSG OUTPUT;

SELECT @RC AS RESULT_CODE, @MSG AS RESULT_MESSAGE;
/*

