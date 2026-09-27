USE [data_camp];
GO



/*==============================================================*/
/* DROP VIEW IF EXISTS                                          */
/*==============================================================*/
IF OBJECT_ID('Analysis.VW_PRODUCT_COMPARISON_BASE', 'V') IS NOT NULL
    DROP VIEW Analysis.VW_PRODUCT_COMPARISON_BASE;
GO

/*==============================================================*/
/* DROP PROCEDURE IF EXISTS                                     */
/*==============================================================*/
IF OBJECT_ID('Analysis.SP_PRODUCT_COMPARISON_DYNAMIC', 'P') IS NOT NULL
    DROP PROCEDURE Analysis.SP_PRODUCT_COMPARISON_DYNAMIC;
GO

/*==============================================================*/
/* VIEW: BASE PRODUCT COMPARISON                                */
/* Normalized analytical result                                 */
/*==============================================================*/
CREATE VIEW Analysis.VW_PRODUCT_COMPARISON_BASE
AS
SELECT
    LT.LAON_TYPE_NAME AS LOAN_TYPE,
    COUNT(*) AS LOAN_COUNT
FROM DATA.CREDIT C
JOIN DATA.LOAN_TYPE LT
    ON C.LOAN_TYPE_ID = LT.LOAN_TYPE_ID
GROUP BY
    LT.LAON_TYPE_NAME;
GO

/*==============================================================*/
/* PROCEDURE: DYNAMIC PRODUCT COMPARISON PIVOT                  */
/* SQL Server 2008 compatible                                   */
/*==============================================================*/
CREATE PROCEDURE Analysis.SP_PRODUCT_COMPARISON_DYNAMIC
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @COLS NVARCHAR(MAX);
    DECLARE @SQL NVARCHAR(MAX);

    SET @COLS = '';

    SELECT
        @COLS = @COLS +
                CASE
                    WHEN @COLS = '' THEN ''
                    ELSE ','
                END +
                QUOTENAME(LAON_TYPE_NAME)
    FROM DATA.LOAN_TYPE
    ORDER BY LOAN_TYPE_ID;

    SET @SQL = '
    SELECT ' + @COLS + '
    FROM
    (
        SELECT
            LT.LAON_TYPE_NAME,
            C.CREDIT_NO
        FROM DATA.CREDIT C
        JOIN DATA.LOAN_TYPE LT
            ON C.LOAN_TYPE_ID = LT.LOAN_TYPE_ID
    ) SRC
    PIVOT
    (
        COUNT(CREDIT_NO)
        FOR LAON_TYPE_NAME IN (' + @COLS + ')
    ) PVT;';

    EXEC sp_executesql @SQL;
END
GO

/*==============================================================*/
/* TESTS                                                        */
/*==============================================================*/

-- Base analytical view
SELECT *
FROM Analysis.VW_PRODUCT_COMPARISON_BASE
ORDER BY LOAN_TYPE;
GO

-- Dynamic pivot
EXEC Analysis.SP_PRODUCT_COMPARISON_DYNAMIC;
GO