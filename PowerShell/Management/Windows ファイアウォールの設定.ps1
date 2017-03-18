New-NetFirewallRule -Group "SQL Server" -Name "SQL Server" -DisplayName "SQL Server" -Protocol tcp -LocalPort @(1433, 1434)
New-NetFirewallRule -Group "SQL Server" -Name "SQL Server Browser" -DisplayName "SQL Server Browser" -Protocol udp -LocalPort @(1434)

