USE [data_camp];
GO

/*==============================================================*/
/* DROP FACT FIRST                                              */
/*==============================================================*/
IF OBJECT_ID('OLAP.FACT_CUSTOMER_SEGMENTATION', 'U') IS NOT NULL
    DROP TABLE OLAP.FACT_CUSTOMER_SEGMENTATION;
GO

/*==============================================================*/
/* DROP DIMENSIONS                                              */
/*==============================================================*/
IF OBJECT_ID('OLAP.DIM_AGE_GROUP', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_AGE_GROUP;
GO

IF OBJECT_ID('OLAP.DIM_INCOME_GROUP', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_INCOME_GROUP;
GO

IF OBJECT_ID('OLAP.DIM_EDUCATION', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_EDUCATION;
GO

/*==============================================================*/
/* DIM_AGE_GROUP - SCD 0                                        */
/*==============================================================*/
CREATE TABLE OLAP.DIM_AGE_GROUP
(
    AgeGroupID      INT           NOT NULL,
    AgeGroupName    VARCHAR(100)  NOT NULL,
    MinAge          INT           NOT NULL,
    MaxAge          INT           NULL,

    CONSTRAINT PK_DIM_AGE_GROUP PRIMARY KEY (AgeGroupID)
);
GO

/*==============================================================*/
/* DIM_INCOME_GROUP - SCD 0                                     */
/*==============================================================*/
CREATE TABLE OLAP.DIM_INCOME_GROUP
(
    IncomeGroupID      INT             NOT NULL,
    IncomeGroupName    VARCHAR(100)    NOT NULL,
    MinIncome          DECIMAL(15,2)   NOT NULL,
    MaxIncome          DECIMAL(15,2)   NULL,

    CONSTRAINT PK_DIM_INCOME_GROUP PRIMARY KEY (IncomeGroupID)
);
GO

/*==============================================================*/
/* DIM_EDUCATION - SCD 2                                        */
/*==============================================================*/
CREATE TABLE OLAP.DIM_EDUCATION
(
    EducationID      VARCHAR(10)    NOT NULL,
    EducationName    VARCHAR(100)   NULL,
    ValidFrom        DATE           NOT NULL,
    ValidTo          DATE           NULL,
    IsLast           INT            NULL,

    CONSTRAINT PK_DIM_EDUCATION PRIMARY KEY (EducationID, ValidFrom)
);
GO

/*==============================================================*/
/* FACT_CUSTOMER_SEGMENTATION                                   */
/* Grain: Customer + Date + Education + Age Group + Income Group*/
/*==============================================================*/
CREATE TABLE OLAP.FACT_CUSTOMER_SEGMENTATION
(
    DateID                    INT             NOT NULL,
    CustomerID                INT             NOT NULL,
    EducationID               VARCHAR(10)     NOT NULL,
    EducationValidFrom        DATE            NOT NULL,
    AgeGroupID                INT             NOT NULL,
    IncomeGroupID             INT             NOT NULL,

    NumberOfLoans             INT             NULL,
    AmountOfLoans             DECIMAL(15,2)   NULL,
    NumberOfCustomers         INT             NULL,
    TotalOutstandingAmount    DECIMAL(15,2)   NULL,
    AverageOutstandingAmount  DECIMAL(15,2)   NULL,

    CONSTRAINT PK_FACT_CUSTOMER_SEGMENTATION
        PRIMARY KEY
        (
            DateID,
            CustomerID,
            EducationID,
            EducationValidFrom,
            AgeGroupID,
            IncomeGroupID
        ),

    CONSTRAINT FK_FACT_SEGMENTATION_TIME
        FOREIGN KEY (DateID)
        REFERENCES OLAP.DIM_TIME (DateID),

    CONSTRAINT FK_FACT_SEGMENTATION_CUSTOMER
        FOREIGN KEY (CustomerID)
        REFERENCES OLAP.DIM_CUSTOMER (CustomerID),

    CONSTRAINT FK_FACT_SEGMENTATION_EDUCATION
        FOREIGN KEY (EducationID, EducationValidFrom)
        REFERENCES OLAP.DIM_EDUCATION (EducationID, ValidFrom),

    CONSTRAINT FK_FACT_SEGMENTATION_AGE_GROUP
        FOREIGN KEY (AgeGroupID)
        REFERENCES OLAP.DIM_AGE_GROUP (AgeGroupID),

    CONSTRAINT FK_FACT_SEGMENTATION_INCOME_GROUP
        FOREIGN KEY (IncomeGroupID)
        REFERENCES OLAP.DIM_INCOME_GROUP (IncomeGroupID)
);
GO