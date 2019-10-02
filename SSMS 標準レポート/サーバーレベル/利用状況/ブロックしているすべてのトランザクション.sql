exec sp_executesql @stmt=N'begin try
declare @tab_tran_locks as table(
        l_resource_type nvarchar(60) collate database_default 
,       l_resource_subtype nvarchar(60) collate database_default 
,       l_resource_associated_entity_id bigint
,       l_blocking_request_spid int
,       l_blocked_request_spid int
,       l_blocking_request_mode nvarchar(60) collate database_default 
,       l_blocked_request_mode nvarchar(60) collate database_default
,       l_blocking_tran_id bigint
,       l_blocked_tran_id bigint   
);
declare @tab_blocked_tran as table (
        tran_id bigint
,       no_blocked bigint
);
declare @temp_tab table(
        blocking_status int
,       no_blocked int
,       l_resource_type nvarchar(60) collate database_default 
,       l_resource_subtype nvarchar(60) collate database_default 
,       l_resource_associated_entity_id bigint
,       l_blocking_request_spid int
,       l_blocked_request_spid int
,       l_blocking_request_mode nvarchar(60) collate database_default 
,       l_blocked_request_mode nvarchar(60) collate database_default 
,       l_blocking_tran_id int
,       l_blocked_tran_id int   
,       local1 int
,       local2 int
,       b_tran_id bigint
,       w_tran_id bigint
,       b_name nvarchar(128) collate database_default 
,       w_name nvarchar(128) collate database_default 
,       b_tran_begin_time datetime
,       w_tran_begin_time datetime
,       b_state nvarchar(60) collate database_default 
,       w_state nvarchar(60) collate database_default 
,       b_trans_type nvarchar(60) collate database_default 
,       w_trans_type nvarchar(60) collate database_default 
,       b_text nvarchar(max) collate database_default 
,       w_text nvarchar(max) collate database_default 
,       db_span_count1 int
,       db_span_count2 int 
);

insert into @tab_tran_locks 
select  a.resource_type
,               a.resource_subtype
,               a.resource_associated_entity_id
,               a.request_session_id as blocking 
,               b.request_session_id as blocked
,               a.request_mode
,               b.request_mode 
,               a.request_owner_id
,               b.request_owner_id  
from sys.dm_tran_locks a 
join sys.dm_tran_locks b on (a.resource_type = b.resource_type and a.resource_subtype = b.resource_subtype and a.resource_associated_entity_id = b.resource_associated_entity_id and a.resource_description = b.resource_description)
where a.request_status = ''GRANT'' and (b.request_status = ''WAIT'' or b.request_status = ''CONVERT'') and a.request_owner_type = ''TRANSACTION'' and b.request_owner_type = ''TRANSACTION''

insert into @tab_blocked_tran 
select  ttl.l_blocking_tran_id
,       count(distinct ttl.l_blocked_tran_id)
from @tab_tran_locks ttl   
group by ttl.l_blocking_tran_id
order by count( distinct ttl.l_blocked_tran_id) desc 

insert into @temp_tab 
select  0 as blocking_status
,       tbt.no_blocked
,       ttl.*
,       st1.is_local as local1
,       st2.is_local as local2
,       st1.transaction_id as b_tran_id
,       ttl.l_blocked_tran_id as w_tran_id
,       at1.name as b_name,at2.name as w_name
,       at1.transaction_begin_time as b_tran_begin_time
,       at2.transaction_begin_time as w_tran_begin_time
,       case when at1.transaction_type <> 4 
                then case at1.transaction_state 
                        when 0 then ''Invalid'' 
                        when 1 then ''Initialized'' 
                        when 2 then ''Active'' 
                        when 3 then ''Ended'' 
                        when 4 then ''Commit Started'' 
                        when 5 then ''Prepared'' 
                        when 6 then ''Committed'' 
                        when 7 then ''Rolling Back'' 
                        when 8 then ''Rolled Back'' 
                end 
                else case at1.dtc_state 
                        when 1 then ''Active'' 
                        when 2 then ''Prepared'' 
                        when 3 then ''Committed'' 
                        when 4 then ''Aborted'' 
                        when 5 then ''Recovered'' 
        end end b_state
,       case when at2.transaction_type <> 4 
                then case at2.transaction_state 
                        when 0 then ''Invalid'' 
                        when 1 then ''Initialized'' 
                        when 2 then ''Active'' 
                        when 3 then ''Ended'' 
                        when 4 then ''Commit Started'' 
                        when 5 then ''Prepared'' 
                        when 6 then ''Committed'' 
                        when 7 then ''Rolling Back'' 
                        when 8 then ''Rolled Back'' 
                end 
                else case at2.dtc_state 
                        when 1 then ''Active'' 
                        when 2 then ''Prepared'' 
                        when 3 then ''Committed'' 
                        when 4 then ''Aborted'' 
                        when 5 then ''Recovered'' 
                end 
        end w_state
