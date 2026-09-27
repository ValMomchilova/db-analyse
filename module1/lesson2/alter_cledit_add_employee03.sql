
/*==============================================================*/
/* EXTEND CREDIT WITH EMPLOYEE                                  */
/*==============================================================*/
IF COL_LENGTH('DATA.CREDIT', 'EMPLOYEE_ID') IS NULL
BEGIN
   ALTER TABLE DATA.CREDIT
   ADD EMPLOYEE_ID INT NULL;
END
GO

IF EXISTS (
   SELECT 1
   FROM sys.sysreferences r
   JOIN sys.sysobjects o
      ON o.id = r.constid AND o.type = 'F'
   WHERE r.fkeyid = OBJECT_ID('DATA.CREDIT')
   AND o.name = 'FK_CREDIT_REFERENCE_EMPLOYEE'
)
ALTER TABLE DATA.CREDIT
   DROP CONSTRAINT FK_CREDIT_REFERENCE_EMPLOYEE;
GO

ALTER TABLE DATA.CREDIT
ADD CONSTRAINT FK_CREDIT_REFERENCE_EMPLOYEE
FOREIGN KEY (EMPLOYEE_ID)
REFERENCES DATA.EMPLOYEE (EMPLOYEE_ID);

GO


/*==============================================================*/
/* SAMPLE EMPLOYEES                                             */
/*==============================================================*/
INSERT INTO DATA.EMPLOYEE
(
   EMPLOYEE_NAME,
   EMPLOYEE_SURNAME,
   EMPLOYEE_LASTNAME,
   SENIORITY_CODE,
   COMPANY_IDENTIFIER,
   EMAIL
)
VALUES
('Иван', 'Петров', 'Георгиев', 'S', 'EMP001', 'ivan.georgiev@creditcompany.bg'),
('Мария', 'Николова', 'Иванова', 'M', 'EMP002', 'maria.ivanova@creditcompany.bg'),
('Георги', 'Димитров', 'Стоянов', 'J', 'EMP003', 'georgi.stoyanov@creditcompany.bg');

GO


/*==============================================================*/
/* Populate existing credits                                            */
/*==============================================================*/

UPDATE DATA.CREDIT
SET EMPLOYEE_ID =
   CASE
      WHEN CREDIT_NO % 3 = 1 THEN 1
      WHEN CREDIT_NO % 3 = 2 THEN 2
      ELSE 3
   END
WHERE EMPLOYEE_ID IS NULL;
GO

/*==============================================================*/
/* Populate existing credits                                            */
/*==============================================================*/
ALTER TABLE DATA.CREDIT
ALTER COLUMN EMPLOYEE_ID INT NOT NULL;
GO
