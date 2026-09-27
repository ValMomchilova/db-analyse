USE [data_camp];
GO

/*==============================================================*/
/* 1. DROP DEPENDENCIES IN CORRECT ORDER                        */
/*==============================================================*/

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.PAYMENT_ALLOCATION')
   AND o.name = 'FK_PAY_ALLOC_REFERENCE_PAYMENT'
)
ALTER TABLE DATA.PAYMENT_ALLOCATION
   DROP CONSTRAINT FK_PAY_ALLOC_REFERENCE_PAYMENT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.PAYMENT_ALLOCATION')
   AND o.name = 'FK_PAY_ALLOC_REFERENCE_INSTALLMENT'
)
ALTER TABLE DATA.PAYMENT_ALLOCATION
   DROP CONSTRAINT FK_PAY_ALLOC_REFERENCE_INSTALLMENT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.PAYMENT')
   AND o.name = 'FK_PAYMENT_REFERENCE_CREDIT'
)
ALTER TABLE DATA.PAYMENT
   DROP CONSTRAINT FK_PAYMENT_REFERENCE_CREDIT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.PAYMENT')
   AND o.name = 'FK_PAYMENT_REFERENCE_CLIENT_ACCOUNT'
)
ALTER TABLE DATA.PAYMENT
   DROP CONSTRAINT FK_PAYMENT_REFERENCE_CLIENT_ACCOUNT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.PAYMENT')
   AND o.name = 'FK_PAYMENT_REFERENCE_COMPANY_ACCOUNT'
)
ALTER TABLE DATA.PAYMENT
   DROP CONSTRAINT FK_PAYMENT_REFERENCE_COMPANY_ACCOUNT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.CLIENT_BANK_ACCOUNT')
   AND o.name = 'FK_CL_BANK_ACC_REFERENCE_CLIENT'
)
ALTER TABLE DATA.CLIENT_BANK_ACCOUNT
   DROP CONSTRAINT FK_CL_BANK_ACC_REFERENCE_CLIENT;
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.REPAYMENT_SCHEDULE')
   AND o.name = 'FK_REPAYMENT_REFERENCE_ISTATUS'
)
ALTER TABLE DATA.REPAYMENT_SCHEDULE
   DROP CONSTRAINT FK_REPAYMENT_REFERENCE_ISTATUS;
GO

/*==============================================================*/
/* 2. DROP TABLES                                               */
/*==============================================================*/

IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.PAYMENT_ALLOCATION')
   AND type = 'U'
)
DROP TABLE DATA.PAYMENT_ALLOCATION;
GO

IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.PAYMENT')
   AND type = 'U'
)
DROP TABLE DATA.PAYMENT;
GO

IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.CLIENT_BANK_ACCOUNT')
   AND type = 'U'
)
DROP TABLE DATA.CLIENT_BANK_ACCOUNT;
GO

IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.COMPANY_BANK_ACCOUNT')
   AND type = 'U'
)
DROP TABLE DATA.COMPANY_BANK_ACCOUNT;
GO

IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.INSTALLMENT_STATUS')
   AND type = 'U'
)
DROP TABLE DATA.INSTALLMENT_STATUS;
GO

/*==============================================================*/
/* 3. INSTALLMENT STATUS NOMENCLATURE                           */
/*==============================================================*/

CREATE TABLE DATA.INSTALLMENT_STATUS (
   ISTATUS_CODE             CHAR(1)              NOT NULL,
   ISTATUS_NAME             VARCHAR(100)         NOT NULL,
   CONSTRAINT PK_INSTALLMENT_STATUS PRIMARY KEY (ISTATUS_CODE)
);
GO

INSERT INTO DATA.INSTALLMENT_STATUS (ISTATUS_CODE, ISTATUS_NAME) VALUES ('D', 'Due');
INSERT INTO DATA.INSTALLMENT_STATUS (ISTATUS_CODE, ISTATUS_NAME) VALUES ('P', 'Paid');
INSERT INTO DATA.INSTALLMENT_STATUS (ISTATUS_CODE, ISTATUS_NAME) VALUES ('X', 'Partially Paid');
INSERT INTO DATA.INSTALLMENT_STATUS (ISTATUS_CODE, ISTATUS_NAME) VALUES ('O', 'Overdue');
GO

/*==============================================================*/
/* 4. EXTEND REPAYMENT_SCHEDULE                                 */
/*==============================================================*/

IF COL_LENGTH('DATA.REPAYMENT_SCHEDULE', 'ISTATUS_CODE') IS NULL
BEGIN
   ALTER TABLE DATA.REPAYMENT_SCHEDULE
   ADD ISTATUS_CODE CHAR(1) NULL;
END
GO

ALTER TABLE DATA.REPAYMENT_SCHEDULE
ADD CONSTRAINT FK_REPAYMENT_REFERENCE_ISTATUS
FOREIGN KEY (ISTATUS_CODE)
REFERENCES DATA.INSTALLMENT_STATUS (ISTATUS_CODE);
GO

/*==============================================================*/
/* 5. COMPANY_BANK_ACCOUNT                                      */
/*==============================================================*/

CREATE TABLE DATA.COMPANY_BANK_ACCOUNT (
   COMPANY_BANK_ACCOUNT_ID  INT                  IDENTITY NOT NULL,
   IBAN                     VARCHAR(34)          NOT NULL,
   BIC                      VARCHAR(11)          NOT NULL,
   BANK_NAME                VARCHAR(100)         NOT NULL,
   ACCOUNT_ACTIVE           CHAR(1)              NOT NULL
      CONSTRAINT CK_COMPANY_BANK_ACCOUNT_ACTIVE CHECK (ACCOUNT_ACTIVE IN ('Y','N')),
   MODIFIED_ON              DATE                 NULL,
   MODIFIED_BY              VARCHAR(50)          NULL,
   CONSTRAINT PK_COMPANY_BANK_ACCOUNT PRIMARY KEY (COMPANY_BANK_ACCOUNT_ID),
   CONSTRAINT UQ_COMPANY_BANK_ACCOUNT_IBAN UNIQUE (IBAN)
);
GO

