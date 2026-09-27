USE [data_camp];
GO

IF OBJECT_ID('OLAP.FACT_LOANS', 'U') IS NOT NULL
    DROP TABLE OLAP.FACT_LOANS;
GO

IF OBJECT_ID('OLAP.DIM_TENURE_BUCKET', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_TENURE_BUCKET;
GO

IF OBJECT_ID('OLAP.DIM_LOANPRODUCT', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_LOANPRODUCT;
GO

IF OBJECT_ID('OLAP.DIM_TIME', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_TIME;
GO

CREATE TABLE OLAP.DIM_TIME
(
    DateID      INT             NOT NULL,
    DateValue   DATE            NULL,
    [Year]      INT             NULL,
    [Month]     INT             NULL,
    [Day]       INT             NULL,
    DayName     VARCHAR(15)     NULL,
    CONSTRAINT PK_DIM_TIME PRIMARY KEY (DateID)
);
GO

CREATE TABLE OLAP.DIM_LOANPRODUCT
(
    ProductID     INT            NOT NULL,
    ProductName   VARCHAR(100)   NULL,
    ValidFrom     DATE           NOT NULL,
    ValidTo       DATE           NULL,
    IsLast        INT            NULL,
    CONSTRAINT PK_DIM_LOANPRODUCT PRIMARY KEY (ProductID, ValidFrom)
);
GO

CREATE TABLE OLAP.DIM_TENURE_BUCKET
(
    TenureBucketID   INT            NOT NULL,
    BucketName       VARCHAR(50)    NOT NULL,
    MinMonths        INT            NOT NULL,
    MaxMonths        INT            NULL,
    CONSTRAINT PK_DIM_TENURE_BUCKET PRIMARY KEY (TenureBucketID)
);
GO

CREATE TABLE OLAP.FACT_LOANS
(
    DateID                    INT              NOT NULL,
    ProductID                 INT              NOT NULL,
    ValidFrom                 DATE             NOT NULL,
    TenureBucketID            INT              NOT NULL,

    NumberOfLoans             INT              NULL,
    TotalInterest             DECIMAL(15,2)    NULL,
    TotalPrinciple            DECIMAL(15,2)    NULL,
    AverageLoanSize           DECIMAL(15,2)    NULL,
    TotalCustomers            INT              NULL,
    TotalOutstandingBalance   DECIMAL(15,2)    NULL,
    TotalDisbursedAmount      DECIMAL(15,2)    NULL,

    CONSTRAINT PK_FACT_LOANS
        PRIMARY KEY (DateID, ProductID, ValidFrom, TenureBucketID),

    CONSTRAINT FK_FACT_LOANS_DIM_TIME
        FOREIGN KEY (DateID)
        REFERENCES OLAP.DIM_TIME (DateID),

    CONSTRAINT FK_FACT_LOANS_DIM_LOANPRODUCT
        FOREIGN KEY (ProductID, ValidFrom)
        REFERENCES OLAP.DIM_LOANPRODUCT (ProductID, ValidFrom),

    CONSTRAINT FK_FACT_LOANS_DIM_TENURE_BUCKET
        FOREIGN KEY (TenureBucketID)
        REFERENCES OLAP.DIM_TENURE_BUCKET (TenureBucketID)
);
GO