,       at1.transaction_type as b_trans_type
,               at2.transaction_type  as w_trans_type
,       case when r1.sql_handle IS NULL then ''--'' else ( select top 1 substring(text,(r1.statement_start_offset+2)/2, (case when r1.statement_end_offset = -1   then (len(convert(nvarchar(MAX),text))*2) else r1.statement_end_offset  end - r1.statement_start_offset) /2  ) from sys.dm_exec_sql_text(r1.sql_handle)) end as b_text
,       case when r2.sql_handle IS NULL then ''--'' else ( select top 1 substring(text,(r2.statement_start_offset+2)/2, (case when r2.statement_end_offset =-1 then len(convert(nvarchar(MAX),text))*2  when r2.statement_end_offset =0  then len(convert(nvarchar(MAX),text))*2  else r2.statement_end_offset  end - r2.statement_start_offset) /2  ) from sys.dm_exec_sql_text(r2.sql_handle)) end as w_text 
,       ( Select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st1.transaction_id ) as db_span_count1
,       ( Select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st2.transaction_id ) as db_span_count2  
from @tab_tran_locks ttl 
inner join sys.dm_tran_active_transactions at1 on(at1.transaction_id = ttl.l_blocking_tran_id) 
inner join @tab_blocked_tran tbt on(tbt.tran_id = at1.transaction_id)  
inner join sys.dm_tran_session_transactions st1 on(at1.transaction_id = st1.transaction_id) 
left outer join sys.dm_exec_requests r1 on(at1.transaction_id = r1.transaction_id ) 
inner join sys.dm_tran_active_transactions at2 on(at2.transaction_id = ttl.l_blocked_tran_id) 
left outer join sys.dm_tran_session_transactions st2  on(at2.transaction_id = st2.transaction_id)  
left outer join  sys.dm_exec_requests r2 on(at2.transaction_id = r2.transaction_id ) 
where st1.is_user_transaction = 1
order by tbt.no_blocked desc;

with Blocking(
        blocking_status
,       no_blocked
,       total_blocked
,       l_resource_type
,       l_resource_subtype
,       l_resource_associated_entity_id
,       l_blocking_request_spid
,       l_blocked_request_spid
,       l_blocking_request_mode
,       l_blocked_request_mode
,       local1
,       local2
,       b_tran_id
,       w_tran_id
,       b_name
,       w_name
,       b_tran_begin_time
,       w_tran_begin_time
,       b_state
,       w_state
,       b_trans_type
,       w_trans_type
,       b_text
,       w_text
,       db_span_count1
,       db_span_count2
,       lvl
)
as( select blocking_status
        ,       no_blocked
        ,       no_blocked
        ,       l_resource_type
        ,       l_resource_subtype
        ,       l_resource_associated_entity_id
        ,       l_blocking_request_spid
        ,       l_blocked_request_spid
        ,       l_blocking_request_mode
        ,       l_blocked_request_mode
        ,       local1
        ,       local2
        ,       b_tran_id
        ,       w_tran_id
        ,       b_name
        ,       w_name
        ,       b_tran_begin_time
        ,       w_tran_begin_time
        ,       b_state
        ,       w_state
        ,       b_trans_type
        ,       w_trans_type
        ,       b_text
        ,       w_text
        ,       db_span_count1
        ,       db_span_count2
        ,       0
        from @temp_tab
   union all
        select E.blocking_status
        ,       M.no_blocked
        ,       convert(int,E.no_blocked + total_blocked)
        ,       E.l_resource_type
        ,       E.l_resource_subtype
        ,       E.l_resource_associated_entity_id
        ,       M.l_blocking_request_spid
        ,       E.l_blocked_request_spid
        ,       M.l_blocking_request_mode
        ,       E.l_blocked_request_mode
        ,       M.local1
        ,       E.local2
        ,       M.b_tran_id
        ,       E.w_tran_id
        ,       M.b_name
        ,       E.w_name
        ,       M.b_tran_begin_time
        ,       E.w_tran_begin_time
        ,       M.b_state
        ,       E.w_state
        ,       M.b_trans_type
        ,       E.w_trans_type
        ,       M.b_text
        ,       E.w_text
        ,       M.db_span_count1
        ,       E.db_span_count2
        ,       M.lvl+1
        from @temp_tab as E
    join Blocking as M on E.b_tran_id = M.w_tran_id
)

select (dense_rank() over (order by no_blocked desc,b_tran_id))%2 as l1 
,       (dense_rank() over (order by no_blocked desc,b_tran_id,w_tran_id))%2 as l2 
,       * 
from Blocking 
order by no_blocked desc,b_tran_id,w_tran_id ;
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as l2
,       ERROR_SEVERITY() as blocking_status
,       ERROR_STATE() as no_blocked
,       ERROR_MESSAGE() as total_blocked
,       1 as l_resource_type,1 as l_resource_subtype,1 as l_resource_associated_entity_id,1 as l_blocking_request_spid,1 as l_blocked_request_spid,1 as l_blocking_request_mode,1 as l_blocked_request_mode,1 as local1,1 as local2,1 as b_tran_id,1 as w_tran_id,1 as b_name,1 as w_name,1 as b_tran_begin_time,1 as w_tran_begin_time,1 as b_state,1 as w_state,1 as b_trans_type,1 as w_trans_type,1 as b_text,1 as w_text,1 as db_span_count1,1 as db_span_count2,1 as lvl
end catch',@params=N''