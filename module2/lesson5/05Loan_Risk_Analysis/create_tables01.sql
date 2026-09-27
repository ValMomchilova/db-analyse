USE [data_camp];
GO

IF OBJECT_ID('OLAP.FACT_LOAN_RISK', 'U') IS NOT NULL
    DROP TABLE OLAP.FACT_LOAN_RISK;
GO

CREATE TABLE OLAP.FACT_LOAN_RISK
(
    DateID                INT NOT NULL,
    LoanID                INT NOT NULL,
    ProductID             INT NOT NULL,
    ProductValidFrom      DATE NOT NULL,

    DPD                   INT NULL,
    MaximumDPD            INT NULL,
    AverageDPD            DECIMAL(10,2) NULL,
    TotalOutstanding      DECIMAL(15,2) NULL,
    NPL                   INT NULL,
    AtRisk                INT NULL,
    PAR_Amount            DECIMAL(15,2) NULL,

    CONSTRAINT PK_FACT_LOAN_RISK
        PRIMARY KEY (DateID, LoanID),

    FOREIGN KEY (DateID) REFERENCES OLAP.DIM_TIME(DateID),
    FOREIGN KEY (ProductID, ProductValidFrom)
        REFERENCES OLAP.DIM_LOANPRODUCT(ProductID, ValidFrom)
);
GO