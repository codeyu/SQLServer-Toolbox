USE [master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_rebuild_index] 
(
    @Rebuild_Fragmentation_Percent      smallint = 5    -- 当逻辑碎片百分比 > 5% 重新生成索引
)
as
begin
    /* 调用方法：
    1.针对当前实例所有数据库：    exec sys.sp_MSforeachdb 'use ?;exec sp_rebuild_index'
    2.针对当前数据库：            exec sp_rebuild_index
    */

    --对系统数据库不作重新组织索引和重新生成索引
    if (db_name() in ('master','model','msdb','tempdb')) return;

    --如果逻辑碎片（索引中的无序页）的百分比 <= 5% ，就不作重新组织索引和重新生成索引
    if not exists(select 1 from sys.dm_db_index_physical_stats(db_id(),null,null,null,null) a where a.index_id>0 and a.avg_fragmentation_in_percent > @Rebuild_Fragmentation_Percent) return


    print replicate('-',60)+char(13)+char(10)+replicate(' ',14)+N'对数据库 '+quotename(db_name())+N' 进行索引优化'+replicate(' ',20)+char(13)+char(10)

    declare @sql nvarchar(2000),@str nvarchar(2000)

    declare cur_x cursor for 
        select 'alter index '+quotename(a.name)+' on '+quotename(object_schema_name(a.object_id))+'.'+quotename(object_name(a.object_id))+' rebuild;' as [sql]
                ,N'重新生成索引：' +quotename(object_schema_name(a.object_id))+'.'+quotename(object_name(a.object_id))+'.'+quotename(a.name) as [str]
            from sys.indexes a
                inner join sys.dm_db_index_physical_stats(db_id(),null,null,null,null) b on b.object_id=a.object_id
                    and b.index_id=a.index_id
            where a.index_id>0
                and b.avg_fragmentation_in_percent > @Rebuild_Fragmentation_Percent
            order by object_name(a.object_id),a.index_id

    open cur_x
    fetch next from cur_x into @sql,@str

    while (@@fetch_status = 0)
    begin
        print @sql
        exec(@sql)

        print @str
        fetch next from cur_x into @sql,@str

    end
    close cur_x
    deallocate cur_x 

end