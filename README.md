# RDP_ShadowSession
RDP Shadow session GUI tool

Using domain group (example: corp\TS Support) for shadow session:

with elevated cmd:
wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TSPermissionsSetting WHERE (TerminalName='RDP-Tcp') CALL AddAccount 'corp\TS Support',2