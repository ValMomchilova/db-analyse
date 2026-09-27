USE [data_camp];
GO

/*==============================================================*/
/* OPTIONAL: ADD COLUMNS NEEDED FOR WORKFLOW                    */
/*==============================================================*/
IF COL_LENGTH('DATA.CREDIT', 'CREDIT_PAID_SUM') IS NULL
BEGIN
    ALTER TABLE DATA.CREDIT
    ADD CREDIT_PAID_SUM NUMERIC(10,2) NULL;
END
GO

IF COL_LENGTH('DATA.CREDIT', 'CREDIT_PAYMENT_CNT') IS NULL
BEGIN
    ALTER TABLE DATA.CREDIT
    ADD CREDIT_PAYMENT_CNT INT NULL;
END
GO

IF COL_LENGTH('DATA.REPAYMENT_SCHEDULE', 'PAID_AMOUNT') IS NULL
BEGIN
    ALTER TABLE DATA.REPAYMENT_SCHEDULE
    ADD PAID_AMOUNT NUMERIC(10,2) NULL;
END
GO

IF COL_LENGTH('DATA.REPAYMENT_SCHEDULE', 'PAID_ON') IS NULL
BEGIN
    ALTER TABLE DATA.REPAYMENT_SCHEDULE
    ADD PAID_ON DATE NULL;
END
GO

