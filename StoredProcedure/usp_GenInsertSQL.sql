--=================================================
--摘抄自http://www.cnblogs.com/sunth/archive/2013/06/05/3118312.html
--用法:
--EXEC [dbo].[usp_GenInsertSQL] 'dbo.TableName'
--=================================================
USE [master]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_GenInsertSQL] 
  @TableName as varchar(100) 
  as
  DECLARE xCursor CURSOR FOR
  SELECT name,xusertype 
  FROM syscolumns 
  WHERE (id = OBJECT_ID(@TableName)) 
  declare @F1 varchar(100) 
  declare @F2 integer
  declare @SQL varchar(8000)
  set @sql ='SELECT ''INSERT INTO ' + @TableName + ' VALUES('''
  OPEN xCursor 
  FETCH xCursor into @F1,@F2 
  WHILE @@FETCH_STATUS = 0 
  BEGIN
    set @sql = @sql + 
          + case when @F2 IN (35,58,99,167,175,231,239,61) then ' + case when ' + @F1 + ' IS NULL then '''' else '''''''' end + '   else '+' end
          + 'replace(ISNULL(cast(' + @F1 + ' as varchar(8000)),''NULL''),'''''''','''''''''''')'  
          + case when @F2 IN (35,58,99,167,175,231,239,61) then ' + case when ' + @F1 + ' IS NULL then '''' else '''''''' end + '   else '+' end
          + char(13) + ''','''  
    FETCH NEXT FROM xCursor into @F1,@F2 
  END
  CLOSE xCursor 
  DEALLOCATE xCursor 
  set @sql = left(@sql,len(@sql) - 5) + ' + '')'' FROM ' + @TableName 
  exec (@sql) 
GO