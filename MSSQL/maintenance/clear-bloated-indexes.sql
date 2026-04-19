USE [<DATABASE_NAME>];
GO

DECLARE @TableName NVARCHAR(256);
DECLARE @SchemaName NVARCHAR(256);
DECLARE @FullTableName NVARCHAR(512);
DECLARE @SQL NVARCHAR(MAX);

DECLARE @MinIndexSizeMB INT = 50;
DECLARE @Ratio INT = 3;

PRINT 'Searching for tables with anomalously large indexes (ratio > ' + CAST(@Ratio AS VARCHAR(10)) + ')...';

DECLARE BloatedTableCursor CURSOR FAST_FORWARD FOR
SELECT
    t.Name AS TableName,
    s.Name AS SchemaName
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_ms_shipped = 0
GROUP BY t.Name, s.Name, p.rows
HAVING
    (SUM(a.used_pages - a.data_pages) * 8 / 1024) > @MinIndexSizeMB
    AND (
        SUM(a.data_pages) = 0
        OR (SUM(a.used_pages - a.data_pages)) > (SUM(a.data_pages) * @Ratio)
    )
ORDER BY (SUM(a.used_pages - a.data_pages)) DESC;

OPEN BloatedTableCursor;
FETCH NEXT FROM BloatedTableCursor INTO @TableName, @SchemaName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FullTableName = '[' + @SchemaName + '].[' + @TableName + ']';

    PRINT 'Anomaly detected: ' + @FullTableName;
    PRINT 'Running REBUILD with PAGE compression...';

    SET @SQL = 'ALTER TABLE ' + @FullTableName + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);';

    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT '--> Compression completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT '--> ERROR: ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM BloatedTableCursor INTO @TableName, @SchemaName;
END;

CLOSE BloatedTableCursor;
DEALLOCATE BloatedTableCursor;

PRINT 'Done. Review reclaimed space after completion.';
GO
