SELECT *
FROM OLAP.FACT_LOANS
ORDER BY DateID, ProductID, TenureBucketID;

SELECT SOURCE_SYSTEM, COUNT(*)
FROM Integration.CREDIT
GROUP BY SOURCE_SYSTEM;

/* The fact table now contains integrated data from both the operational system and external sources. Each row represents a loan aggregated by product, date, and tenure bucket, enabling consistent analytical reporting across all data sources.
*/

/*
The solution implements a full data pipeline, where data from the operational system and external CSV files is first integrated in a staging layer, and then transformed into a star schema data mart used for analysis. This ensures consistent, scalable, and extensible analytical processing.
*/