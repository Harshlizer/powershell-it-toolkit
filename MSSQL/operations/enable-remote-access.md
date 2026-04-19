# Enable Remote Access for SQL Server

## Steps

1. Open `SQL Server Configuration Manager` on the SQL Server host.
2. Go to `SQL Server Network Configuration` -> `Protocols for MSSQLSERVER`.
3. Open `TCP/IP` properties and set `Enabled` to `Yes`.
4. In the `IP Addresses` tab, set the `TCP Port` under `IPAll` to `1433`.
5. Restart the `SQL Server (MSSQLSERVER)` service from `SQL Server Services`.
6. Add TCP port `1433` to the Windows Firewall allow list.

## Firewall Example

```powershell
New-NetFirewallRule -DisplayName "ALLOW TCP PORT 1433" -Direction Inbound -Profile Any -Action Allow -LocalPort 1433 -Protocol TCP
```
