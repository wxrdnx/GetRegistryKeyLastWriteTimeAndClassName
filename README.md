# GetRegistryKeyLastWriteTimeAndClassName

A pentesting script to get the last write time of a registry key.
These scripts are forked from <https://gallery.technet.microsoft.com/scriptcenter/Get-Last-Write-Time-and-06dcf3fb>

## Usage

```powershell
Import-Module .\AddRegKeyMember_PSv2_and_higher.ps1
Get-Item HKLM:\SYSTEM\CurrentControllSet\Services\USBSTOR | Add-RegKeyMember | Select Name, LastWriteTime
```
