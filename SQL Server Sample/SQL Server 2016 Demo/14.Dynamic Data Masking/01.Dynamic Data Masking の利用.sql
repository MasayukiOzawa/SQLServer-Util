USE DemoDB
GO

/*
CTP 2.0 の場合はトレースフラグを有効化
CTP 2.1 の場合は有効化するとエラーになる
DBCC TRACEON(209,219,-1)
GO
*/

CREATE TABLE DynamicDataMasking
  (MemberID int IDENTITY PRIMARY KEY,
   FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)') NULL,
   LastName varchar(100) NOT NULL,
   Phone# varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
   EMail varchar(100) MASKED WITH (FUNCTION = 'email()') NULL);

INSERT DynamicDataMasking (FirstName, LastName, Phone#, EMail) VALUES 
('Roberto', 'Tamburello', '555.123.4567', 'RTamburello@contoso.com'),
('Janice', 'Galvin', '555.123.4568', 'JGalvin@contoso.com.co'),
('Zheng', 'Mu', '555.123.4569', 'ZMu@contoso.net');

SELECT * FROM DynamicDataMasking;


CREATE USER TestUser WITHOUT LOGIN;
GRANT SELECT ON DynamicDataMasking TO TestUser;
GRANT SHOWPLAN TO TestUser

EXECUTE AS USER = 'TestUser';
SELECT * FROM DynamicDataMasking;
REVERT;

GRANT UNMASK TO TestUser
DENY UNMASK TO Testuser
