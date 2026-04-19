# SQL Server Memory Limit

By default, SQL Server can aggressively consume available RAM and may not release it quickly enough for the operating system or other applications.

## Recommended Approach

Set `max server memory` so the OS and other services still have enough memory available.

A common starting point is to reserve approximately 20 percent of total server memory for the operating system and non-SQL workloads, then assign the remaining 80 percent to SQL Server.

## Example

- Total memory: `64 GB`
- Reserve for OS and supporting services: `12-16 GB`
- SQL Server `max server memory`: `48-52 GB`

Review the final value against your actual workload, monitoring, and co-hosted services.
