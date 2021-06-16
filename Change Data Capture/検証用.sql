DELETE FROM orders 
WHERE  o_id IN(
    SELECT TOP 10 o_id FROM orders ORDER BY NEWID()
) 
WAITFOR DELAY '00:00:10'
GO 15

select * from orders2
EXCEPT
select * from orders
ORDER BY 1
/*
select  o_id,o_d_id,o_w_id,o_c_id,o_carrier_id from orders2 GROUP BY o_id,o_d_id,o_w_id,o_c_id,o_carrier_id HAVING COUNT(*) > 1
select  o_id,o_d_id,o_w_id,o_c_id,o_carrier_id from orders GROUP BY o_id,o_d_id,o_w_id,o_c_id,o_carrier_id HAVING COUNT(*) > 1



DELETE FROM orders 
WHERE  o_id IN(
    SELECT TOP 10 o_id FROM orders ORDER BY NEWID()
) 
WAITFOR DELAY '00:00:30'

*/

SELECT COUNT(*) FROM orders
SELECT COUNT(*) FROM orders2
