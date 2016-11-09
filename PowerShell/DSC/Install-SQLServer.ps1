# https://github.com/PowerShell/xSQLServer
# C:\Program Files\WindowsPowerShell\Modules に DSC Resource を配置
# PowerShell v5 以降を使用する場合、以下で　DSC Resource をインストールすることが可能
# Install-Module xSQLServer -Scope AllUsers -Force

if(!(Test-Path (Join-Path $ENV:ProgramFiles "WindowsPowerShell\Modules\xSQLServer\ja-jp"))){
    Copy-Item (Join-Path $ENV:ProgramFiles "WindowsPowerShell\Modules\xSQLServer\en-us") (Join-Path $ENV:ProgramFiles "WindowsPowerShell\Modules\xSQLServer\ja-jp") -Recurse
}
$Password = "M@sterEr0s"

Configuration LCM
{
        LocalConfigurationManager
        {
            AllowModuleOverwrite = $true
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }
}

Configuration SQLServer
{
    Import-DscResource -Module xSQLServer

    Node $AllNodes.NodeName
    {
        xSqlServerSetup SQLServer
        {
            SourcePath = $Node.SourcePath
            SourceFolder = $Node.SourceFolder
            SetupCredential = $Node.SetupCredential
            InstanceName = $Node.InstanceName
            Features = $Node.Features
            SQLSysAdminAccounts = $Node.SQLSysAdminAccounts
            InstallSharedDir =  $Node.InstallSharedDir
            InstallSharedWOWDir =  $Node.InstallSharedWOWDir
            InstanceDir =  $Node.InstanceDir
            InstallSQLDataDir =  $Node.InstallSQLDataDir
            SQLUserDBDir =  $Node.SQLUserDBDir
            SQLUserDBLogDir =  $Node.SQLUserDBLogDir
            SQLTempDBDir =  $Node.SQLTempDBDir
            SQLTempDBLogDir =  $Node.SQLTempDBLogDir
            SQLBackupDir =  $Node.SQLBackupDir
        }     
        xSQLServerFirewall SQLFirewall
        {
            DependsOn = "[xSqlServerSetup]SQLServer"
            InstanceName = $Node.InstanceName
            Features = $Node.Features
            SourcePath = $Node.SourcePath
            SourceFolder = $Node.SourceFolder
        }
    }
}

$SetupCredential = New-Object System.Management.Automation.PSCredential ("Administrator", (ConvertTo-SecureString -String $Password -AsPlainText -Force))

$ConfiguraionData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $true
            SourcePath = "D:\"
            SourceFolder = ""
        },
        @{
            NodeName = "localhost"
            InstanceName = "MSSQLSERVER"
            Features = "SQLENGINE,FULLTEXT,REPLICATION"
            SetupCredential = $SetupCredential
            SQLSysAdminAccounts = ".\administrator"
            InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
            InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
            InstanceDir       = "C:\Program Files\Microsoft SQL Server"
            InstallSQLDataDir = ""
            SQLUserDBDir      = ""
            SQLUserDBLogDir   = ""
            SQLTempDBDir      = ""
            SQLTempDBLogDir   = ""
            SQLBackupDir      = ""
            TCPPort = "1433"
        }
    )
}

LCM -OutputPath C:\temp
Set-DscLocalConfigurationManager -Path c:\temp
Get-DscLocalConfigurationManager

SQLServer -OutputPath (Join-Path "C:\temp" "Mof") -ConfigurationData $ConfiguraionData -Verbose
Start-DscConfiguration -Path  (Join-Path "C:\temp" "Mof") -Verbose -Wait -Force
Get-DscConfiguration
