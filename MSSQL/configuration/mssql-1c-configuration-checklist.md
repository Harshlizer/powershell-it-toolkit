# Microsoft SQL Server Configuration for 1C:Enterprise

This checklist summarizes recommended SQL Server settings for 1C:Enterprise deployments.

## General

- Install the latest Service Pack and the latest cumulative update for your SQL Server version.
- Align storage to a 1024 KB boundary and format with a 64 KB allocation unit size unless your storage vendor recommends otherwise.

## Operating System

- Enable `Database instant file initialization` for the account running the SQL Server service.
- Validate instant file initialization by creating and deleting a test database with a large data file.
- Grant `Lock pages in memory` to the SQL Server service account unless SQL Server and 1C share the same host and your operational standard says otherwise.
- Use the `High performance` power plan.
- Make sure database and transaction log files are not compressed.
- Exclude data and log files from file-based backup products.

## Server Properties

- Set an appropriate `max server memory` limit, especially if SQL Server and 1C run on the same host.
- Configure separate default locations for data files and transaction log files when possible.
- Set `Max degree of parallelism` to `1`.
- Enable SQL Server authentication if required by your application design.
- Create dedicated logins for each working database and assign only the required roles.
- Enable remote administrative connections:

```sql
EXEC sp_configure 'remote admin connections', 1;
GO
RECONFIGURE;
GO
```

## Database Settings

### `model`

- Set the initial data file size to approximately 1 GB to 10 GB.
- Set the initial log file size to approximately 1 GB to 2 GB.
- Set file growth to `512 MB`.
- Set the recovery model according to your backup policy.
- Set `Auto update statistics asynchronously` to `True`.

### `tempdb`

- Split `tempdb` into four data files.
- If `tempdb` is on a dedicated volume, size each file according to roughly `(50% of the volume size / number of files)`.
- If `tempdb` shares storage with user databases, use an initial size of approximately 1 GB to 10 GB per file.
- Set file growth to `512 MB`.

### User Databases

- Use settings similar to `model`, but size files according to the expected long-term database size.
- Size the log file so auto-growth is avoided between log backups whenever possible.

## Trace Flags

- `4199` - enable optimizer hotfixes where appropriate for older SQL Server versions.
- `1118` - avoid mixed extents on older versions where this is not already the default.

## Network Protocols

- Enable `TCP/IP`.
- If the 1C server is installed on the same host, enable `Shared Memory`.
- Disable `Named Pipes`.

## Maintenance

- Create a `Database Mail` account.
- Configure operators for alerting and assign valid email addresses.
- Configure maintenance plans or jobs to notify operators on failure.
- Configure backups according to the approved backup plan.
- Test restore procedures after the first successful automated backup.
- Configure regular maintenance for working databases.

## Final Step

Restart SQL Server services after applying all settings.
