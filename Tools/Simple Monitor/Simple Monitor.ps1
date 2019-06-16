[CmdletBinding()]
param(
    $server = "localhost",
    $database = "master",
    $user = "",
    $password = "",
    $outputdir = "C:\Simple Monitor",
    $interval = 10,
    [switch]$isAzure ,
    [switch]$isPDW
)
$ErrorActionPreference = "Stop"
$dateFormat = "yyyy/MM/dd HH:mm:ss"
$RunspaceSize = 5

Clear-Host

# Verify that Invoke-SqlCmd is Installed
if($null -eq (Get-Command | Where-Object Name -eq "Invoke-SqlCmd")){
    Write-Host @"
Invoke-SqlCmd is not installed."
Please install SQL Server PowerShell referring to the information of the following URL.
https://www.powershellgallery.com/packages/Sqlserver

You can also install it with the following command:.
====
Install-Module SqlServer
===
"@
    exit -1
}

Function Write-Message($message){
    Write-Host ("{0} | {1} " -f (Get-Date).ToString($dateFormat), $message)
}

function Write-ErrorMessage($message){
    Write-Host ("{0} | {1} " -f (Get-Date).ToString($dateFormat), $message) -ForegroundColor Red
}

Write-Message "Start collecting metrics. "

# Connect Test
try{
    Write-Message "Test the connection."
    $con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = ("Data Source={0};Initial Catalog={1};User Id={2};Password={3};Connection Timeout=5" -f $server, $database, $user, $password)
    $con.Open()
    Write-Message "Connection succeeded."
}catch{
    Write-ErrorMessage $Error[0].Exception.Message
    Write-ErrorMessage ("Could not connect to Server {0}." -f $server)
    exit -1
}finally{
    $con.Close()
    $con.Dispose()
}

# Run SQL file in same directory as PS1
# PDW / SQL Data Warehouse
if ($isPDW){
    $timeseriesSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "timeseries") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -Like "*PDW*"
# SQL Data Base
}elseif($isAzure){
    $timeseriesSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "timeseries") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -NotLike "*Box*" | Where-Object Name -NotLike "*PDW*"
# SQL Server
}else{
    $timeseriesSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "timeseries") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -NotLike "*Azure*" | Where-Object Name -NotLike "*PDW*"
}

# PDW / SQL Data Warehouse
if ($isPDW){
    $snapshotSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "snapshot") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -Like "*PDW*"
# SQL Data Base
}elseif($isAzure){
    $snapshotSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "snapshot") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -NotLike "*Box*" | Where-Object Name -NotLike "*PDW*"
# SQL Server
}else{
    $snapshotSqllist = Get-ChildItem -Path (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "snapshot") | Where-Object Name -Match "^[0-9].*sql" | Where-Object Name -NotLike "*Azure*" | Where-Object Name -NotLike "*PDW*"
}


# Root Directory
$outfilepath = (Join-Path $outputdir $database)
if (-not (Test-Path $outfilepath)){
    New-Item -Path $outfilepath -ItemType Directory | Out-Null
}

# Date Directory
$outfilepath = (Join-Path $outfilepath (Get-Date).ToString("yyyyMMdd"))
if (-not (Test-Path $outfilepath)){
    New-Item -Path $outfilepath -ItemType Directory | Out-Null
}

# Time Series Directory
$timeseriespath = (Join-Path $outfilepath "timeseries")
if (-not (Test-Path $timeseriespath)){
    New-Item -Path $timeseriespath -ItemType Directory | Out-Null
}

# Time Series Directory
$snapshotpath = (Join-Path $outfilepath "snapshot")
if (-not (Test-Path $snapshotpath)){
    New-Item -Path $snapshotpath -ItemType Directory | Out-Null
}


# Parameter Setting
if (-not[String]::IsNullOrEmpty($user)){
    $param = @{
        ServerInstance = $server
        Database = $database
        UserName = $user
        Password = $password
    }
}else{
    $param = @{
        ServerInstance = $server
        Database = $database
    }
}

