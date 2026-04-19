PRINT 'USE ' + DB_NAME();
PRINT 'GO';

DECLARE @output NVARCHAR(MAX);
SET @output = '';

SELECT @output = @output +
'CREATE USER ' + QUOTENAME(mp.name) + ' FOR LOGIN ' + QUOTENAME(sp.name) + CHAR(13)
FROM sys.database_principals sp
INNER JOIN sys.database_principals mp
    ON mp.principal_id = sp.principal_id
   AND mp.type <> 'R'
LEFT JOIN sys.database_role_members rm
    ON rm.member_principal_id = mp.principal_id
LEFT JOIN sys.database_principals rpn
    ON rm.role_principal_id = rpn.principal_id
   AND rpn.type = 'R'
INNER JOIN sys.database_principals rp
    ON rm.role_principal_id = rp.principal_id
WHERE mp.name NOT IN ('sys', 'dbo', 'guest')
GROUP BY mp.name, sp.name;

PRINT @output;
PRINT 'GO';

SET @output = '';

SELECT @output = @output +
'EXEC sp_addrolemember ''' + rpn.name + ''',''' + mp.name + '''' + CHAR(13)
FROM sys.database_principals sp
INNER JOIN sys.database_principals mp
    ON mp.principal_id = sp.principal_id
   AND mp.type <> 'R'
LEFT JOIN sys.database_role_members rm
    ON rm.member_principal_id = mp.principal_id
LEFT JOIN sys.database_principals rpn
    ON rm.role_principal_id = rpn.principal_id
   AND rpn.type = 'R'
INNER JOIN sys.database_principals rp
    ON rm.role_principal_id = rp.principal_id
WHERE mp.name NOT IN ('sys', 'dbo', 'guest')
GROUP BY mp.name, sp.name, rpn.name;

PRINT @output;
PRINT 'GO';
