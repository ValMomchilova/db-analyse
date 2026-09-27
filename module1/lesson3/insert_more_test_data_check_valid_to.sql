
/*==============================================================*/
/* 1. CLIENT 58+ VALID (NULL VALIDTO)                    */
/*==============================================================*/
INSERT INTO DATA.CLIENT
(
    CLIENT_NAME, CLIENT_SURNAME, CLIENT_LASTNAME, CLIENT_EGN, CLIENT_GENDER,
    CLIENT_BIRTHDATE, CLIENT_IDCARD_NO, CLIENT_IDCARD_ISSUED, CLIENT_IDCARD_VALIDTO,
    CLIENT_IDCARD_ISSUER, EDU_CODE, CLIENT_INCOME, MSTATUS_CODE
)
VALUES
('Иван', 'Стефанов', 'Димитров', '6501011111', 'M',
 '1965-01-01', '9001123456', '2024-01-15', NULL,
 'МВР Варна', 'S', 2500.00, 'M');

 GO

/*==============================================================*/
/* 2. CLIENT INVALID CASE (should be 10 years, but isn't)  */
/*==============================================================*/
INSERT INTO DATA.CLIENT
(
    CLIENT_NAME, CLIENT_SURNAME, CLIENT_LASTNAME, CLIENT_EGN, CLIENT_GENDER,
    CLIENT_BIRTHDATE, CLIENT_IDCARD_NO, CLIENT_IDCARD_ISSUED, CLIENT_IDCARD_VALIDTO,
    CLIENT_IDCARD_ISSUER, EDU_CODE, CLIENT_INCOME, MSTATUS_CODE
)
VALUES
('Петя', 'Иванова', 'Георгиева', '9005052222', 'F',
 '1990-05-05', '9102234567', '2022-03-10', '2027-03-10', --  should be 2032
 'МВР Варна', 'H', 2800.00, 'S');

GO

/*==============================================================*/
/* 7. TEST QUERY                                                */
/*==============================================================*/
SELECT *
FROM DATA.VW_CLIENT_IDCARD_VALIDITY_REPORT
ORDER BY INTERNAL_CLIENT_ID;
GO