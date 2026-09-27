select * from OLAP.FACT_CUSTOMER_LOANS
GO;

--select * from OLAP.DIM_CUSTOMER

/*
 1.Who are my most reliable customers? * Reliable customers are borrowers who
consistently repay their loans on time, maintain low or zero delinquency, and have
predictable repayment behavior
*/
SELECT
    C.CustomerID,
    C.FirstName,
    C.LastName,
    F.NumberOfLoans,
    F.RepaymentConsistencyPct,
    F.AverageDPD,
    F.MaximumDPD,
    F.LoansWith30DPD
FROM OLAP.FACT_CUSTOMER_LOANS F
JOIN OLAP.DIM_CUSTOMER C
    ON F.CustomerID = C.CustomerID
WHERE
    F.RepaymentConsistencyPct >= 90
    AND F.MaximumDPD = 0
    AND F.LoansWith30DPD = 0
ORDER BY F.RepaymentConsistencyPct DESC;

/*
2. High-risk customers
Definition
high DPD
delayed payments
loans with 30+ DPD
*/

SELECT
    C.CustomerID,
    C.FirstName,
        C.LastName,
    F.AverageDPD,
    F.MaximumDPD,
    F.LoansWith30DPD,
    F.TotalOutstandingAmount
FROM OLAP.FACT_CUSTOMER_LOANS F
JOIN OLAP.DIM_CUSTOMER C
    ON F.CustomerID = C.CustomerID
WHERE
    F.MaximumDPD >= 90
    OR F.LoansWith30DPD > 0
ORDER BY F.MaximumDPD DESC;

/*
All identified high-risk customers have at least one loan with delay greater than 30 days, and several customers exceed 180 days, indicating severe delinquency and potential default risk.
*/

/*
3. Largest exposure
Definition

who owes the most
*/

SELECT
    C.CustomerID,
    C.FirstName,
        C.LastName,
    F.TotalOutstandingAmount
FROM OLAP.FACT_CUSTOMER_LOANS F
JOIN OLAP.DIM_CUSTOMER C
    ON F.CustomerID = C.CustomerID
ORDER BY F.TotalOutstandingAmount DESC;



/*4. Upselling candidates
Definition

good customers:

low risk
already active
paying on time
*/


SELECT
    C.CustomerID,
    C.FirstName,
    F.NumberOfLoans,
    F.RepaymentConsistencyPct,
    F.TotalOutstandingAmount
FROM OLAP.FACT_CUSTOMER_LOANS F
JOIN OLAP.DIM_CUSTOMER C
    ON F.CustomerID = C.CustomerID
WHERE
    F.RepaymentConsistencyPct >= 80
    AND F.MaximumDPD <= 5
    AND F.NumberOfLoans >= 1
ORDER BY F.RepaymentConsistencyPct DESC;

/*
Customers with strong repayment behavior and low delinquency are ideal candidates for upselling additional loan products.*/

/*
5. Behavior over time

Important
You currently have only one snapshot date

So:
You CANNOT analyze change over time yet
*/

SELECT
    DateID,
    CustomerID,
    AverageDPD,
    TotalOutstandingAmount
FROM OLAP.FACT_CUSTOMER_LOANS
ORDER BY CustomerID, DateID;

/*
Currently the model supports time-based analysis, but since only one snapshot is available, trend analysis is not yet possible. With periodic execution, changes in repayment behavior can be tracked over time.
*/