/*==============================================================*/
/* 6. CLIENT_BANK_ACCOUNT                                       */
/*==============================================================*/

CREATE TABLE DATA.CLIENT_BANK_ACCOUNT (
   CLIENT_BANK_ACCOUNT_ID   INT                  IDENTITY NOT NULL,
   CLIENT_ID                INT                  NOT NULL,
   IBAN                     VARCHAR(34)          NOT NULL,
   BIC                      VARCHAR(11)          NOT NULL,
   ACCOUNT_HOLDER_NAME      VARCHAR(140)         NOT NULL,
   ACCOUNT_ACTIVE           CHAR(1)              NOT NULL
      CONSTRAINT CK_CLIENT_BANK_ACCOUNT_ACTIVE CHECK (ACCOUNT_ACTIVE IN ('Y','N')),
   MODIFIED_ON              DATE                 NULL,
   MODIFIED_BY              VARCHAR(50)          NULL,
   CONSTRAINT PK_CLIENT_BANK_ACCOUNT PRIMARY KEY (CLIENT_BANK_ACCOUNT_ID),
   CONSTRAINT FK_CL_BANK_ACC_REFERENCE_CLIENT
      FOREIGN KEY (CLIENT_ID)
      REFERENCES DATA.CLIENT (CLIENT_ID),
   CONSTRAINT UQ_CLIENT_BANK_ACCOUNT_IBAN UNIQUE (IBAN)
);
GO

/*==============================================================*/
/* 7. PAYMENT                                                   */
/* One payment belongs to one contract only                     */
/*==============================================================*/

CREATE TABLE DATA.PAYMENT (
   PAYMENT_ID               INT                  IDENTITY NOT NULL,
   CREDIT_NO                NUMERIC              NOT NULL,
   CLIENT_BANK_ACCOUNT_ID   INT                  NOT NULL,
   COMPANY_BANK_ACCOUNT_ID  INT                  NOT NULL,
   PAYMENT_AMOUNT           NUMERIC(10,2)        NOT NULL,
   PAYMENT_EXECUTED_AT      DATETIME             NOT NULL,
   PAYMENT_VALUE_DATE       DATE                 NULL,
   PAYMENT_REFERENCE        VARCHAR(50)          NULL,
   PAYMENT_REASON           VARCHAR(140)         NULL,
   PAYMENT_DETAILS          VARCHAR(255)         NULL,
   BANK_TRANSACTION_ID      VARCHAR(100)         NULL,
   MODIFIED_ON              DATE                 NULL,
   MODIFIED_BY              VARCHAR(50)          NULL,

   CONSTRAINT PK_PAYMENT PRIMARY KEY (PAYMENT_ID),
   CONSTRAINT UQ_PAYMENT_PAYMENTID_CREDIT UNIQUE (PAYMENT_ID, CREDIT_NO),

   CONSTRAINT FK_PAYMENT_REFERENCE_CREDIT
      FOREIGN KEY (CREDIT_NO)
      REFERENCES DATA.CREDIT (CREDIT_NO),

   CONSTRAINT FK_PAYMENT_REFERENCE_CLIENT_ACCOUNT
      FOREIGN KEY (CLIENT_BANK_ACCOUNT_ID)
      REFERENCES DATA.CLIENT_BANK_ACCOUNT (CLIENT_BANK_ACCOUNT_ID),

   CONSTRAINT FK_PAYMENT_REFERENCE_COMPANY_ACCOUNT
      FOREIGN KEY (COMPANY_BANK_ACCOUNT_ID)
      REFERENCES DATA.COMPANY_BANK_ACCOUNT (COMPANY_BANK_ACCOUNT_ID),

   CONSTRAINT CK_PAYMENT_AMOUNT_POSITIVE
      CHECK (PAYMENT_AMOUNT > 0)
);
GO

/*==============================================================*/
/* 8. PAYMENT_ALLOCATION                                        */
/* Maps payment to one or more installments of same contract    */
/*==============================================================*/

CREATE TABLE DATA.PAYMENT_ALLOCATION (
   PAYMENT_ID               INT                  NOT NULL,
   CREDIT_NO                NUMERIC              NOT NULL,
   INSTALLMENT_NO           INT                  NOT NULL,
   ALLOCATED_AMOUNT         NUMERIC(10,2)        NOT NULL,
   MODIFIED_ON              DATE                 NULL,
   MODIFIED_BY              VARCHAR(50)          NULL,

   CONSTRAINT PK_PAYMENT_ALLOCATION
      PRIMARY KEY (PAYMENT_ID, CREDIT_NO, INSTALLMENT_NO),

   CONSTRAINT FK_PAY_ALLOC_REFERENCE_PAYMENT
      FOREIGN KEY (PAYMENT_ID, CREDIT_NO)
      REFERENCES DATA.PAYMENT (PAYMENT_ID, CREDIT_NO),

   CONSTRAINT FK_PAY_ALLOC_REFERENCE_INSTALLMENT
      FOREIGN KEY (CREDIT_NO, INSTALLMENT_NO)
      REFERENCES DATA.REPAYMENT_SCHEDULE (CREDIT_NO, INSTALLMENT_NO),

   CONSTRAINT CK_PAYMENT_ALLOCATION_AMOUNT_POSITIVE
      CHECK (ALLOCATED_AMOUNT > 0)
);
GO