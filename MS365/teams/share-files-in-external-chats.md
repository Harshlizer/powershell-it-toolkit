# Share Files in External Chats in Microsoft Teams

## Overview

Teams can support file sharing in federated chats, but this capability depends on OneDrive, SharePoint, Entra B2B, and external sharing controls.

## PowerShell Examples

```powershell
Connect-MicrosoftTeams
Set-CsTeamsFilesPolicy -Identity Global -FileSharingInChatsWithExternalUsers Enabled
Get-CsTeamsFilesPolicy | Select-Object Identity, FileSharingInChatsWithExternalUsers
Set-CsTeamsFilesPolicy -Identity Global -FileSharingInChatsWithExternalUsers Disabled
Set-CsTeamsMessagingPolicy -Identity Global -AutoShareFilesInExternalChats Disabled
```
