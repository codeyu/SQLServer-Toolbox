--1.查看数据库的版本
select @@version as Version
--2.查看数据库所在机器操作系统参数
exec master..xp_msver 
--3.查看数据库启动的参数 
exec sp_configure 
--4.查看数据库启动时间 
select convert(varchar(30),login_time,120) as StartRunTime from master..sysprocesses where spid=1 
--5.查看数据库服务器名和实例名 
print 'Server Name...............：' + convert(varchar(30),@@SERVERNAME) 
print 'Instance..................：' + convert(varchar(30),@@SERVICENAME) 
--6. 查看所有数据库名称及大小 
exec sp_helpdb 
--重命名数据库用的SQL 
sp_renamedb 'old_dbname', 'new_dbname' 
--7. 查看所有数据库用户登录信息 
sp_helplogins 
--8.查看所有数据库用户所属的角色信息 
sp_helpsrvrolemember 
--修复迁移服务器时孤立用户时,可以用的fix_orphan_user脚本或者LoneUser过程 
--9.更改某个数据对象的用户属主 
sp_changeobjectowner [@objectname =] 'object', [@newowner =] 'owner' 
--注意：更改对象名的任一部分都可能破坏脚本和存储过程。 
--把一台服务器上的数据库用户登录信息备份出来可以用add_login_to_aserver脚本 
--10.查看某数据库下,对象级用户权限 
sp_helprotect 
--11. 查看链接服务器 
sp_helplinkedsrvlogin 
--12.查看远端数据库用户登录信息 
sp_helpremotelogin 
--13.查看某数据库下某个数据对象的大小。还可以用sp_toptables过程看最大的N(默认为50)个表
sp_spaceused @objname 

--14.查看某数据库下某个数据对象的索引信息 
sp_helpindex @objname 
--15.还可以用SP_NChelpindex过程查看更详细的索引情况 
SP_NChelpindex @objname 
--clustered索引是把记录按物理顺序排列的，索引占的空间比较少。 
--对键值DML操作十分频繁的表我建议用非clustered索引和约束，fillfactor参数都用默认值。 
--16.查看某数据库下某个数据对象的的约束信息 
sp_helpconstraint @objname 
--17.查看数据库里所有的存储过程和函数 
use @database_name 
sp_stored_procedures 
--18.查看存储过程和函数的源代码 
sp_helptext [url=mailto:'@procedure_name']'@procedure_name'[/url] 
--查看包含某个字符串@str的数据对象名称 
select distinct object_name(id) from syscomments where text like [url=mailto:'%@str%']'%@str%'[/url] 
--创建加密的存储过程或函数在AS前面加WITH ENCRYPTION参数 
--解密加密过的存储过程和函数可以用sp_decrypt过程 
--19.查看数据库里用户和进程的信息 
sp_who 
--查看SQL Server数据库里的活动用户和进程的信息 
sp_who 'active' 
--查看SQL Server数据库里的锁的情况 
sp_lock 
--进程号1--50是SQL Server系统内部用的,进程号大于50的才是用户的连接进程. 
--spid是进程编号,dbid是数据库编号,objid是数据对象编号 
--查看进程正在执行的SQL语句 
select * from master..sysprocesses
dbcc inputbuffer(spid) 
--推荐大家用经过改进后的sp_who3过程可以直接看到进程运行的SQL语句 http://www.sqlservercentral.com/scripts/sp_who3/69906/ 
--11.查看和收缩数据库文章文件的方法 
--查看所有数据库文章文件大小 
dbcc sqlperf(logspace) 
--如果某些文章文件较大，收缩简单恢复模式数据库文章，收缩后@database_name_log的大小单位为M 
backup log @database_name with no_log 
dbcc shrinkfile (@database_name_log, 5) 
--13.查看数据库在哪里 
SELECT * FROM sysfiles