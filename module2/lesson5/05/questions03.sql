/* 1. Which loans are NPL? */

SELECT *
FROM OLAP.FACT_LOAN_RISK
WHERE NPL = 1
ORDER BY TotalOutstanding DESC;

/*
Five loans are classified as non-performing, with the largest exposure concentrated in Loan 6, which represents the highest risk to the portfolio.
*/

/* 2. Distribution by DPD bucket */

SELECT
    CASE
        WHEN DPD = 0 THEN '0'
        WHEN DPD BETWEEN 1 AND 30 THEN '1-30'
        WHEN DPD BETWEEN 31 AND 60 THEN '31-60'
        WHEN DPD BETWEEN 61 AND 90 THEN '61-90'
        ELSE '90+'
    END AS DPD_Bucket,
    COUNT(*) AS Loans
FROM OLAP.FACT_LOAN_RISK
GROUP BY
    CASE
        WHEN DPD = 0 THEN '0'
        WHEN DPD BETWEEN 1 AND 30 THEN '1-30'
        WHEN DPD BETWEEN 31 AND 60 THEN '31-60'
        WHEN DPD BETWEEN 61 AND 90 THEN '61-90'
        ELSE '90+'
    END
ORDER BY DPD_Bucket;

/* 3. Average DPD per product */

SELECT
    P.ProductName,
    AVG(F.AverageDPD) AS AvgDPD
FROM OLAP.FACT_LOAN_RISK F
JOIN OLAP.DIM_LOANPRODUCT P
    ON F.ProductID = P.ProductID
   AND F.ProductValidFrom = P.ValidFrom
GROUP BY P.ProductName
ORDER BY AvgDPD DESC;

/*4. Exposure tied to high-risk loans*/
SELECT
    SUM(TotalOutstanding) AS HighRiskExposure
FROM OLAP.FACT_LOAN_RISK
WHERE NPL = 1;

/* Over 113,000 of the portfolio exposure is tied to non-performing loans, highlighting a significant concentration of financial risk. */

/* Outstanding in DPD > 30 (PAR) */

SELECT
    SUM(PAR_Amount) AS PortfolioAtRisk
FROM OLAP.FACT_LOAN_RISK;


/*The portfolio-at-risk metric shows how much of the outstanding balance is exposed to delayed payments, providing a key indicator for risk monitoring. */

/* The analysis shows that portfolio risk is highly concentrated, with a small number of loans contributing disproportionately to total exposure and delinquency. This allows targeted risk management and prioritization of high-impact cases.
*/
