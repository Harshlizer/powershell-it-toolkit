# Apple Mail EWS Traffic

## Overview

High EWS call volume from application ID `<APPLE_INTERNET_ACCOUNTS_APP_ID>` is usually caused by Apple Internet Accounts, which powers the native Mail, Calendar, and Contacts apps on iOS, iPadOS, and macOS.

This is not a legacy authentication issue. The client uses modern authentication, but it still communicates through EWS instead of Microsoft Graph.

## Why It Matters

If EWS is disabled organization-wide, users who rely on the native Apple stack can immediately lose synchronization for:

- Mail
- Calendar
- Contacts

## Recommended Actions

- Move affected users to Outlook for iOS and Outlook for Mac when possible.
- Restrict EWS by application instead of disabling it globally.
- Measure real impact in Entra sign-in logs before rollout.
