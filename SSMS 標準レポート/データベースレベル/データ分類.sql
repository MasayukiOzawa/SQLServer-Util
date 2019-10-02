exec sp_executesql @stmt=N'
			SELECT (SELECT
					 COUNT(*)
				   FROM sys.sensitivity_classifications)
				   AS classified_columns,

				   (SELECT
					 COUNT(COLUMN_NAME)
				   FROM INFORMATION_SCHEMA.COLUMNS
				   WHERE (TABLE_NAME IN (SELECT
					 name AS TableName
				   FROM sys.tables)
				   ))
				   AS total_columns,

				   (SELECT
					 COUNT(DISTINCT major_id)
				   FROM sys.sensitivity_classifications)
				   AS classified_tables,

				   (SELECT
					 COUNT(name) AS table_num
				   FROM sys.tables)
				   AS total_tables,

				   (SELECT
					 COUNT(DISTINCT information_type)
				   FROM sys.sensitivity_classifications)
				   AS unique_information_type
        ',@params=N''
go
exec sp_executesql @stmt=N'
          SELECT DISTINCT(label) AS sensitivity_label_name, count(label) AS num
          FROM sys.sensitivity_classifications
          WHERE label IS NOT NULL AND DATALENGTH(label) > 0
          GROUP BY label
        ',@params=N''
go
exec sp_executesql @stmt=N'
		  SELECT DISTINCT(information_type) AS information_type_name, count(information_type) AS num
          FROM sys.sensitivity_classifications
          WHERE information_type IS NOT NULL AND DATALENGTH(information_type) > 0
          GROUP BY information_type
        ',@params=N''
go
exec sp_executesql @stmt=N'
		 SELECT
			s.name AS schema_name,
			t.name AS table_name,
			c.name AS column_name,
			ISNULL(Label,'''') AS sensitivity_label_name,
			ISNULL(Information_Type,'''') AS information_type_name
		FROM
			sys.sensitivity_classifications 
			JOIN sys.tables t ON sys.sensitivity_classifications.major_id = t.object_id 
			JOIN sys.schemas s ON t.schema_id = s.schema_id
			JOIN sys.columns c ON sys.sensitivity_classifications.major_id = c.object_id 
				AND sys.sensitivity_classifications.minor_id = c.column_id
        ',@params=N''
go
