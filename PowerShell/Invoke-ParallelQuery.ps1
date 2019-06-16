[CmdletBinding()]
Param(
    [int]$ConnectionTimeout = 15,
    [Parameter(Mandatory=$True)]
    [string]$ServerInstance,
    [Parameter(Mandatory=$True)]
    [string]$Username,
    [Parameter(Mandatory=$True)]
    [string]$Password,
    [Parameter(Mandatory=$True)]
    [pscustomobject[]]$SQL,
    [switch]$UniqueAppName,
    [switch]$DisableConnectionPool
)


##### Function definition ####
function Out-Message([string]$Msg, [switch]$Error, [switch]$Info ){
    Write-Host ("[{0}] $Msg" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss.fff"),  $Msg) -ForegroundColor $(if($Error){"Red"} elseif($Info){"Green"} else{"White"})
}
############################

$ErrorActionPreference = "Stop"

$success = 0
$failed = 0

$RunspaceSize = $SQL.Count

Out-Message -Msg ("=" * 50)
Out-Message "Script Settings:"
Out-Message ("Connection Timeout:[{0}] / Runspace Size:[{1}]" -f $ConnectionTimeout,$RunspaceSize)
Out-Message -Msg ("=" * 50)

$sw = [system.diagnostics.stopwatch]::startNew()

$constring = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$constring["Data Source"] = $ServerInstance
$constring["User Id"] = $Username
$constring["Password"] = $Password
$constring["Connect Timeout"] = $ConnectionTimeout
if ($DisableConnectionPool){
    $constring["Pooling"] = $false
}



try{
    $minpoolsize = $maxpoolsize = $RunspaceSize
    $runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize)
    $runspacePool.Open()

    $Command = {
        Param(
            [System.Data.SqlClient.SqlConnectionStringBuilder]$constring,
            [PSCustomObject]$sql
        )
        try{
            $orgErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $constring["Initial Catalog"] = $sql.Database
            $con = New-Object System.Data.SqlClient.SqlConnection
            $con.ConnectionString = $constring

            $con.Open()

            if ($sql.IsDataSet -ne $True){
                $cmd = $con.CreateCommand()
                if($sql.CommandTimeout -ne $null){
                    $cmd.CommandTimeout = $sql.CommandTimeout
                }
                
                $cmd.CommandText = $sql.Text
            
                [void]$cmd.ExecuteNonQuery()
            
                $cmd.Dispose()
            }else{
                $da = New-Object System.Data.SqlClient.SqlDataAdapter -ArgumentList $sql.Text, $con
                $ds = New-Object System.Data.DataSet
                $da.Fill($ds)
                $ds.Tables[0] | Out-GridView
                $ds.Dispose()
                $da.Dispose()
            }
            Write-Output ("Query Complete [{0}] " -f $sql.Text)
        }catch{
            return $Error[0]
        }finally{
            if($con -ne $null){
                $con.Close()
                $con.Dispose()
            }

            $ErrorActionPreference = $orgErrorActionPreference
        }
    }
    $RunspaceCollection  = New-Object System.Collections.ArrayList
    $Result = New-Object System.Collections.ArrayList
    
    $cnt = 1
    foreach ($Source in $SQL){
        if ($UniqueAppName){
            $constring["Application Name"] = ([GUID]::NewGuid()).ToString()
        }

        $powershell = [PowerShell]::Create().AddScript($Command).AddArgument($constring).AddArgument($Source)
        $powershell.RunspacePool = $runspacePool
        [void]$RunspaceCollection.Add([PSCustomObject] @{
            QueryNo = $cnt
            Runspace = $powershell.BeginInvoke();
            PowerShell = $powershell
            StartTime = Get-Date
            SQL = $Source.text
        })
        Out-Message -Msg ("Start [#{0}] : {1}" -f $cnt++, $Source.text)
    }

    # 処理完了の待機
    while($RunspaceCollection){
        foreach($runspace in $RunspaceCollection){
            if ($runspace.Runspace.IsCompleted){
                $ret = $runspace.powershell.EndInvoke($runspace.Runspace)
                $runspace.PowerShell.Dispose()

                if (($ret | Get-Member).TypeName[0] -eq [System.Management.Automation.ErrorRecord]){
                    Out-Message -Msg ("Error [#{0}] : [Start Time : {1} / Execution Time : {2}]" -f $runspace.QueryNo, $runspace.StartTime, ((Get-Date) - $runspace.StartTime).TotalSeconds) -Error
                    Out-Message -Msg $ret.Exception.GetBaseException()  -Error
                    $failed +=1
                }else{
                    Out-Message -Msg ("Success [#{0}] : [Start Time : {1} / Execution Time : {2}]" -f $runspace.QueryNo, $runspace.StartTime, ((Get-Date) - $runspace.StartTime).TotalSeconds) -Info
                    $success +=1
                }
                [void]$Result.Add($ret)
                $RunspaceCollection.Remove($runspace)
                break
            }
        }
        Start-Sleep -Milliseconds 5
    }

}catch{
  Write-Output $Error[0]
}finally{
    if ($runspacePool -ne $null){
        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}


$sw.Stop()

Out-Message -Msg ("=" * 50)
Out-Message -Msg ("Total execution time (sec) : [{0}]" -f $sw.Elapsed.TotalSeconds)
Out-Message -Msg ("[Result] Success : [{0}] / Failed : [{1}]" -f $success, $failed)
Out-Message -Msg ("=" * 50)
