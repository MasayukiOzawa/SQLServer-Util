SELECT
	osi.sql_memory_model_desc,
	opm.memory_utilization_percentage,
	opm.process_physical_memory_low,
	opm.process_virtual_memory_low,
	osm.system_high_memory_signal_state,
	osm.system_low_memory_signal_state,
	osm.system_memory_state_desc,
	FORMAT(osm.total_physical_memory_kb / 1024, '#,##0') AS total_physical_memory_mb,
	FORMAT(osm.available_physical_memory_kb / 1024, '#,##0') AS available_physical_memory_mb,
	FORMAT(osi.physical_memory_kb / 1024, '#,##0') AS physical_memory_mb,
	FORMAT(osi.committed_kb / 1024, '#,##0') AS committed_mb,
	FORMAT(osi.committed_target_kb / 1024, '#,##0') AS committed_target_mb,
	FORMAT(opm.virtual_address_space_committed_kb / 1024, '#,##0') AS virtual_address_space_committed_mb,
	FORMAT(opm.physical_memory_in_use_kb / 1024, '#,##0') AS physical_memory_in_use_mb,
	FORMAT(opm.large_page_allocations_kb / 1024, '#,##0') AS large_page_allocations_mb,
	FORMAT(opm.locked_page_allocations_kb / 1024, '#,##0') AS locked_page_allocations_mb,
	FORMAT(opm.available_commit_limit_kb / 1024, '#,##0') AS available_commit_limit_mb,
	FORMAT(osm.available_page_file_kb / 1024, '#,##0') AS available_page_file_mb,
	FORMAT(osi.virtual_memory_kb / 1024, '#,##0') AS virtual_memory_mb,
	FORMAT(opm.virtual_address_space_available_kb / 1024, '#,##0') AS virtual_address_space_available_mb,
	FORMAT(osm.total_page_file_kb / 1024, '#,##0') AS total_page_file_mb,
	FORMAT(osm.available_page_file_kb / 1024, '#,##0') AS available_page_file_mb,
	FORMAT(osm.system_cache_kb / 1024, '#,##0') AS system_cache_mb,
	FORMAT(osm.system_cache_kb / 1024, '#,##0') AS system_cache_mb,
	FORMAT(osm.kernel_paged_pool_kb / 1024, '#,##0') AS kernel_paged_pool_mb,
	FORMAT(osm.kernel_nonpaged_pool_kb / 1024, '#,##0') AS kernel_nonpaged_pool_mb
FROM
	sys.dm_os_sys_info AS osi
	CROSS JOIN sys.dm_os_sys_memory AS osm
	CROSS JOIN sys.dm_os_process_memory AS opm