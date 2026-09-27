USE [data_camp];
GO

IF OBJECT_ID('Integration.SP_LOAD_FROM_OLTP', 'P') IS NOT NULL
    DROP PROCEDURE Integration.SP_LOAD_FROM_OLTP;
GO

CREATE PROCEDURE Integration.SP_LOAD_FROM_OLTP
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LoadDate DATETIME = GETDATE();

    /*==============================================================*/
    /* CLEAN STAGING TABLES                                         */
    /*==============================================================*/
    DELETE FROM Integration.PAYMENT_ALLOCATION;
    DELETE FROM Integration.PAYMENT;
    DELETE FROM Integration.REPAYMENT_SCHEDULE;
    DELETE FROM Integration.CREDIT;
    DELETE FROM Integration.CLIENT_ADDRESS;
    DELETE FROM Integration.CLIENT;

    /*==============================================================*/
    /* LOAD CLIENT                                                  */
    /*==============================================================*/
    INSERT INTO Integration.CLIENT
    (
        CLIENT_ID,
        CLIENT_NAME,
        CLIENT_SURNAME,
        CLIENT_LASTNAME,
        CLIENT_EGN,
        CLIENT_GENDER,
        CLIENT_BIRTHDATE,
        CLIENT_IDCARD_NO,
        CLIENT_IDCARD_ISSUED,
        CLIENT_IDCARD_VALIDTO,
        CLIENT_IDCARD_ISSUER,
        EDU_CODE,
        CLIENT_INCOME,
        MSTATUS_CODE,
        MODIFIED_ON,
        MODIFIED_BY,
        SOURCE_SYSTEM,
        LOAD_DATE
    )
    SELECT
        CLIENT_ID,
        CLIENT_NAME,
        CLIENT_SURNAME,
        CLIENT_LASTNAME,
        CLIENT_EGN,
        CLIENT_GENDER,
        CLIENT_BIRTHDATE,
        CLIENT_IDCARD_NO,
        CLIENT_IDCARD_ISSUED,
        CLIENT_IDCARD_VALIDTO,
        CLIENT_IDCARD_ISSUER,
        EDU_CODE,
        CLIENT_INCOME,
        MSTATUS_CODE,
        MODIFIED_ON,
        MODIFIED_BY,
        'OLTP',
        @LoadDate
    FROM DATA.CLIENT;

    /*==============================================================*/
    /* LOAD CLIENT_ADDRESS                                          */
    /*==============================================================*/
    INSERT INTO Integration.CLIENT_ADDRESS
    SELECT
        ADDRES_ID,
        CLIENT_ID,
        ADDRESS_PCODE,
        ADDRESS_TYPE,
        ADDRESS_TOWN,
        ADDRESS_TEXT,
        'OLTP',
        @LoadDate
    FROM DATA.CLIENT_ADDRESS;

    /*==============================================================*/
    /* LOAD CREDIT                                                  */
    /*==============================================================*/
    INSERT INTO Integration.CREDIT
    SELECT
        CREDIT_NO,
        CLIENT_ID,
        LOAN_TYPE_ID,
        CREDIT_SIGNED,
        CREDIT_BEGIN_DATE,
        CREDIT_END_DATE,
        CREDIT_SUM,
        CREDIT_INTEREST_PRC,
        CREDIT_ALLSUM,
        CREDIT_GPR,
        STATUS_CODE,
        CREDIT_FIRST_MATURITY,
        CREDIT_ISNTALLMENTS_CNT,
        CREDIT_INSTALLMENT,
        MODIFIED_ON,
        MODIFIED_BY,
        EMPLOYEE_ID,
        CREDIT_PAID_SUM,
        CREDIT_PAYMENT_CNT,
        'OLTP',
        @LoadDate
    FROM DATA.CREDIT;

    /*==============================================================*/
    /* LOAD REPAYMENT SCHEDULE                                      */
    /*==============================================================*/
    INSERT INTO Integration.REPAYMENT_SCHEDULE
    SELECT
        CREDIT_NO,
        INSTALLMENT_NO,
        INSTALLMENT_DATE,
        INSTALLMENT_SUM,
        INSTALLMENT_PRINCIPLE,
        INSTALLMENT_INTEREST,
        INSTALLMENT_RESTSUM,
        ISTATUS_CODE,
        MODIFIED_ON,
        MODIFIED_BY,
        PAID_AMOUNT,
        PAID_ON,
        'OLTP',
        @LoadDate
    FROM DATA.REPAYMENT_SCHEDULE;

    /*==============================================================*/
    /* LOAD PAYMENT                                                 */
    /*==============================================================*/
    INSERT INTO Integration.PAYMENT
    SELECT
        PAYMENT_ID,
        CREDIT_NO,
        PAYMENT_AMOUNT,
        PAYMENT_VALUE_DATE,
        PAYMENT_EXECUTED_AT,
        PAYMENT_REFERENCE,
        MODIFIED_ON,
        MODIFIED_BY,
        'OLTP',
        @LoadDate
    FROM DATA.PAYMENT;

    /*==============================================================*/
    /* LOAD PAYMENT ALLOCATION                                      */
    /*==============================================================*/
    INSERT INTO Integration.PAYMENT_ALLOCATION
    SELECT
        PAYMENT_ID,
        CREDIT_NO,
        INSTALLMENT_NO,
        ALLOCATED_AMOUNT,
        MODIFIED_ON,
        MODIFIED_BY,
        'OLTP',
        @LoadDate
    FROM DATA.PAYMENT_ALLOCATION;

END;
GO