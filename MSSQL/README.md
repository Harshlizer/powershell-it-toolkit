# MSSQL Knowledge Base

This folder contains the English version of the MSSQL materials migrated from the internal Notion knowledge base.

All Russian text was translated to English.
All credentials, passwords, login names, bucket names, tenant IDs, client IDs, client secrets, email addresses, hostnames, and IP addresses were replaced with safe placeholders.

## Structure

- `analysis/` - table and index analysis queries
- `backup/` - backup-related scripts
- `configuration/` - server and database configuration guidance
- `database/` - database file relocation scripts
- `maintenance/` - maintenance and cleanup notes
- `monitoring/` - SQL Agent job monitoring examples
- `operations/` - operational guides
- `security/` - login and user management scripts
- `tempdb/` - TempDB diagnostics
- `troubleshooting/` - common issue fixes

## Notes

- Replace placeholders such as `<USERNAME>`, `<PASSWORD>`, `<BUCKET_NAME>`, `<TENANT_ID>`, and `<CLIENT_SECRET>` with environment-specific values.
- Review each script before running it in production.
- `maintenance/maintenance-solution.md` references the official Ola Hallengren Maintenance Solution rather than embedding the full upstream installer script.
