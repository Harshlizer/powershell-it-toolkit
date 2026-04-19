DECLARE @dbName NVARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
  AND state_desc = 'ONLINE';

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER DATABASE [' + @dbName + '] SET COMPATIBILITY_LEVEL = 160;';
    PRINT 'Updating compatibility level for database: ' + @dbName;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM db_cursor INTO @dbName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
