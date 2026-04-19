/*
    Enables Query Store in all user databases on the SQL Server instance.

    Notes:
    - System databases are excluded: master, tempdb, model, msdb.
    - The script applies ALTER DATABASE ... SET QUERY_STORE = ON to each user database.
    - Review Query Store sizing and retention settings before enabling it in bulk.
*/
DECLARE @DatabaseName NVARCHAR(255);
DECLARE database_cursor CURSOR FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

OPEN database_cursor;
FETCH NEXT FROM database_cursor INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('ALTER DATABASE [' + @DatabaseName + '] SET QUERY_STORE = ON');
    FETCH NEXT FROM database_cursor INTO @DatabaseName;
END;

CLOSE database_cursor;
DEALLOCATE database_cursor;
