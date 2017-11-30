USE MLDB
GO

SELECT * FROM rental_models
GO

-- テーブルから学習済みモデルを取得
DECLARE @model varbinary(max) = 
(SELECT native_model FROM rental_models WHERE model_name = 'linear_model');

-- PREDICT 関数を使用した学習済みモデルの利用
WITH d AS (SELECT TOP 100 * FROM dbo.rental_data WHERE Year = 2015 ORDER BY Year, Month, Day)
SELECT d.Year,  d.Month, d.Day, d.WeekDay, d.Holiday, d.snow, d.RentalCount, 
CAST(p.RentalCount_Pred AS int) as RentalCount_Pred
FROM 
PREDICT(MODEL = @model, DATA =d AS d) 
WITH(RentalCount_Pred float) AS p
ORDER BY Year, Month, day
GO
