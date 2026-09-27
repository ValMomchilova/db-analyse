TRUNCATE TABLE Integration.RAW_CUSTOMERS;
TRUNCATE TABLE Integration.RAW_CREDITS;
TRUNCATE TABLE Integration.RAW_REPAYMENT;
GO

BULK INSERT Integration.RAW_CUSTOMERS
FROM 'C:\Valentina\doc\Data_camp\lesson6\Customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT Integration.RAW_CREDITS
FROM 'C:\Valentina\doc\Data_camp\lesson6\Credits.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

BULK INSERT Integration.RAW_REPAYMENT
FROM 'C:\Valentina\doc\Data_camp\lesson6\RepaymentSchedule.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT * FROM Integration.RAW_CUSTOMERS;
SELECT * FROM Integration.RAW_CREDITS;
SELECT * FROM Integration.RAW_REPAYMENT;