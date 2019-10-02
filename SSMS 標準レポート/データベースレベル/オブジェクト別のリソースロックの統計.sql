exec sp_executesql @stmt=N'begin try 
declare @obj_locks table(       
        obj_id bigint
,       obj_name sysname collate database_default null
,       resource_type nvarchar(60) collate database_default 
,       request_mode nvarchar(60) collate database_default 
,       request_status nvarchar(60) collate database_default 
,       request_owner_type nvarchar(60) collate database_default 
,       request_owner_id bigint
,       session_id int
,       request_id int
,       login_name sysname collate database_default  null
,       waiting_tran_1 int
,       waiting_tran_2 int
,       waiting_tran_3 int
,       waiting_tran_4 int
,       waiting_tran_5 int
);      
declare @waiting_tran table (   
        obj_id bigint
,       tran_id bigint
,       wait_time bigint
);      
declare @objects table (
        row_no int identity
,       obj_id bigint
);

INSERT INTO @obj_locks  
select case when obj.object_id is null then -1 else obj.object_id end
,       case when obj.name is null then ''System Resources'' else sch.name+''.''+obj.name end as obj_name
,       tl.resource_type
,       tl.request_mode as request_mode
,       tl.request_status
,       tl.request_owner_type
,       tl.request_owner_id
,       tl.request_session_id
,       tl.request_request_id
,       session.login_name
,0,0,0,0,0      
from sys.dm_tran_locks tl 
left outer join sys.partitions prt on (tl.resource_type in (''PAGE'',''HOBT'',''KEY'',''RID'') and tl.resource_associated_entity_id = prt.hobt_id) 
left outer join sys.objects obj on ((tl.resource_type in (''PAGE'',''HOBT'',''KEY'',''RID'') and obj.object_id = prt.object_id) or (tl.resource_type not in (''PAGE'',''HOBT'',''KEY'',''RID'') and tl.resource_associated_entity_id = obj.object_id)) 
left outer join sys.schemas sch on (obj.schema_id = sch.schema_id) 
left outer join sys.dm_exec_sessions session on (tl.request_session_id = session.session_id)    

insert into @waiting_tran       
select ol.obj_id
,       ol.request_owner_id
,       r.wait_time     
from @obj_locks ol      
left outer join sys.dm_exec_requests r on (ol.session_id = r.session_id)        
where ol.request_status = ''WAIT''        

insert into @objects    
select distinct(obj_id) from @waiting_tran      

declare @cnt int        
declare @obj_id bigint  
select @cnt = count(*) from @objects    
while @cnt > 0       
begin   
        select @obj_id = obj_id from @objects where row_no = @cnt       
        update @obj_locks  set  waiting_tran_1 = (select count(*) from @waiting_tran wt where wt.obj_id = @obj_id and wt.wait_time <= 100)
        ,       waiting_tran_2 = (select count(*) from @waiting_tran wt where wt.obj_id = @obj_id and wt.wait_time <= 1000 and wt.wait_time > 100)
        ,       waiting_tran_3 = (select count(*) from @waiting_tran wt where wt.obj_id = @obj_id and wt.wait_time <= 60000 and wt.wait_time > 1000)
        ,       waiting_tran_4 = (select count(*) from @waiting_tran wt where wt.obj_id = @obj_id and wt.wait_time <= 600000  and wt.wait_time > 60000 )
        ,       waiting_tran_5 = (select count(*) from @waiting_tran wt where wt.obj_id = @obj_id and wt.wait_time >= 600000 )
          where obj_id = @obj_id
          set @cnt = @cnt - 1
          end
          
          select dense_rank() over(order by waiting_tran_1+waiting_tran_2+waiting_tran_3+waiting_tran_4+waiting_tran_5 desc , obj_id) as rank
          ,       (dense_rank() over(order by waiting_tran_1+waiting_tran_2+waiting_tran_3+waiting_tran_4+waiting_tran_5 desc , obj_id))%2 as l1
          ,       (dense_rank() over(order by waiting_tran_1+waiting_tran_2+waiting_tran_3+waiting_tran_4+waiting_tran_5 desc , obj_id,(case resource_type when ''METADATA'' then 1 when ''DATABASE'' then 2 when ''FILE'' then 3 when ''TABLE'' then 4 when ''HOBT'' then 5 when ''EXTENT'' then 6 when ''PAGE'' then 7 when ''KEY'' then 8 when ''RID'' then 9 when ''ALLOCATION_UNIT'' then 10 when ''APPLICATION'' then 11 else 12 end)))%2 as l2
          ,       (dense_rank() over(order by waiting_tran_1+waiting_tran_2+waiting_tran_3+waiting_tran_4+waiting_tran_5 desc , obj_id,(case resource_type when ''METADATA'' then 1 when ''DATABASE'' then 2 when ''FILE'' then 3 when ''TABLE'' then 4 when ''HOBT'' then 5 when ''EXTENT'' then 6 when ''PAGE'' then 7 when ''KEY'' then 8 when ''RID'' then 9 when ''ALLOCATION_UNIT'' then 10 when ''APPLICATION'' then 11 else 12 end),request_owner_type,request_owner_id))%2 as l3
          ,       *
          ,       case resource_type when ''METADATA'' then 1
          when ''DATABASE'' then 2
          when ''FILE'' then 3
          when ''TABLE'' then 4
          when ''HOBT'' then 5
          when ''EXTENT'' then 6
          when ''PAGE'' then 7
          when ''KEY'' then 8
          when ''RID'' then 9
          when ''ALLOCATION_UNIT'' then 10
          when ''APPLICATION'' then 11
          else 12
          end as resource_rank
          from @obj_locks
          
          end try
          begin catch
          select          1 as rank
          ,       -100 as l1
          ,       ERROR_NUMBER() as l2
          ,       ERROR_SEVERITY() as l3
          ,       ERROR_STATE() as obj_id
          ,       ERROR_MESSAGE() as obj_name
          ,       1 as resource_type ,    1 as locking_mode ,     1 as request_status ,   1 as request_owner_type ,       1 as request_owner_id , 1 as session_id ,       1 as request_id ,       1 as login_name ,       1 as waiting_tran_1 ,   1 as waiting_tran_2 ,   1 as waiting_tran_3 ,   1 as waiting_tran_4 ,   1 as waiting_tran_5 ,   1 as resource_rank
          end catch',@params=N''