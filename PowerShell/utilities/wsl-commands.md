# WSL Commands

```powershell
wsl --install
wsl --set-default-version 2
wsl --list --online
wsl --install -d Ubuntu
wsl --list --verbose
wsl
wsl -d <DISTRIBUTION_NAME>
wsl --set-version <DISTRIBUTION_NAME> 2
wsl --set-default <DISTRIBUTION_NAME>
wsl --unregister <DISTRIBUTION_NAME>
wsl --status
wsl --update
wsl --export <DISTRIBUTION_NAME> <BACKUP_FILE_PATH.tar>
wsl --import <NEW_DISTRIBUTION_NAME> <TARGET_FOLDER> <BACKUP_FILE_PATH.tar>
wsl cp /path/to/file C:\path\to\folder
wsl cp C:\path\to\file /path/to/folder
wsl --shutdown
wsl --terminate <DISTRIBUTION_NAME>
```