/*==============================================================*/
/* DROP PROCEDURES IF EXIST                                     */
/*==============================================================*/
IF OBJECT_ID('DATA.SP_DAILY_CREDIT_WORKFLOW', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_DAILY_CREDIT_WORKFLOW;
GO

IF OBJECT_ID('DATA.SP_WF_CHECK_ACTIVE_PROGRESS', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_WF_CHECK_ACTIVE_PROGRESS;
GO

IF OBJECT_ID('DATA.SP_WF_ALIGN_ACTIVE_PAYMENTS', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_WF_ALIGN_ACTIVE_PAYMENTS;
GO

IF OBJECT_ID('DATA.SP_WF_VERIFIED_TO_ACTIVE', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_WF_VERIFIED_TO_ACTIVE;
GO

IF OBJECT_ID('DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION', 'P') IS NOT NULL
    DROP PROCEDURE DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION;
GO

/*==============================================================*/
/* 1. REGISTERED -> VERIFIED / INSPECTION                       */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CLIENT_ID INT,
        @CREDIT_NO NUMERIC(18,0),
        @RC INT,
        @MSG VARCHAR(255),
        @IDCARD_RESULT VARCHAR(50);

    DECLARE REG_CURSOR CURSOR FOR
        SELECT C.CREDIT_NO, C.CLIENT_ID
        FROM DATA.CREDIT C
        WHERE C.STATUS_CODE = 'R';

    OPEN REG_CURSOR;
    FETCH NEXT FROM REG_CURSOR INTO @CREDIT_NO, @CLIENT_ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @RC = NULL;
        SET @MSG = NULL;
        SET @IDCARD_RESULT = NULL;

        EXEC DATA.SP_VERIFY_CLIENT_EGN
            @CLIENT_ID = @CLIENT_ID,
            @RESULT_CODE = @RC OUTPUT,
            @RESULT_MESSAGE = @MSG OUTPUT;

        SELECT
            @IDCARD_RESULT =
                DATA.FN_TEST_IDCARD_VALIDITY
                (
                    CLIENT_BIRTHDATE,
                    CLIENT_IDCARD_ISSUED,
                    CLIENT_IDCARD_VALIDTO
                )
        FROM DATA.CLIENT
        WHERE CLIENT_ID = @CLIENT_ID;

        IF @RC >= 0 AND @IDCARD_RESULT = 'VALID'
        BEGIN
            UPDATE DATA.CREDIT
            SET STATUS_CODE = 'V'
            WHERE CREDIT_NO = @CREDIT_NO;
        END
        ELSE
        BEGIN
            UPDATE DATA.CREDIT
            SET STATUS_CODE = 'I'
            WHERE CREDIT_NO = @CREDIT_NO;
        END

        FETCH NEXT FROM REG_CURSOR INTO @CREDIT_NO, @CLIENT_ID;
    END

    CLOSE REG_CURSOR;
    DEALLOCATE REG_CURSOR;
END
GO

/*==============================================================*/
/* 2. VERIFIED -> ACTIVE                                        */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_WF_VERIFIED_TO_ACTIVE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DATA.CREDIT
    SET STATUS_CODE = 'A'
    WHERE STATUS_CODE = 'V'
      AND CREDIT_BEGIN_DATE <= CAST(GETDATE() AS DATE);
END
GO

/*==============================================================*/
/* 3. ALIGN ACTIVE PAYMENTS WITH REPAYMENT SCHEDULE             */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_WF_ALIGN_ACTIVE_PAYMENTS
AS
BEGIN
    SET NOCOUNT ON;

    /* Recalculate credit payment summary directly */
    UPDATE C
    SET
        CREDIT_PAID_SUM = ISNULL(P.PAID_SUM, 0),
        CREDIT_PAYMENT_CNT = ISNULL(P.PAYMENT_CNT, 0)
    FROM DATA.CREDIT C
    LEFT JOIN
    (
        SELECT
            CREDIT_NO,
            SUM(PAYMENT_AMOUNT) AS PAID_SUM,
            COUNT(*) AS PAYMENT_CNT
        FROM DATA.PAYMENT
        GROUP BY CREDIT_NO
    ) P
      ON C.CREDIT_NO = P.CREDIT_NO
    WHERE C.STATUS_CODE = 'A';

    /* Recalculate installment paid amount and paid date directly */
    UPDATE RS
    SET
        PAID_AMOUNT = ISNULL(X.ALLOC_SUM, 0),
        PAID_ON = X.LAST_PAYMENT_DATE
    FROM DATA.REPAYMENT_SCHEDULE RS
    JOIN DATA.CREDIT C
      ON RS.CREDIT_NO = C.CREDIT_NO
    LEFT JOIN
    (
        SELECT
            PA.CREDIT_NO,
            PA.INSTALLMENT_NO,
            SUM(PA.ALLOCATED_AMOUNT) AS ALLOC_SUM,
            MAX(ISNULL(P.PAYMENT_VALUE_DATE, CAST(P.PAYMENT_EXECUTED_AT AS DATE))) AS LAST_PAYMENT_DATE
        FROM DATA.PAYMENT_ALLOCATION PA
        JOIN DATA.PAYMENT P
          ON PA.PAYMENT_ID = P.PAYMENT_ID
         AND PA.CREDIT_NO = P.CREDIT_NO
        GROUP BY
            PA.CREDIT_NO,
            PA.INSTALLMENT_NO
    ) X
      ON RS.CREDIT_NO = X.CREDIT_NO
     AND RS.INSTALLMENT_NO = X.INSTALLMENT_NO
    WHERE C.STATUS_CODE = 'A';

    /* Set installment status */
    UPDATE RS
    SET ISTATUS_CODE =
        CASE
            WHEN ISNULL(RS.PAID_AMOUNT, 0) >= RS.INSTALLMENT_SUM THEN 'P'
            WHEN ISNULL(RS.PAID_AMOUNT, 0) > 0 AND ISNULL(RS.PAID_AMOUNT, 0) < RS.INSTALLMENT_SUM THEN 'X'
            WHEN RS.INSTALLMENT_DATE < CAST(GETDATE() AS DATE) AND ISNULL(RS.PAID_AMOUNT, 0) = 0 THEN 'O'
            ELSE 'D'
        END
    FROM DATA.REPAYMENT_SCHEDULE RS
    JOIN DATA.CREDIT C
      ON RS.CREDIT_NO = C.CREDIT_NO
    WHERE C.STATUS_CODE = 'A';
END
GO

/*==============================================================*/
/* 4. CHECK ACTIVE CREDIT PROGRESS                              */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_WF_CHECK_ACTIVE_PROGRESS
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TODAY DATE;
    SET @TODAY = CAST(GETDATE() AS DATE);

    /* Active -> Closed : all installments paid */
    UPDATE C
    SET STATUS_CODE = 'C'
    FROM DATA.CREDIT C
    WHERE C.STATUS_CODE = 'A'
      AND NOT EXISTS
      (
          SELECT 1
          FROM DATA.REPAYMENT_SCHEDULE RS
          WHERE RS.CREDIT_NO = C.CREDIT_NO
            AND RS.ISTATUS_CODE <> 'P'
      );

    /* Active -> Overdue : end date reached and missing installments */
    UPDATE C
    SET STATUS_CODE = 'O'
    FROM DATA.CREDIT C
    WHERE C.STATUS_CODE = 'A'
      AND C.CREDIT_END_DATE <= @TODAY
      AND EXISTS
      (
          SELECT 1
          FROM DATA.REPAYMENT_SCHEDULE RS
          WHERE RS.CREDIT_NO = C.CREDIT_NO
            AND RS.ISTATUS_CODE <> 'P'
      );

    /* Active -> Overdue : before end date, paid less than planned up to today */
    UPDATE C
    SET STATUS_CODE = 'O'
    FROM DATA.CREDIT C
    JOIN
    (
        SELECT
            RS.CREDIT_NO,
            SUM(CASE WHEN RS.INSTALLMENT_DATE <= @TODAY THEN RS.INSTALLMENT_SUM ELSE 0 END) AS PLANNED_TO_DATE,
            SUM(ISNULL(RS.PAID_AMOUNT, 0)) AS PAID_TO_DATE
        FROM DATA.REPAYMENT_SCHEDULE RS
        GROUP BY RS.CREDIT_NO
    ) S
      ON C.CREDIT_NO = S.CREDIT_NO
    WHERE C.STATUS_CODE = 'A'
      AND C.CREDIT_END_DATE > @TODAY
      AND S.PAID_TO_DATE < S.PLANNED_TO_DATE;
END
GO

/*==============================================================*/
/* 5. WRAPPER PROCEDURE                                         */
/*==============================================================*/
CREATE PROCEDURE DATA.SP_DAILY_CREDIT_WORKFLOW
AS
BEGIN
    SET NOCOUNT ON;

    EXEC DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION;
    EXEC DATA.SP_WF_VERIFIED_TO_ACTIVE;
    EXEC DATA.SP_WF_ALIGN_ACTIVE_PAYMENTS;
    EXEC DATA.SP_WF_CHECK_ACTIVE_PROGRESS;
END
GO



-- test
--EXEC DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION;
--EXEC DATA.SP_DAILY_CREDIT_WORKFLOW
select * from data.credit