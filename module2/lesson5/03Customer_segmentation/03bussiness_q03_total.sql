SELECT
    AG.AgeGroupName,
    E.EducationName,
    SUM(F.NumberOfLoans) AS NumberOfLoans,
    SUM(F.AmountOfLoans) AS AmountOfLoans,
    SUM(F.NumberOfCustomers) AS NumberOfCustomers,
    SUM(F.TotalOutstandingAmount) AS TotalOutstandingAmount,
    AVG(F.AverageOutstandingAmount) AS AverageOutstandingAmount
FROM OLAP.FACT_CUSTOMER_SEGMENTATION F
JOIN OLAP.DIM_AGE_GROUP AG
    ON F.AgeGroupID = AG.AgeGroupID
JOIN OLAP.DIM_EDUCATION E
    ON F.EducationID = E.EducationID
   AND F.EducationValidFrom = E.ValidFrom
GROUP BY
    AG.AgeGroupName,
    E.EducationName
ORDER BY
    SUM(F.AmountOfLoans) DESC;