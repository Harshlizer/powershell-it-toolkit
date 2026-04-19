USE [<DATABASE_NAME>];
GO

SELECT TOP 20
    t.name AS [Internal_1C_Name],
    p.rows AS [Row_Count],
    CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS [Total_MB],
    CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS [Used_MB],
    CAST(ROUND((SUM(a.data_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS [Data_MB],
    CAST(ROUND((SUM(a.used_pages - a.data_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS [Index_MB],
    CAST(ROUND((SUM(a.total_pages - a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS [Unused_MB]
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
GROUP BY t.name, p.rows
ORDER BY [Total_MB] DESC;
