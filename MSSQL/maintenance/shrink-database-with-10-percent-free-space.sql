-- Shrinks the database while leaving approximately 10 percent free space to reduce immediate regrowth pressure.
DBCC SHRINKDATABASE ([<DATABASE_NAME>], 10);
