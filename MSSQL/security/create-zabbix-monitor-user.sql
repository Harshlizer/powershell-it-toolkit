/*
    Creates a SQL Server login and database user for monitoring purposes.

    Replace the placeholder values before running the script.
*/
USE [master];
GO

CREATE LOGIN [<MONITOR_USERNAME>]
WITH PASSWORD = N'<MONITOR_PASSWORD>',
DEFAULT_DATABASE = [master],
DEFAULT_LANGUAGE = [us_english],
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF;
GO

GRANT VIEW SERVER STATE TO [<MONITOR_USERNAME>];
GO

GRANT VIEW ANY DEFINITION TO [<MONITOR_USERNAME>];
GO

USE [msdb];
GO

CREATE USER [<MONITOR_USERNAME>] FOR LOGIN [<MONITOR_USERNAME>];
GO

GRANT SELECT ON OBJECT::msdb.dbo.sysjobs TO [<MONITOR_USERNAME>];
GRANT SELECT ON OBJECT::msdb.dbo.sysjobservers TO [<MONITOR_USERNAME>];
GRANT SELECT ON OBJECT::msdb.dbo.sysjobactivity TO [<MONITOR_USERNAME>];
GRANT EXECUTE ON OBJECT::msdb.dbo.agent_datetime TO [<MONITOR_USERNAME>];
GO
