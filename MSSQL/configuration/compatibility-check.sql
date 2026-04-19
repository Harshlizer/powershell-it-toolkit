SELECT
    name AS DatabaseName,
    compatibility_level,
    CASE compatibility_level
        WHEN 80 THEN 'SQL Server 2000'
        WHEN 90 THEN 'SQL Server 2005'
        WHEN 100 THEN 'SQL Server 2008'
        WHEN 110 THEN 'SQL Server 2012'
        WHEN 120 THEN 'SQL Server 2014'
        WHEN 130 THEN 'SQL Server 2016'
        WHEN 140 THEN 'SQL Server 2017'
        WHEN 150 THEN 'SQL Server 2019'
        WHEN 160 THEN 'SQL Server 2022'
        ELSE 'Unknown'
    END AS SQL_Version
FROM sys.databases
ORDER BY name;
