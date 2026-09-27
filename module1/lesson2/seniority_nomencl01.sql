USE [data_camp];
GO

/*==============================================================*/
/* TABLE: SENIORITY_LEVEL                                       */
/*==============================================================*/
IF EXISTS (
   SELECT 1
   FROM sysobjects
   WHERE id = OBJECT_ID('DATA.SENIORITY_LEVEL')
   AND type = 'U'
)
DROP TABLE DATA.SENIORITY_LEVEL;
GO

CREATE TABLE DATA.SENIORITY_LEVEL (
   SENIORITY_CODE          CHAR(1)              NOT NULL,
   SENIORITY_NAME          VARCHAR(50)          NOT NULL,
   CONSTRAINT PK_SENIORITY_LEVEL PRIMARY KEY (SENIORITY_CODE)
);
GO

INSERT INTO DATA.SENIORITY_LEVEL (SENIORITY_CODE, SENIORITY_NAME) VALUES ('J', 'Junior');
INSERT INTO DATA.SENIORITY_LEVEL (SENIORITY_CODE, SENIORITY_NAME) VALUES ('M', 'Mid');
INSERT INTO DATA.SENIORITY_LEVEL (SENIORITY_CODE, SENIORITY_NAME) VALUES ('S', 'Senior');
GO