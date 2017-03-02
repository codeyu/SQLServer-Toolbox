SELECT TOP 10 TEXT AS 'SQL Statement'
    ,last_execution_time AS 'Last Execution Time'
    ,(total_logical_reads + total_physical_reads + total_logical_writes) / execution_count AS [Average IO]
    ,(total_worker_time / execution_count) / 1000000.0 AS [Average CPU Time (sec)]
    ,(total_elapsed_time / execution_count) / 1000000.0 AS [Average Elapsed Time (sec)]
    ,execution_count AS "Execution Count"
    ,qp.query_plan AS "Query Plan"
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY total_elapsed_time / execution_count DESC