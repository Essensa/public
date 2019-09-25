PowerShell Mount-DiskImage -ImagePath "'C:\Program Files (x86)\sql2016.iso'"
PowerShell "(Get-DiskImage -ImagePath "'C:\Program Files (x86)\sql2016.iso'" | Get-Volume).DriveLetter" > "C:\Program Files (x86)\volume.txt"
set /p volume=<"C:\Program Files (x86)\volume.txt"
del "C:\Program Files (x86)\volume.txt"
Dism /online /enable-feature /featurename:NetFx3 /All

powershell.exe -executionpolicy remotesigned -file "C:\Program Files (x86)\generate_password.ps1"
set /p password=<"C:\Program Files (x86)\password_for_MSSQL.txt"
%volume%:\setup.exe /qs /ACTION=install /IACCEPTSQLSERVERLICENSETERMS=1 /INSTANCENAME=MSSQLServer /FEATURES=SQLEngine,Replication /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /SQLSYSADMINACCOUNTS=Administrator /BROWSERSVCSTARTUPTYPE=Automatic /SECURITYMODE=SQL /SAPWD=%password% /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /AGTSVCSTARTUPTYPE=Automatic /NPENABLED=1 /TCPENABLED=1 /ERRORREPORTING=1

netsh advfirewall firewall add rule name=\"Open Port 80\" dir=in action=allow protocol=TCP localport=80

netsh advfirewall firewall add rule name=\"SQL Server\" dir=in action=allow protocol=TCP localport=1433

netsh advfirewall firewall add rule name=\"SQL Admin Connection\" dir=in action=allow protocol=TCP localport=1434

netsh advfirewall firewall add rule name=\"SQL Service Broker\" dir=in action=allow protocol=TCP localport=4022

netsh advfirewall firewall add rule name=\"SQL Debugger/RPC\" dir=in action=allow protocol=TCP localport=135

netsh advfirewall firewall add rule name=\"Analysis Services\" dir=in action=allow protocol=TCP localport=2383

netsh advfirewall firewall add rule name=\"SQL Browser\" dir=in action=allow protocol=TCP localport=2382

netsh advfirewall firewall add rule name=\"HTTP\" dir=in action=allow protocol=TCP localport=80

netsh advfirewall firewall add rule name=\"SSL\" dir=in action=allow protocol=TCP localport=443

netsh advfirewall firewall add rule name=\"SQL Browser\" dir=in action=allow protocol=UDP localport=1434

netsh firewall set multicastbroadcastresponse ENABLE


PowerShell Dismount-DiskImage -ImagePath "'C:\Program Files (x86)\sql2016.iso'"
