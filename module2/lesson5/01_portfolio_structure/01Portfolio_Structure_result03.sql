-- qiuck check

SELECT *
FROM OLAP.FACT_LOANS
ORDER BY DateID, ProductID, TenureBucketID;

-- check
SELECT
    T.DateValue,
    P.ProductName,
    B.BucketName,
    F.NumberOfLoans,
    F.TotalInterest,
    F.TotalPrinciple,
    F.AverageLoanSize,
    F.TotalCustomers,
    F.TotalOutstandingBalance,
    F.TotalDisbursedAmount
FROM OLAP.FACT_LOANS F
JOIN OLAP.DIM_TIME T
    ON F.DateID = T.DateID
JOIN OLAP.DIM_LOANPRODUCT P
    ON F.ProductID = P.ProductID
   AND F.ValidFrom = P.ValidFrom
JOIN OLAP.DIM_TENURE_BUCKET B
    ON F.TenureBucketID = B.TenureBucketID
ORDER BY T.DateValue, P.ProductName, B.TenureBucketID;


-- business question answer
SELECT
    P.ProductName,
    B.BucketName,
    SUM(F.NumberOfLoans) AS NumberOfLoans,
    SUM(F.TotalPrinciple) AS TotalPrinciple,
    SUM(F.TotalInterest) AS TotalInterest,
    SUM(F.TotalOutstandingBalance) AS TotalOutstandingBalance,
    SUM(F.TotalDisbursedAmount) AS TotalDisbursedAmount
FROM OLAP.FACT_LOANS F
JOIN OLAP.DIM_LOANPRODUCT P
    ON F.ProductID = P.ProductID
   AND F.ValidFrom = P.ValidFrom
JOIN OLAP.DIM_TENURE_BUCKET B
    ON F.TenureBucketID = B.TenureBucketID
GROUP BY
    P.ProductName,
    B.BucketName
ORDER BY
    SUM(F.TotalPrinciple) DESC;

    /* 
    Total loan amounts include all scheduled installments, while outstanding balance is calculated only for matured unpaid installments. Therefore, the sum of disbursed and outstanding amounts may not equal the total loan amount.
    */