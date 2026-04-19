USE [<DATABASE_NAME>];
GO

DECLARE @MinIndexSizeMB INT = 50;
DECLARE @Ratio INT = 3;

PRINT 'Searching for the top 30 tables with the largest oversized indexes...';

;WITH TableSizes AS
(
    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS RowCnt,
        SUM(a.data_pages) * 8.0 / 1024 AS DataSizeMB,
        SUM(a.used_pages - a.data_pages) * 8.0 / 1024 AS IndexSizeMB,
        SUM(a.used_pages) * 8.0 / 1024 AS TotalSizeMB
    FROM sys.tables t
    INNER JOIN sys.indexes i
        ON t.object_id = i.object_id
    INNER JOIN sys.partitions p
        ON i.object_id = p.object_id
       AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a
        ON p.partition_id = a.container_id
    INNER JOIN sys.schemas s
        ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0
    GROUP BY s.name, t.name, t.object_id
)
SELECT TOP (30)
    SchemaName,
    TableName,
    RowCnt,
    CAST(DataSizeMB AS DECIMAL(18,2)) AS DataSizeMB,
    CAST(IndexSizeMB AS DECIMAL(18,2)) AS IndexSizeMB,
    CAST(TotalSizeMB AS DECIMAL(18,2)) AS TotalSizeMB,
    CAST(
        CASE
            WHEN DataSizeMB = 0 THEN NULL
            ELSE IndexSizeMB / NULLIF(DataSizeMB, 0)
        END
        AS DECIMAL(18,2)
    ) AS IndexToDataRatio
FROM TableSizes
WHERE
    IndexSizeMB > @MinIndexSizeMB
    AND (
        DataSizeMB = 0
        OR IndexSizeMB > (DataSizeMB * @Ratio)
    )
ORDER BY IndexSizeMB DESC;
GO
