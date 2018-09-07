-- 現在の設定
SELECT * FROM sys.configurations WHERE name= 'max worker threads'
-- 設定により割り当てられたワーカースレッド
SELECT * FROM sys.dm_os_sys_info

-- ワーカースレッドの利用状況
SELECT * FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE'
SELECT * FROM sys.dm_os_nodes WHERE node_state_desc  <> 'ONLINE DAC'