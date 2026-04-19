# Error 15281: SQL Server Agent XPs Disabled

This error usually means SQL Server Agent extended stored procedures are disabled, not that SQL Server Agent is missing.

## Fix

Run the following commands as a `sysadmin`:

```sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;
```

## Afterward

- Restart the `SQL Server Agent` service if needed.
- Or start it from SQL:

```sql
EXEC xp_servicecontrol 'START', 'SQLServerAgent';
```

## Verification

```sql
EXEC sp_configure 'Agent XPs';
```

Expected result:

```text
run_value = 1
```
