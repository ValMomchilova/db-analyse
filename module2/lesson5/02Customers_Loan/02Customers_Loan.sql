/*
Unlike Task 1, which is a product-level portfolio mart, Task 2 is a customer-level periodic snapshot mart. Each row represents one customer at one reporting date and stores behavioral and exposure metrics.
*/

/*
The DateID is a foreign key to the Time dimension. Its business meaning depends on the fact table grain — in Task 1 it represents loan origination date, while in Task 2 it represents the reporting snapshot date.
*/

USE [data_camp];
GO

/*==============================================================*/
/* DROP FACT FIRST                                              */
/*==============================================================*/
IF OBJECT_ID('OLAP.FACT_CUSTOMER_LOANS', 'U') IS NOT NULL
    DROP TABLE OLAP.FACT_CUSTOMER_LOANS;
GO

/*==============================================================*/
/* DROP DIMENSION                                               */
/*==============================================================*/
IF OBJECT_ID('OLAP.DIM_CUSTOMER', 'U') IS NOT NULL
    DROP TABLE OLAP.DIM_CUSTOMER;
GO

/*==============================================================*/
/* DIM_CUSTOMER                                                 */
/* Simple dimension (SCD0 / SCD1 for now)                       */
/*==============================================================*/
CREATE TABLE OLAP.DIM_CUSTOMER
(
    CustomerID     INT            NOT NULL,
    FirstName      VARCHAR(100)   NULL,
    LastName       VARCHAR(100)   NULL,
    Gender         CHAR(1)        NULL,
    BirthDate      DATE           NULL,

    CONSTRAINT PK_DIM_CUSTOMER PRIMARY KEY (CustomerID)
);
GO

/*==============================================================*/
/* FACT_CUSTOMER_LOANS                                          */
/* Grain: Customer + Date (snapshot)                            */
/*==============================================================*/
CREATE TABLE OLAP.FACT_CUSTOMER_LOANS
(
    DateID                     INT             NOT NULL,
    CustomerID                 INT             NOT NULL,

    NumberOfLoans              INT             NULL,
    AmountOfLoans              DECIMAL(15,2)   NULL,
    TotalOutstandingAmount     DECIMAL(15,2)   NULL,
    RepaymentConsistencyPct    DECIMAL(10,4)   NULL,
    AverageDPD                 DECIMAL(10,2)   NULL,
    MaximumDPD                 INT             NULL,
    LoansWith30DPD             INT             NULL,

    CONSTRAINT PK_FACT_CUSTOMER_LOANS
        PRIMARY KEY (DateID, CustomerID),

    CONSTRAINT FK_FACT_CUSTOMER_TIME
        FOREIGN KEY (DateID)
        REFERENCES OLAP.DIM_TIME (DateID),

    CONSTRAINT FK_FACT_CUSTOMER_CUSTOMER
        FOREIGN KEY (CustomerID)
        REFERENCES OLAP.DIM_CUSTOMER (CustomerID)
);
GO