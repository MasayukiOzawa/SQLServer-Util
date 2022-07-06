/*
参考: 
https://docs.microsoft.com/ja-jp/sql/relational-databases/track-changes/work-with-change-tracking-sql-server?view=sql-server-ver16
https://docs.microsoft.com/ja-jp/azure/data-factory/solution-template-delta-copy-with-control-table
https://docs.microsoft.com/ja-jp/azure/data-factory/tutorial-incremental-copy-change-data-capture-feature-portal
*/

-- water mark 設定テーブルの作成
DROP TABLE IF EXISTS cdc_watermark;
CREATE TABLE cdc_watermark (source_object_name varchar(255) PRIMARY KEY, from_lsn binary(10),last_row_count bigint,  last_updated_at datetime2(3), last_error varchar(500), last_errored_at datetime2(3))
GO

-- 初期データの投入
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN
	-- 初期データ投入時の最大の LSN を現在の LSN として設定
	DECLARE  @from_lsn binary(10)
	-- SET @from_lsn =  sys.fn_cdc_get_min_lsn('dbo_orders');
	SET @from_lsn =  sys.fn_cdc_get_max_lsn();

	DROP TABLE IF EXISTS orders2;
	SELECT * INTO orders2 FROM orders;
	INSERT INTO cdc_watermark VALUES('orders', @from_lsn, null, SYSDATETIME(), NULL, NULL)
COMMIT TRAN
ALTER TABLE orders2 ADD CONSTRAINT PK_orders2 PRIMARY KEY CLUSTERED (o_id ASC,o_d_id ASC,o_w_id ASC)
GO

/*
SELECT * FROM cdc_watermark
GO

SELECT 
    capture_instance,
    start_lsn,
    OBJECT_NAME(source_object_id) AS source_object_name,
    OBJECT_NAME(object_id) AS object_name
FROM 
    cdc.change_tables 
WHERE 
    source_object_id = OBJECT_ID('orders');
*/

-- SELECT * FROM cdc.dbo_orders_CT;


-- 以下、データ反映処理
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SET NOCOUNT, XACT_ABORT ON
SET LOCK_TIMEOUT 3000

DECLARE @msg_base nvarchar (50) = N'{0} : {1}'
DECLARE @msg   nvarchar(1000) = N''

WHILE(1=1)
BEGIN
	BEGIN TRAN

	BEGIN TRY
		DECLARE  @from_lsn binary(10), @to_lsn binary(10);
		IF EXISTS(SELECT 1 FROM cdc_watermark WHERE source_object_name = 'orders')
		BEGIN
			SET @from_lsn = (SELECT from_lsn FROM cdc_watermark WHERE source_object_name = 'orders')
		END
		ELSE
		BEGIN
			SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_orders');
		END
		SET  @to_lsn = sys.fn_cdc_map_time_to_lsn('largest less than or equal',SYSDATETIME())

		-- SELECT @from_lsn, @to_lsn

		-- @from_lsn = @to_lsn = 前回更新時以降にデータ更新が発生していない
		IF @from_lsn <> @to_lsn
		BEGIN
			--取得した LSN 自身は前回処理時に対象となっているため、インクリメント
			SET @from_lsn = sys.fn_cdc_increment_lsn(@from_lsn)

			/*
			SELECT __$operation, o_id,o_d_id,o_w_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d
			FROM cdc.fn_cdc_get_net_changes_dbo_orders(@from_lsn, @to_lsn, 'all')
			ORDER BY o_id
			*/

			MERGE orders2 AS target
			USING(
				SELECT __$operation, o_id,o_d_id,o_w_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d
				FROM cdc.fn_cdc_get_net_changes_dbo_orders(@from_lsn, @to_lsn, 'all') 
			) AS source
			ON 
				source.o_id = target.o_id
				AND source.o_d_id = target.o_d_id
				AND source.o_w_id = target.o_w_id
			WHEN MATCHED AND source.__$operation = '1' THEN 
				DELETE
			WHEN MATCHED AND source.__$operation = '4' THEN
				UPDATE SET 
					target.o_c_id = source.o_c_id
					,target.o_carrier_id = source.o_carrier_id
					,target.o_ol_cnt = source.o_ol_cnt
					,target.o_all_local = source.o_all_local
					,target.o_entry_d = source.o_entry_d
			WHEN NOT MATCHED THEN
				INSERT VALUES(source.o_id, source.o_d_id, source.o_w_id, source.o_c_id, source.o_carrier_id, source.o_ol_cnt, source.o_all_local, source.o_entry_d)
			;
			-- Water Mark の更新
			UPDATE cdc_watermark SET from_lsn = @to_lsn, last_row_count = @@ROWCOUNT, last_updated_at = SYSDATETIME() -- , last_error = NULL, last_errored_at = NULL
			WHERE source_object_name = 'orders'
			-- SELECT * FROM cdc_watermark
		END
		COMMIT TRAN
	END TRY

	-- エラー発生時アクティブなトランザクションが存在している場合はすべてロールバックしエラーを記録
	BEGIN CATCH
		SET @msg = REPLACE(@msg_base, '{0}',  CAST(SYSDATETIME() AS nvarchar(27)))
		SET @msg = REPLACE(@msg, '{1}',  CAST( ERROR_MESSAGE() AS nvarchar(100)))
		RAISERROR(@msg, 0,0)  WITH NOWAIT

		WHILE(1=1)
		BEGIN
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN
			END
			ELSE
			BEGIN
				BREAK
			END
		END
		UPDATE cdc_watermark SET last_error = ERROR_MESSAGE(), last_errored_at = SYSDATETIME() 
		WHERE source_object_name = 'orders'
	END CATCH

	WAITFOR DELAY '00:00:05'
END