-- テスト用データの作成
-- https://learn.microsoft.com/ja-jp/sql/relational-databases/security/encryption/always-encrypted-tutorial-getting-started?view=sql-server-ver16&tabs=ssms

USE [AEDB]
GO

CREATE SCHEMA [HR];
GO


CREATE TABLE [HR].[Employees]
(
    [EmployeeID] [int] IDENTITY(1,1) NOT NULL
    , [SSN] [char](11) NOT NULL
    , [FirstName] [nvarchar](50) NOT NULL
    , [LastName] [nvarchar](50) NOT NULL
    , [Salary] [money] NOT NULL
) ON [PRIMARY];
GO
INSERT INTO [HR].[Employees]
(
    [SSN]
    , [FirstName]
    , [LastName]
    , [Salary]
)
VALUES
(
    '795-73-9838'
    , N'Catherine'
    , N'Abel'
    , $31692
);

INSERT INTO [HR].[Employees]
(
    [SSN]
    , [FirstName]
    , [LastName]
    , [Salary]
)
VALUES
(
    '990-00-6818'
    , N'Kim'
    , N'Abercrombie'
    , $55415
);
GO

-- CMK / CEK の作成

USE [AEDB]
GO

CREATE COLUMN MASTER KEY [CMK-KeyVault-01]
WITH (
     KEY_STORE_PROVIDER_NAME = N'AZURE_KEY_VAULT',
     KEY_PATH = N'https://xxxxxxxxxx.vault.azure.net/keys/Always-Encrypted-xxxxxxxx'
);
GO


CREATE COLUMN MASTER KEY [CMK-KeyVault-02]
WITH (
     KEY_STORE_PROVIDER_NAME = N'AZURE_KEY_VAULT',
     KEY_PATH = N'https://xxxxxxxxxx.vault.azure.net/keys/Always-Encrypted-xxxxxxxx'
);
GO

CREATE COLUMN ENCRYPTION KEY [CEK]
WITH VALUES
(
	COLUMN_MASTER_KEY = [CMK-KeyVault-01],
	ALGORITHM = 'RSA_OAEP',
	ENCRYPTED_VALUE = 0x<Encrypted Value>
)
GO

ALTER COLUMN ENCRYPTION KEY [CEK]
ADD VALUE
(
	COLUMN_MASTER_KEY = [CMK-KeyVault-02],
	ALGORITHM = 'RSA_OAEP',
	ENCRYPTED_VALUE = 0x<Encrypted Value>
)

