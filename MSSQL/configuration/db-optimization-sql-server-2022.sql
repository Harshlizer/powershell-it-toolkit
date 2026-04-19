DECLARE @dbName NVARCHAR(255);

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE database_id > 4
  AND state_desc = 'ONLINE';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = '
    ALTER DATABASE [' + @dbName + '] SET COMPATIBILITY_LEVEL = 160;

    ALTER DATABASE [' + @dbName + '] SET QUERY_STORE = ON;
    ALTER DATABASE [' + @dbName + ']
        SET QUERY_STORE (
            OPERATION_MODE = READ_WRITE,
            CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
            DATA_FLUSH_INTERVAL_SECONDS = 900,
            INTERVAL_LENGTH_MINUTES = 60,
            MAX_STORAGE_SIZE_MB = 1024,
            QUERY_CAPTURE_MODE = AUTO
        );

    ALTER DATABASE [' + @dbName + '] SET ACCELERATED_DATABASE_RECOVERY = ON;

    USE [' + @dbName + '];
    EXEC sp_updatestats;
    ';

    PRINT 'Applying SQL Server 2022 optimization settings to database: ' + @dbName;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @dbName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
