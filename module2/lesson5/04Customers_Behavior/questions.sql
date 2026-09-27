/*
Which segments are high-risk?
*/

SELECT
    AG.AgeGroupName,
    E.EducationName,

    AVG(FCL.AverageDPD) AS AvgDPD,
    MAX(FCL.MaximumDPD) AS MaxDPD,
    SUM(FCS.TotalOutstandingAmount) AS TotalOutstanding

FROM OLAP.FACT_CUSTOMER_SEGMENTATION FCS
JOIN OLAP.FACT_CUSTOMER_LOANS FCL
    ON FCS.CustomerID = FCL.CustomerID
   AND FCS.DateID = FCL.DateID

JOIN OLAP.DIM_AGE_GROUP AG
    ON FCS.AgeGroupID = AG.AgeGroupID

JOIN OLAP.DIM_EDUCATION E
    ON FCS.EducationID = E.EducationID
   AND FCS.EducationValidFrom = E.ValidFrom

GROUP BY
    AG.AgeGroupName,
    E.EducationName

ORDER BY AvgDPD DESC;

/*
High-risk segments are identified by high average and maximum DPD, combined with large outstanding balances.
*/

/*2. Are high-risk customers clustered?*/

/*
YES

From previous results:

Mid-Career + Higher - high exposure + high DPD
Early Professionals - high volume + moderate risk


High-risk customers are concentrated in specific demographic groups, particularly Mid-Career individuals with higher education, indicating potential risk clustering.
*/

/*3. Which segments contribute most to portfolio-at-risk? */

SELECT
    AG.AgeGroupName,
    E.EducationName,

    SUM(FCS.TotalOutstandingAmount) AS PortfolioAtRisk

FROM OLAP.FACT_CUSTOMER_SEGMENTATION FCS
JOIN OLAP.FACT_CUSTOMER_LOANS FCL
    ON FCS.CustomerID = FCL.CustomerID
   AND FCS.DateID = FCL.DateID

JOIN OLAP.DIM_AGE_GROUP AG
    ON FCS.AgeGroupID = AG.AgeGroupID

JOIN OLAP.DIM_EDUCATION E
    ON FCS.EducationID = E.EducationID
   AND FCS.EducationValidFrom = E.ValidFrom

WHERE FCL.MaximumDPD >= 30

GROUP BY
    AG.AgeGroupName,
    E.EducationName

ORDER BY PortfolioAtRisk DESC;

/*
Answer

Same pattern:

Mid-Career + Higher dominates

Portfolio-at-risk is concentrated in a small number of segments, primarily Mid-Career customers with higher education, representing both high exposure and high delinquency.
/*



/*
By combining behavioral metrics with demographic segmentation, we identify that risk is not evenly distributed but concentrated in specific customer groups, allowing targeted risk management strategies.
*/


