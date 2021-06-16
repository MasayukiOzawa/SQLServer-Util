
/*
DROP TABLE IF EXISTS orders2;

SELECT * INTO orders2 FROM orders;
ALTER TABLE orders2 ADD CONSTRAINT PK_orders2 PRIMARY KEY CLUSTERED (o_id ASC,o_d_id ASC,o_w_id ASC)

DROP TABLE IF EXISTS water_mark;
CREATE TABLE water_mark (source_object_name varchar(255) PRIMARY KEY, from_lsn binary(10))
*/

/*
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

DECLARE  @from_lsn binary(10), @to_lsn binary(10);
IF EXISTS(SELECT 1 FROM water_mark WHERE source_object_name = 'orders')
BEGIN
    SET @from_lsn = (SELECT from_lsn FROM water_mark WHERE source_object_name = 'orders')
END
ELSE
BEGIN
    SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_orders');
END
SET  @to_lsn = sys.fn_cdc_map_time_to_lsn('largest less than or equal',GETDATE())

-- SELECT @from_lsn, @to_lsn

-- @from_lsn = @to_lsn = 前回更新時以降にデータ更新が発生していない
IF @from_lsn <> @to_lsn
BEGIN
    --取得した LSN 自身は前回処理時に対象となっているため、インクリメント
    SET @from_lsn = sys.fn_cdc_increment_lsn(@from_lsn)

    
    SELECT __$operation, o_id,o_d_id,o_w_id,o_c_id,o_carrier_id,o_ol_cnt,o_all_local,o_entry_d
    FROM cdc.fn_cdc_get_net_changes_dbo_orders(@from_lsn, @to_lsn, 'all')
    ORDER BY o_id
    

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
    MERGE water_mark AS target
    USING(
        SELECT 'orders' AS source_object_name, @to_lsn AS to_lsn
    ) AS source
    ON source.source_object_name = target.source_object_name
    WHEN MATCHED THEN
        UPDATE SET from_lsn = source.to_lsn
    WHEN NOT MATCHED THEN
        INSERT VALUES('orders', @to_lsn)
    ;
    -- SELECT * FROM water_mark
END
WAITFOR DELAY '00:00:10'
GO 30