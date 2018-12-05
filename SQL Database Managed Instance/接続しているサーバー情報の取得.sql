-- 接続しているサーバーの IP / ポート番号の取得 (Local TCP Port が取得できているノードの接続している)
SELECT 
	fn.node_name,  
	c.local_tcp_port,
	fn.ip_address_or_FQDN, fn.code_version, upgrade_domain, fault_domain
FROM 
	sys.dm_hadr_fabric_nodes AS fn
LEFT JOIN
	sys.dm_exec_connections AS c
	ON
	fn.ip_address_or_FQDN = c.local_net_address
	AND
	c.session_id = @@SPID