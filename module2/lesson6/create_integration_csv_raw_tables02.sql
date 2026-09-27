USE [data_camp];
GO

/*==============================================================*/
/* RAW_CUSTOMERS                                                */
/*==============================================================*/
IF OBJECT_ID('Integration.RAW_CUSTOMERS', 'U') IS NOT NULL
    DROP TABLE Integration.RAW_CUSTOMERS;

CREATE TABLE Integration.RAW_CUSTOMERS
(
    CLIENT_ID VARCHAR(50),
    CLIENT_NAME VARCHAR(50),
    CLIENT_SURNAME VARCHAR(50),
    CLIENT_LASTNAME VARCHAR(50),
    CLIENT_EGN VARCHAR(20),
    CLIENT_GENDER VARCHAR(10),
    CLIENT_BIRTHDATE VARCHAR(50),
    CLIENT_IDCARD_NO VARCHAR(50),
    CLIENT_IDCARD_ISSUED VARCHAR(50),
    CLIENT_IDCARD_VALIDTO VARCHAR(50),
    CLIENT_IDCARD_ISSUER VARCHAR(50),
    EDU_CODE VARCHAR(10),
    CLIENT_INCOME VARCHAR(50),
    MSTATUS_CODE VARCHAR(10)
);
GO

/*==============================================================*/
/* RAW_CREDITS                                                  */
/*==============================================================*/
IF OBJECT_ID('Integration.RAW_CREDITS', 'U') IS NOT NULL
    DROP TABLE Integration.RAW_CREDITS;

CREATE TABLE Integration.RAW_CREDITS
(
    CREDIT_NO VARCHAR(50),
    CLIENT_EGN VARCHAR(20),
    LOAN_TYPE_ID VARCHAR(10),
    CREDIT_SIGNED VARCHAR(10),
    CREDIT_BEGIN_DATE VARCHAR(50),
    CREDIT_END_DATE VARCHAR(50),
    CREDIT_SUM VARCHAR(50),
    CREDIT_INTEREST_PRC VARCHAR(50),
    CREDIT_ALLSUM VARCHAR(50),
    CREDIT_GPR VARCHAR(50),
    STATUS_CODE VARCHAR(10),
    CREDIT_FIRST_MATURITY VARCHAR(50),
    CREDIT_ISNTALLMENTS_CNT VARCHAR(50),
    CREDIT_INSTALLMENT VARCHAR(50),
    EMPLOYEE_ID VARCHAR(50)
);
GO

/*==============================================================*/
/* RAW_REPAYMENT_SCHEDULE                                       */
/*==============================================================*/
IF OBJECT_ID('Integration.RAW_REPAYMENT', 'U') IS NOT NULL
    DROP TABLE Integration.RAW_REPAYMENT;

CREATE TABLE Integration.RAW_REPAYMENT
(
    CREDIT_NO VARCHAR(50),
    INSTALLMENT_NO VARCHAR(50),
    INSTALLMENT_DATE VARCHAR(50),
    INSTALLMENT_SUM VARCHAR(50),
    INSTALLMENT_PRINCIPLE VARCHAR(50),
    INSTALLMENT_INTEREST VARCHAR(50),
    INSTALLMENT_RESTSUM VARCHAR(50),
    ISTATUS_CODE VARCHAR(10),
    PAID_AMOUNT VARCHAR(50),
    PAID_ON VARCHAR(50)
);
GO