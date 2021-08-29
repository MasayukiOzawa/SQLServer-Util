SELECT 
    *, 
    COLLATIONPROPERTY(name, 'CodePage') AS CodePage,
    COLLATIONPROPERTY(name, 'LCID') AS LCID,
    COLLATIONPROPERTY(name, 'ComparisonStyle') AS ComparisonStyle,
    COLLATIONPROPERTY(name, 'Version') AS Version
FROM 
    sys.fn_helpcollations() 
WHERE 
    name like 'Japanese%'
ORDER BY
    Version
GO

SELECT 
    name, 
    collation_name,
    COLLATIONPROPERTY(collation_name, 'CodePage') AS CodePage,
    COLLATIONPROPERTY(collation_name, 'LCID') AS LCID,
    COLLATIONPROPERTY(collation_name, 'ComparisonStyle') AS ComparisonStyle,
    COLLATIONPROPERTY(collation_name, 'Version') AS Version
FROM 
    sys.databases
GO

-- UTF-16LE
-- http://download.microsoft.com/download/B/0/9/B09F266D-8D54-4476-A3EC-E974CA5F61F8/BS_303.pdf
SELECT 
    CAST(N'叱' AS varbinary(max)),
    UNICODE(N'叱'),
    FORMAT(UNICODE(N'叱'), 'x')

-- サロゲートペア
SELECT 
    CAST(N'𠮟' AS varbinary(max)),
    UNICODE(N'𠮟'),
    FORMAT(UNICODE(N'𠮟'), 'x')

    
SELECT CAST(0x42D89FDF AS nvarchar(2))
SELECT CAST(0x42D8 + 0x9FDF AS nvarchar(2))


SELECT N'🀀' COLLATE Japanese_XJIS_100_CI_AS
SELECT CAST(N'🀀' AS varbinary(max))
SELECT CAST(0x3CD800DC AS nvarchar(max))
SELECT CAST(0x3CD8 + 0x00DC AS nvarchar(max))


-- UTF-8
SELECT 
    CAST(CAST(N'𠮟' AS varchar(4)) COLLATE Japanese_XJIS_140_CI_AS_UTF8 AS varbinary(max)),
    CAST(CAST(N'𠮟' AS varchar(4)) COLLATE Japanese_XJIS_140_CI_AS AS varbinary(max))

SELECT CAST(CAST(N'🀀' AS varchar(4)) COLLATE Japanese_XJIS_140_CI_AS_UTF8 AS varbinary(max))
SELECT CAST(0xF09F8080 AS varchar(4))

-- Unicode CodePoint
SELECT UNICODE(N'🀀' COLLATE Japanese_XJIS_140_CI_AS)
SELECT FORMAT(126976,'x')
SELECT NCHAR(126976)

