UPDATE DATA.CREDIT
SET STATUS_CODE = 'R'
WHERE CREDIT_NO = 7;
GO


USE [data_camp];
GO

DECLARE @EMP_ID INT;
DECLARE @CR_TEST_13 NUMERIC(18,0);
DECLARE @CR_TEST_14 NUMERIC(18,0);

-- use an existing employee
SELECT @EMP_ID = MIN(EMPLOYEE_ID)
FROM DATA.EMPLOYEE;

------------------------------------------------------------
-- Reset credit 7 for retest
------------------------------------------------------------
UPDATE DATA.CREDIT
SET STATUS_CODE = 'R'
WHERE CREDIT_NO = 7;

------------------------------------------------------------
-- CREDIT FOR CLIENT 13 (INVALID EGN)
------------------------------------------------------------
INSERT INTO DATA.CREDIT
(
    CLIENT_ID,
    LOAN_TYPE_ID,
    CREDIT_SIGNED,
    CREDIT_BEGIN_DATE,
    CREDIT_END_DATE,
    CREDIT_SUM,
    CREDIT_INTEREST_PRC,
    CREDIT_ALLSUM,
    CREDIT_GPR,
    STATUS_CODE,
    CREDIT_FIRST_MATURITY,
    CREDIT_ISNTALLMENTS_CNT,
    CREDIT_INSTALLMENT,
    EMPLOYEE_ID
)
VALUES
(
    13,
    20,
    'N',
    '2026-04-01',
    '2026-07-01',
    3000.00,
    7.00,
    3150.00,
    7.50,
    'R',
    DATEADD(DAY, 30, '2026-04-01'),
    3,
    1050.00,
    @EMP_ID
);

SET @CR_TEST_13 = SCOPE_IDENTITY();

INSERT INTO DATA.REPAYMENT_SCHEDULE
(
    CREDIT_NO,
    INSTALLMENT_NO,
    INSTALLMENT_DATE,
    INSTALLMENT_SUM,
    INSTALLMENT_PRINCIPLE,
    INSTALLMENT_INTEREST,
    INSTALLMENT_RESTSUM
)
VALUES
(@CR_TEST_13, 1, '2026-05-01', 1050.00, 1000.00, 50.00, 2000.00),
(@CR_TEST_13, 2, '2026-06-01', 1050.00, 1000.00, 50.00, 1000.00),
(@CR_TEST_13, 3, '2026-07-01', 1050.00, 1000.00, 50.00,    0.00);

------------------------------------------------------------
-- CREDIT FOR CLIENT 14 (INVALID EGN)
------------------------------------------------------------
INSERT INTO DATA.CREDIT
(
    CLIENT_ID,
    LOAN_TYPE_ID,
    CREDIT_SIGNED,
    CREDIT_BEGIN_DATE,
    CREDIT_END_DATE,
    CREDIT_SUM,
    CREDIT_INTEREST_PRC,
    CREDIT_ALLSUM,
    CREDIT_GPR,
    STATUS_CODE,
    CREDIT_FIRST_MATURITY,
    CREDIT_ISNTALLMENTS_CNT,
    CREDIT_INSTALLMENT,
    EMPLOYEE_ID
)
VALUES
(
    14,
    20,
    'N',
    '2026-04-10',
    '2026-07-10',
    3600.00,
    6.50,
    3780.00,
    7.10,
    'R',
    DATEADD(DAY, 30, '2026-04-10'),
    3,
    1260.00,
    @EMP_ID
);

SET @CR_TEST_14 = SCOPE_IDENTITY();

INSERT INTO DATA.REPAYMENT_SCHEDULE
(
    CREDIT_NO,
    INSTALLMENT_NO,
    INSTALLMENT_DATE,
    INSTALLMENT_SUM,
    INSTALLMENT_PRINCIPLE,
    INSTALLMENT_INTEREST,
    INSTALLMENT_RESTSUM
)
VALUES
(@CR_TEST_14, 1, '2026-05-10', 1260.00, 1200.00, 60.00, 2400.00),
(@CR_TEST_14, 2, '2026-06-10', 1260.00, 1200.00, 60.00, 1200.00),
(@CR_TEST_14, 3, '2026-07-10', 1260.00, 1200.00, 60.00,    0.00);

UPDATE DATA.CREDIT
SET STATUS_CODE = 'R'
WHERE CREDIT_NO IN (1,2,3,4,5,6,7,8,9,10,11,12,15,16);

------------------------------------------------------------
-- Run only the first workflow step
------------------------------------------------------------
--EXEC DATA.SP_WF_REGISTERED_TO_VERIFIED_OR_INSPECTION;

------------------------------------------------------------
-- Check result
------------------------------------------------------------
SELECT
    CREDIT_NO,
    CLIENT_ID,
    STATUS_CODE
FROM DATA.CREDIT
WHERE CREDIT_NO = 7
   OR CLIENT_ID IN (13, 14)
ORDER BY CREDIT_NO;