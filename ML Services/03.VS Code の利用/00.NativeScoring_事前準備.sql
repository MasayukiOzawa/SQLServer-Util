USE TutorialDB;
GO
DROP TABLE IF EXISTS rental_models;
GO
CREATE TABLE rental_models (
                model_name VARCHAR(30) NOT NULL DEFAULT('default model'),
                lang VARCHAR(30),
				model VARBINARY(MAX),
				native_model VARBINARY(MAX),
				PRIMARY KEY (model_name, lang)
);
GO

DECLARE @model varbinary(max) = 
(SELECT * FROM 
OPENROWSET(BULK N'c:\temp\trained_model.pickle', SINGLE_BLOB) AS t);

WITH d AS (SELECT * FROM dbo.rental_data WHERE Year = 2013)

SELECT d.*, p.* 
FROM 
PREDICT(MODEL = @model, DATA =d AS d) 
WITH(RentalCount_Pred float) AS p;
GO
