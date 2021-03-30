use cci_test

select 
	object_name(p.object_id) AS object_name,
	CAST(
		SUBSTRING(s.data_ptr,2,1) + SUBSTRING(s.data_ptr,1,1) + 
		SUBSTRING(s.data_ptr,4,1) + SUBSTRING(s.data_ptr,3,1) 
	AS int),
	CAST(
		SUBSTRING(s.data_ptr,8,1) + SUBSTRING(s.data_ptr,7,1) +
		SUBSTRING(s.data_ptr,6,1) + SUBSTRING(s.data_ptr,5,1) + 
		SUBSTRING(s.data_ptr,12,1) + SUBSTRING(s.data_ptr,11,1) +
		SUBSTRING(s.data_ptr,10,1) + SUBSTRING(s.data_ptr,9,1)
	AS INT) AS page_id,
	CAST(
		SUBSTRING(data_ptr,14,1) + SUBSTRING(data_ptr,13,1)
	AS INT) AS file_id,
	CAST(
		SUBSTRING(data_ptr,16,1) + SUBSTRING(data_ptr,15,1)
	AS INT) AS slot_id,
	s.hobt_id,
	s.column_id - 1 AS column_id,
	s.segment_id,
	s.version,
	s.encoding_type,
	s.row_count,
	s.status,
	s.base_id,
	s.magnitude,
	s.primary_dictionary_id,
	s.secondary_dictionary_id,
	s.min_data_id,
	s.max_data_id,
	s.null_value,
	s.on_disk_size,
	s.data_ptr,
	s.container_id,
	s.bloom_filter_md,
	s.bloom_filter_data_ptr,
	plc.*
from 
	sys.syscscolsegments AS s
	outer apply sys.fn_PhysLocCracker(%%physloc%%) AS plc
	inner join sys.partitions as p on p.hobt_id = s.hobt_id
GO

select 
	object_name(p.object_id) AS object_name,
	CAST(
		SUBSTRING(d.data_ptr,2,1) + SUBSTRING(d.data_ptr,1,1) + 
		SUBSTRING(d.data_ptr,4,1) + SUBSTRING(d.data_ptr,3,1) 
	AS int),
	CAST(
		SUBSTRING(d.data_ptr,8,1) + SUBSTRING(d.data_ptr,7,1) +
		SUBSTRING(d.data_ptr,6,1) + SUBSTRING(d.data_ptr,5,1) + 
		SUBSTRING(d.data_ptr,12,1) + SUBSTRING(d.data_ptr,11,1) +
		SUBSTRING(d.data_ptr,10,1) + SUBSTRING(d.data_ptr,9,1)
	AS INT) AS page_id,
	CAST(
		SUBSTRING(d.data_ptr,14,1) + SUBSTRING(d.data_ptr,13,1)
	AS INT) AS file_id,
	CAST(
		SUBSTRING(d.data_ptr,16,1) + SUBSTRING(d.data_ptr,15,1)
	AS INT) AS slot_id,
	d.hobt_id,
	d.column_id -1 as column_id,
	d.dictionary_id,
	d.version,
	d.type,
	d.flags,
	d.last_id,
	d.entry_count,
	d.on_disk_size,
	d.data_ptr,
	d.container_id,
	plc.*
from 
	sys.syscsdictionaries AS d
	outer apply sys.fn_PhysLocCracker(%%physloc%%) AS plc
	inner join sys.partitions as p on p.hobt_id = d.hobt_id
GO
