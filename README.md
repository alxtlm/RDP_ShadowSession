# RDP_ShadowSession

RDP Shadow session GUI tool

## Using

Create domain group (example: corp\TS Support) for shadow session.

Add user to group.

Add terminal server to file rdp_shadowsession_servers.txt

On all terminal server run with elevated cmd:

wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TSPermissionsSetting WHERE (TerminalName='RDP-Tcp') CALL AddAccount 'corp\TS Support',2

Run with powershell rdp_shadowsession.ps1
