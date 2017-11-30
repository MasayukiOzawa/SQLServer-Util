USE [TutorialDB]
GO

SELECT * FROM [WIN01.Techsummit.local].[TutorialDB].[dbo].[rental_models]

DELETE FROM rental_models WHERE model_name = 'linear_model'
GO
INSERT INTO [rental_models]
SELECT * FROM [WIN01.Techsummit.local].[TutorialDB].[dbo].[rental_models]
GO

SELECT * FROM [rental_models]