$ExecuteSql = {
    param(
        $sqlparam,
        $inputFile,
        $outFileFullName
    )
    try{
        # if ($PSVersionTable.PSVersion.Major -lt 6){
        #     [System.Threading.Monitor]::Enter([guid])
        # }
        # https://social.technet.microsoft.com/wiki/contents/articles/40091.automating-sql-operations-with-service-management-automation-sma-and-invoke-sqlcmd-challenges-and-solutions.aspx
        # Invoke-Sqlcmd @sqlparam -InputFile $inputFile -ErrorAction Stop | Export-Csv -Path $outFileFullName -NoTypeInformation -Append -Force 
        $con = New-Object System.Data.SqlClient.SqlConnection
        $con.ConnectionString = ("Data Source={0};Initial Catalog={1};User Id={2};Password={3};Connection Timeout=5" -f $sqlparam.ServerInstance, $sqlparam.Database, $sqlparam.UserName, $sqlparam.Password)
        $con.Open()
        $da = New-Object System.Data.SqlClient.SqlDataAdapter
        $dt = New-Object System.Data.DataTable
        $cmd = $con.CreateCommand()
        $cmd.CommandText = (Get-Content $inputFile)
        $da.SelectCommand = $cmd
        [void]$da.Fill($dt)
        $dt | Export-Csv -Path $outFileFullName -NoTypeInformation -Append -Force 

    }catch{
        throw $Error[0].Exception.Message
    }finally{
        # if ($PSVersionTable.PSVersion.Major -lt 6){
        #     [System.Threading.Monitor]::Exit([guid])
        # }
        $dt.Dispose()
        $da.Dispose()
        $con.Close()
        $con.Dispose()
    }
}

Write-Message "Start collecting snapshot data."
# Collect Snapshot Data
try{
    foreach($sqlfile in $snapshotSqllist){
        $outfile = ($sqlfile.BaseName -split "_")[0] + ".txt"
        $outFileFullName = (Join-Path $snapshotpath $outfile)
        $ExecuteSql.Invoke(
            $param,
            $sqlfile.FullName,
            $outFileFullName)
    }
}catch{
    Write-ErrorMessage ("{0} | {1}" -f $sqlfile, $Error[0].Exception.Message)
}
Write-Message "End collecting snapshot data."

# Collect Time Series Data
$minpoolsize = $maxpoolsize = $RunspaceSize
$runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize)
$runspacePool.Open()
$RunspaceCollection  = New-Object System.Collections.ArrayList

Write-Message "Start collecting time series data."
Write-Message "Press Ctrl+C to exit."

try{
    while($true){
        foreach($sqlfile in $timeseriesSqllist){
            try{
                $outfile = ($sqlfile.BaseName -split "_")[0] + ".txt"
                $outFileFullName = (Join-Path $timeseriespath $outfile)

                $powershell = [PowerShell]::Create().AddScript($ExecuteSql).`
                    AddArgument($param).`
                    AddArgument($sqlfile.FullName).`
                    AddArgument($outFileFullName)
                $powershell.RunspacePool = $runspacePool
                [void]$RunspaceCollection.Add([PSCustomObject] @{
                    FileName = $sqlfile.Name
                    Runspace = $powershell.BeginInvoke();
                    PowerShell = $powershell
                })
                # $res = $ExecuteSql.Invoke($param, $sqlfile.FullName,$outFileFullName)
            }catch{
                Write-ErrorMessage ("{0} | {1}" -f $sqlfile, $Error[0].Exception.Message)
            }
        }        
        while($RunspaceCollection){
            foreach($runspace in $RunspaceCollection){
                if ($runspace.Runspace.IsCompleted){
                    try{
                        $runspace.PowerShell.EndInvoke($runspace.Runspace)
                        if($null -ne $runspace.PowerShell.Streams.Error){
                            foreach($err in $runspace.PowerShell.Streams.Error){
                                Write-ErrorMessage $err.Exception.Message
                            }
                        }
                        $runspace.PowerShell.Dispose()
                    }catch{
                        Write-ErrorMessage ("File : {0} | {1}" -f $runspace.FileName, $runspace.PowerShell.InvocationStateInfo.Reason.ErrorRecord.Exception.Message)
                    }
                    $RunspaceCollection.Remove($runspace)
                    break
                }
            }
            Start-Sleep -Milliseconds 10
        }
        Start-Sleep -Seconds $interval
    }
}catch{
    Write-Error $Error[0]
}
finally{
    Write-Message "Stop collecting time series data."
    Write-Message "Stop collecting metrics. "
}
