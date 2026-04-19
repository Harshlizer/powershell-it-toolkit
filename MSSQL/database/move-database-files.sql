/*
    Moves the physical data and log files for a SQL Server database.

    Replace the database name, logical file names, and target paths before use.
    Take the database offline and move the files at the OS level as required by your procedure.
*/
ALTER DATABASE [<DATABASE_NAME>]
    MODIFY FILE (
        NAME = <DATABASE_NAME>_Data,
        FILENAME = 'E:\<NEW_LOCATION>\<DATABASE_NAME>_Data.mdf'
    );
GO

ALTER DATABASE [<DATABASE_NAME>]
    MODIFY FILE (
        NAME = <DATABASE_NAME>_Log,
        FILENAME = 'E:\<NEW_LOCATION>\<DATABASE_NAME>_Log.ldf'
    );
GO
