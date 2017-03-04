-- JSON の妥当性の判断
DECLARE @json1 nvarchar(max) = N'{
    "info":{  
      "type":1,
      "address":{  
        "town":"Bristol",
        "county":"Avon",
        "country":"England"
      },
      "tags":["Sport", "Water polo"]
   },
   "type":"Basic"
}',
@json2 nvarchar(max) = N'{
aaaaa
}'
SELECT ISJSON(@json1), ISJSON(@json2)
GO

-- JSON から特定の値を取得 (単一値)
DECLARE @json1 nvarchar(max) = N'{
    "info":{  
      "type":1,
      "address":{  
        "town":"Bristol",
        "county":"Avon",
        "country":"England"
      },
      "tags":["Sport", "Water polo"]
   },
   "type":"Basic"
}
'

SELECT 
JSON_VALUE(@json1, '$.info.tags'),
JSON_VALUE(@json1, '$.info.tags[1]')
GO



-- JSON から特定の値を取得 (複数値)
DECLARE @json1 nvarchar(max) = N'{
    "info":{  
      "type":1,
      "address":{  
        "town":"Bristol",
        "county":"Avon",
        "country":"England"
      },
      "tags":["Sport", "Water polo"]
   },
   "type":"Basic"
}
'

SELECT 
JSON_QUERY(@json1, '$.info.tags'),
JSON_QUERY(@json1, '$.info.tags[1]')
GO
