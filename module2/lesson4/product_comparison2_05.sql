CREATE OR ALTER PROCEDURE Analysis.SP_PRODUCT_COMPARISON_BY_YEAR
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @COLS NVARCHAR(MAX);
    DECLARE @SQL NVARCHAR(MAX);

    -- use correct column name
    SELECT @COLS = STRING_AGG(QUOTENAME(LAON_TYPE_NAME), ',')
    FROM DATA.LOAN_TYPE;

    SET @SQL = '
    SELECT 
        CONTRACT_YEAR,
        ' + @COLS + '
    FROM
    (
        SELECT
            YEAR(C.CREDIT_BEGIN_DATE) AS CONTRACT_YEAR,
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
    ) PVT
    ORDER BY CONTRACT_YEAR;
    ';

    EXEC sp_executesql @SQL;
END;
GO

/*==============================================================*/
/* TESTS                                                        */
/*==============================================================*/


-- Dynamic pivot
EXEC Analysis.SP_PRODUCT_COMPARISON_BY_YEAR;
GO