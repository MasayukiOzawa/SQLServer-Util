CREATE TABLE DirectWrite(
    C1 int identity NOT NULL, 
    C2 nvarchar(36) DEFAULT NEWID(), 
    C3 varchar(100),
    CONSTRAINT  PK_DIrectWrite PRIMARY KEY CLUSTERED(C1)
)
GO

INSERT INTO DirectWrite(C3) VALUES('08GB=1‚©‚¸‚ ‚«')
GO
