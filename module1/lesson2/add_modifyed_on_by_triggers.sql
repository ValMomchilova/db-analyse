USE [data_camp];
GO

/*==============================================================*/
/* TRIGGER: CLIENT                                              */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_CLIENT_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_CLIENT_MODIFIED;
GO

CREATE TRIGGER DATA.TR_CLIENT_MODIFIED
ON DATA.CLIENT
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE c
      SET c.MODIFIED_ON = CAST(GETDATE() AS DATE),
          c.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.CLIENT c
   JOIN inserted i
     ON c.CLIENT_ID = i.CLIENT_ID;
END
GO


/*==============================================================*/
/* TRIGGER: CREDIT                                              */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_CREDIT_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_CREDIT_MODIFIED;
GO

CREATE TRIGGER DATA.TR_CREDIT_MODIFIED
ON DATA.CREDIT
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE c
      SET c.MODIFIED_ON = CAST(GETDATE() AS DATE),
          c.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.CREDIT c
   JOIN inserted i
     ON c.CREDIT_NO = i.CREDIT_NO;
END
GO


/*==============================================================*/
/* TRIGGER: REPAYMENT_SCHEDULE                                  */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_REPAYMENT_SCHEDULE_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_REPAYMENT_SCHEDULE_MODIFIED;
GO

CREATE TRIGGER DATA.TR_REPAYMENT_SCHEDULE_MODIFIED
ON DATA.REPAYMENT_SCHEDULE
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE rs
      SET rs.MODIFIED_ON = CAST(GETDATE() AS DATE),
          rs.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.REPAYMENT_SCHEDULE rs
   JOIN inserted i
     ON rs.CREDIT_NO = i.CREDIT_NO
    AND rs.INSTALLMENT_NO = i.INSTALLMENT_NO;
END
GO


/*==============================================================*/
/* TRIGGER: COMPANY_BANK_ACCOUNT                                */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_COMPANY_BANK_ACCOUNT_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_COMPANY_BANK_ACCOUNT_MODIFIED;
GO

CREATE TRIGGER DATA.TR_COMPANY_BANK_ACCOUNT_MODIFIED
ON DATA.COMPANY_BANK_ACCOUNT
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE cba
      SET cba.MODIFIED_ON = CAST(GETDATE() AS DATE),
          cba.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.COMPANY_BANK_ACCOUNT cba
   JOIN inserted i
     ON cba.COMPANY_BANK_ACCOUNT_ID = i.COMPANY_BANK_ACCOUNT_ID;
END
GO


/*==============================================================*/
/* TRIGGER: CLIENT_BANK_ACCOUNT                                 */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_CLIENT_BANK_ACCOUNT_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_CLIENT_BANK_ACCOUNT_MODIFIED;
GO

CREATE TRIGGER DATA.TR_CLIENT_BANK_ACCOUNT_MODIFIED
ON DATA.CLIENT_BANK_ACCOUNT
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE cba
      SET cba.MODIFIED_ON = CAST(GETDATE() AS DATE),
          cba.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.CLIENT_BANK_ACCOUNT cba
   JOIN inserted i
     ON cba.CLIENT_BANK_ACCOUNT_ID = i.CLIENT_BANK_ACCOUNT_ID;
END
GO


/*==============================================================*/
/* TRIGGER: PAYMENT                                             */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_PAYMENT_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_PAYMENT_MODIFIED;
GO

CREATE TRIGGER DATA.TR_PAYMENT_MODIFIED
ON DATA.PAYMENT
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE p
      SET p.MODIFIED_ON = CAST(GETDATE() AS DATE),
          p.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.PAYMENT p
   JOIN inserted i
     ON p.PAYMENT_ID = i.PAYMENT_ID;
END
GO


/*==============================================================*/
/* TRIGGER: PAYMENT_ALLOCATION                                  */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.TR_PAYMENT_ALLOCATION_MODIFIED')
   AND type = 'TR'
)
DROP TRIGGER DATA.TR_PAYMENT_ALLOCATION_MODIFIED;
GO

CREATE TRIGGER DATA.TR_PAYMENT_ALLOCATION_MODIFIED
ON DATA.PAYMENT_ALLOCATION
AFTER INSERT, UPDATE
AS
BEGIN
   SET NOCOUNT ON;

   UPDATE pa
      SET pa.MODIFIED_ON = CAST(GETDATE() AS DATE),
          pa.MODIFIED_BY = SUSER_SNAME()
   FROM DATA.PAYMENT_ALLOCATION pa
   JOIN inserted i
     ON pa.PAYMENT_ID = i.PAYMENT_ID
    AND pa.CREDIT_NO = i.CREDIT_NO
    AND pa.INSTALLMENT_NO = i.INSTALLMENT_NO;
END
GO