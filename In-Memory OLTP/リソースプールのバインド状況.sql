--リソースプールへのバインド状況
SELECT
	d.name,
	rp.name,
	rp.min_memory_percent,
	rp.max_memory_percent
FROM
	sys.databases AS d
	LEFT JOIN
	sys.resource_governor_resource_pools AS rp
	ON
	rp.pool_id =  COALESCE(d.resource_pool_id, 2)

/*
リソースプールのバインド
CREATE RESOURCE POOL Pool_IMOLTP   
WITH( 
MIN_MEMORY_PERCENT = 50,   
MAX_MEMORY_PERCENT = 50);  
GO  
  
ALTER RESOURCE POOL Pool_IMOLTP   
WITH( 
MIN_MEMORY_PERCENT = 0,   
MAX_MEMORY_PERCENT = 80);  
GO  
  
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO  

EXEC sp_xtp_bind_db_resource_pool 'SSISMoc', 'Pool_IMOLTP'  
GO  
EXEC sys.sp_xtp_unbind_db_resource_pool 'SSISMoc'  
GO

ALTER DATABASE [SSISMoc] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE [SSISMoc] SET OFFLINE
GO
ALTER DATABASE [SSISMoc] SET ONLINE
GO
ALTER DATABASE [SSISMoc] SET MULTI_USER 
GO
*/