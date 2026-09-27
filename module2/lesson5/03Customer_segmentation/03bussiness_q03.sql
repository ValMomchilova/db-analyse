/*
1
Which age groups or education levels hold the most loans?
*/


SELECT
    AG.AgeGroupName,
    E.EducationName,
    SUM(F.NumberOfLoans) AS NumberOfLoans
FROM OLAP.FACT_CUSTOMER_SEGMENTATION F
JOIN OLAP.DIM_AGE_GROUP AG
    ON F.AgeGroupID = AG.AgeGroupID
JOIN OLAP.DIM_EDUCATION E
    ON F.EducationID = E.EducationID
   AND F.EducationValidFrom = E.ValidFrom
GROUP BY
    AG.AgeGroupName,
    E.EducationName
ORDER BY NumberOfLoans DESC;

/*
The largest number of loans is concentrated among Early Professionals with Higher education, indicating this segment is the most active borrower group.
*/

/*2 Which segments contribute the most to total loan exposure?*/

SELECT
    AG.AgeGroupName,
    E.EducationName,
    SUM(F.AmountOfLoans) AS TotalExposure
FROM OLAP.FACT_CUSTOMER_SEGMENTATION F
JOIN OLAP.DIM_AGE_GROUP AG
    ON F.AgeGroupID = AG.AgeGroupID
JOIN OLAP.DIM_EDUCATION E
    ON F.EducationID = E.EducationID
   AND F.EducationValidFrom = E.ValidFrom
GROUP BY
    AG.AgeGroupName,
    E.EducationName
ORDER BY TotalExposure DESC;

/*Mid-Career Adults with Higher education

66,240 - highest exposure
The highest exposure is concentrated among Mid-Career Adults with Higher education, which indicates that this segment carries the largest financial weight in the portfolio.
*/

/* 3. Are certain demographics overrepresented in high outstanding balances? */

SELECT
    AG.AgeGroupName,
    E.EducationName,
    SUM(F.TotalOutstandingAmount) AS TotalOutstanding
FROM OLAP.FACT_CUSTOMER_SEGMENTATION F
JOIN OLAP.DIM_AGE_GROUP AG
    ON F.AgeGroupID = AG.AgeGroupID
JOIN OLAP.DIM_EDUCATION E
    ON F.EducationID = E.EducationID
   AND F.EducationValidFrom = E.ValidFrom
GROUP BY
    AG.AgeGroupName,
    E.EducationName
ORDER BY TotalOutstanding DESC;

/*
Mid-Career Adults with Higher education are overrepresented in outstanding balances, indicating that this segment is both highly exposed and carries higher repayment risk.
*/

/* 4. How does average loan size vary by age or education? */
SELECT
    AG.AgeGroupName,
    E.EducationName,
    AVG(F.AmountOfLoans) AS AvgLoanSize
FROM OLAP.FACT_CUSTOMER_SEGMENTATION F
JOIN OLAP.DIM_AGE_GROUP AG
    ON F.AgeGroupID = AG.AgeGroupID
JOIN OLAP.DIM_EDUCATION E
    ON F.EducationID = E.EducationID
   AND F.EducationValidFrom = E.ValidFrom
GROUP BY
    AG.AgeGroupName,
    E.EducationName
ORDER BY AvgLoanSize DESC;

/*
Average loan size increases with age and education level, with Mid-Career Adults holding the largest loans, while younger segments tend to have smaller loan sizes.
*/

/*
Final demo summary 

The segmentation analysis shows that Early Professionals are the most active borrowers, while Mid-Career customers with higher education hold the largest exposure and outstanding balances. This indicates a concentration of both opportunity and risk within this segment.
*/



