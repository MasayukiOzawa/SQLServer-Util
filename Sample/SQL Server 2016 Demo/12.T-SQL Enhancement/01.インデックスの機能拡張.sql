USE DemoDB
GO

IF OBJECT_ID('TSQLTEST','U') IS NOT NULL
	DROP TABLE TSQLTEST

CREATE TABLE TSQLTEST(
	Col1 char(900),
	Col2 char(800),
	INDEX NCIX NONCLUSTERED(Col1, Col2)
)

IF OBJECT_ID('TSQLTEST','U') IS NOT NULL
	DROP TABLE TSQLTEST

CREATE TABLE TSQLTEST(
	c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int, c9 int,
	c10 int,c11 int, c12 int, c13 int, c14 int, c15 int, c16 int, c17 int, c18 int, c19 int,
	c20 int,c21 int, c22 int, c23 int, c24 int, c25 int, c26 int, c27 int, c28 int, c29 int,
	c30 int,c31 int, c32 int,
	INDEX NCIX NONCLUSTERED(
	c1, c2, c3, c4, c5, c6, c7, c8, c9,
	c10, c11, c12, c13, c14, c15, c16, c17, c18, c19,
	c20, c21, c22, c23, c24, c25, c26, c27, c28, c29,
	c30, c31, c32)
)
