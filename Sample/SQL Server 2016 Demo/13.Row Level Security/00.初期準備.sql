IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO

USE DemoDB
GO

IF EXISTS(SELECT * FROM sys.security_policies WHERE NAME = 'RowLevelSecurityFilter')
	DROP SECURITY POLICY rls.RowLevelSecurityFilter

IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'fn_RowLevelSecurityPredicate')
	DROP FUNCTION rls.fn_RowLevelSecurityPredicate 

IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'fn_RLSAccessPredicateScalar')
	DROP FUNCTION rls.fn_RLSAccessPredicateScalar

IF (OBJECT_ID('RowLevelSecurity', 'U')) IS NOT NULL
	DROP TABLE RowLevelSecurity

IF SCHEMA_ID('rls') IS NOT NULL
	DROP SCHEMA rls

IF OBJECT_ID('RowLevelSecurity') IS NOT NULL
	DROP TABLE RowLevelSecurity

IF USER_ID(N'ユーザーA') IS NOT NULL
	DROP USER ユーザーA

IF USER_ID(N'ユーザーB') IS NOT NULL
	DROP USER ユーザーB

IF USER_ID(N'マネージャー') IS NOT NULL
	DROP USER マネージャー
