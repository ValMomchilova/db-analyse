/*==============================================================*/
/* TABLE: EMPLOYEE                                              */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.EMPLOYEE')
   AND type = 'U'
)
DROP TABLE DATA.EMPLOYEE;
GO

CREATE TABLE DATA.EMPLOYEE (
   EMPLOYEE_ID             INT                  IDENTITY NOT NULL,
   EMPLOYEE_NAME           VARCHAR(50)          NOT NULL,
   EMPLOYEE_SURNAME        VARCHAR(50)          NOT NULL,
   EMPLOYEE_LASTNAME       VARCHAR(50)          NOT NULL,
   SENIORITY_CODE          CHAR(1)              NOT NULL,
   COMPANY_IDENTIFIER      VARCHAR(30)          NOT NULL,
   EMAIL                   VARCHAR(100)         NOT NULL,
   MODIFIED_ON             DATE                 NULL,
   MODIFIED_BY             VARCHAR(50)          NULL,
   CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EMPLOYEE_ID),
   CONSTRAINT FK_EMPLOYEE_REFERENCE_SENIORITY
      FOREIGN KEY (SENIORITY_CODE)
      REFERENCES DATA.SENIORITY_LEVEL (SENIORITY_CODE),
   CONSTRAINT UQ_EMPLOYEE_COMPANY_IDENTIFIER UNIQUE (COMPANY_IDENTIFIER),
   CONSTRAINT UQ_EMPLOYEE_EMAIL UNIQUE (EMAIL)
);
GO