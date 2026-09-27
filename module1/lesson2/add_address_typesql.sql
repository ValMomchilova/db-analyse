USE [data_camp];
GO

/*==============================================================*/
/* DROP FK FROM CLIENT_ADDRESS TO ADDRESS_TYPE IF IT EXISTS     */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.CLIENT_ADDRESS')
     AND o.name = 'FK_CLIENT_ADDRESS_REFERENCE_ADDR_TYPE'
)
ALTER TABLE DATA.CLIENT_ADDRESS
   DROP CONSTRAINT FK_CLIENT_ADDRESS_REFERENCE_ADDR_TYPE;
GO

/*==============================================================*/
/* DROP OLD CHECK CONSTRAINT ON ADDRESS_TYPE IF IT EXISTS       */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sys.check_constraints
   WHERE name = 'CKC_ADDRESS_TYPE_CLIENT_A'
)
ALTER TABLE DATA.CLIENT_ADDRESS
   DROP CONSTRAINT CKC_ADDRESS_TYPE_CLIENT_A;
GO

/*==============================================================*/
/* DROP ADDRESS_TYPE TABLE IF IT EXISTS                         */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.ADDRESS_TYPE')
     AND type = 'U'
)
DROP TABLE DATA.ADDRESS_TYPE;
GO

/*==============================================================*/
/* CREATE ADDRESS_TYPE NOMENCLATURE TABLE                       */
/*==============================================================*/
CREATE TABLE DATA.ADDRESS_TYPE (
   ADDRESS_TYPE_CODE        CHAR(1)              NOT NULL,
   ADDRESS_TYPE_NAME        VARCHAR(100)         NOT NULL,
   CONSTRAINT PK_ADDRESS_TYPE PRIMARY KEY (ADDRESS_TYPE_CODE)
);
GO

/*==============================================================*/
/* INSERT PREDEFINED ADDRESS TYPES                              */
/*==============================================================*/
INSERT INTO DATA.ADDRESS_TYPE (ADDRESS_TYPE_CODE, ADDRESS_TYPE_NAME)
VALUES ('P', 'Permanent address');
GO

INSERT INTO DATA.ADDRESS_TYPE (ADDRESS_TYPE_CODE, ADDRESS_TYPE_NAME)
VALUES ('C', 'Current address');
GO

INSERT INTO DATA.ADDRESS_TYPE (ADDRESS_TYPE_CODE, ADDRESS_TYPE_NAME)
VALUES ('K', 'Correspondence address');
GO

/*==============================================================*/
/* ADD FK FROM CLIENT_ADDRESS TO ADDRESS_TYPE                   */
/*==============================================================*/
ALTER TABLE DATA.CLIENT_ADDRESS
ADD CONSTRAINT FK_CLIENT_ADDRESS_REFERENCE_ADDR_TYPE
FOREIGN KEY (ADDRESS_TYPE)
REFERENCES DATA.ADDRESS_TYPE (ADDRESS_TYPE_CODE);
GO