
-- テーブルのデータ
SELECT TOP 100 * FROM dbo.rental_data WHERE Year = 2015 ORDER BY Year, Month, Day
GO

-- 学習済みモデルの表示
SELECT * FROM rental_models WHERE model_name = 'linear_model'
GO

-- PREDICT 関数を使用した学習済みモデルの利用
DECLARE @model varbinary(max) = 
(SELECT native_model FROM rental_models WHERE model_name = 'linear_model');

WITH d AS (SELECT TOP 100 *
FROM dbo.rental_data WHERE Year = 2015 ORDER BY Year, Month, Day)
SELECT d.Year,  d.Month, d.Day, d.RentalCount, 
CAST(p.RentalCount_Pred AS int) as RentalCount_Pred,
d.WeekDay, d.Holiday, d.snow
FROM 
PREDICT(MODEL = @model, DATA =d AS d) 
WITH(RentalCount_Pred float) AS p
ORDER BY Year, Month, day
GO
