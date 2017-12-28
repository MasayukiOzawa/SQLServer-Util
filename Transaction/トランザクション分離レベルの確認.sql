SELECT
	s.session_id,
	CASE s.transaction_isolation_level 
		WHEN 0 THEN 'Unspecified' 
		WHEN 1 THEN 'ReadUncommitted' 
		WHEN 2 THEN 'ReadCommitted' 
		WHEN 3 THEN 'Repeatable' 
		WHEN 4 THEN 'Serializable' 
		WHEN 5 THEN 'Snapshot' 
	END AS Transaction_Isolation_Level ,
	s.host_name,
	s.program_name,
	s.client_interface_name,
	s.login_name,
	s.nt_domain,
	s.nt_user_name,
	s.status,
	st.enlist_count,
	st.is_user_transaction,
	st.is_local,
	st.is_enlisted,
	st.is_bound,
	st.open_transaction_count,
	CASE at.transaction_type
		WHEN 1 THEN 'Read/write'
		WHEN 2 THEN 'Read-only'
		WHEN 3 THEN 'System'
		WHEN 4 THEN 'Distributed'
	END as transaction_type,
	at.transaction_uow,
	CASE at.transaction_state		
		WHEN 0 THEN 'The transaction has not been completely initialized yet.'
		WHEN 1 THEN 'The transaction has been initialized but has not started.'
		WHEN 2 THEN 'The transaction is active.'
		WHEN 3 THEN 'The transaction has ended. This is used for read-only transactions.'
		WHEN 4 THEN 'The commit process has been initiated on the distributed transaction. This is for distributed transactions only. The distributed transaction is still active but further processing cannot take place.'
		WHEN 5 THEN 'The transaction is in a prepared state and waiting resolution.'
		WHEN 6 THEN 'The transaction has been committed.'
		WHEN 7 THEN 'The transaction is being rolled back.'
		WHEN 8 THEN 'The transaction has been rolled back.'
	END AS transaction_state,
	CASE dtc_state
		WHEN 1 THEN 'ACTIVE'
		WHEN 2 THEN 'PREPARED'
		WHEN 3 THEN 'COMMITTED'
		WHEN 4 THEN 'ABORTED'
		WHEN 5 THEN 'RECOVERED'
		ELSE CAST(dtc_state AS nvarchar(50))
	END AS dtc_state

FROM 
	sys.dm_exec_sessions s
	LEFT JOIN
	sys.dm_tran_session_transactions st
	ON
	s.session_id = st.session_id
	LEFT JOIN
	sys.dm_tran_active_transactions at
	ON
	st.transaction_id = at.transaction_id

WHERE
	st.is_user_transaction = 1
	AND
	s.session_id > 50