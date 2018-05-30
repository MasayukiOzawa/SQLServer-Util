# http://tech.guitarrapc.com/entry/2013/10/29/100946
# https://www.gmo.jp/report/single/?art_id=195
# https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/26/beginning-use-of-powershell-runspaces-part-1/
function Start-AsyncSQLQueryTest(){
    [CmdletBinding()]
    param
    (
        [string]$ConnectionString,
        [string]$Query,
        [int]$RunspaceSize,
        [int]$CommandTimeout = 30
    )
    Write-Output ("[{0}] Start" -f (Get-Date))
    try{
        $Command = {
            [CmdletBinding()]
            param(
                [string]$ConnectionString,
                [string]$Query,
                [int]$CommandTimeout
            )
            try{
                $con = New-Object System.Data.SqlClient.SqlConnection
                $con.ConnectionString = $ConnectionString
                $con.Open()
                $cmd = $con.CreateCommand()
                $cmd.CommandType = [System.Data.CommandType]::Text
                $cmd.CommandText = $Query
                $cmd.CommandTimeout = $CommandTimeout
                $cmd.ExecuteNonQuery() > $null
                Write-Output "Success"
            }catch{
                Write-Output $Error[0]
            }finally{
                if ($con){
                    $con.Close()
                    $con.Dispose()
                }
            }
        }

        $minpoolsize = $maxpoolsize = $RunspaceSize
        $runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize)
        $runspacePool.ApartmentState = "STA"
        $runspacePool.Open()

        $aryPowerShell  = New-Object System.Collections.ArrayList 
        $aryIAsyncResult  = New-Object System.Collections.ArrayList 
        for ( $i = 0; $i -lt $RunspaceSize; $i++ )   
        {       
            $powershell = [PowerShell]::Create().AddScript($Command).AddArgument($ConnectionString).AddArgument($Query).AddArgument($CommandTimeout)
            $powershell.RunspacePool = $runspacePool  
            [array]$RunspaceCollection += New-Object -TypeName PSObject -Property @{
                Runspace = $powershell.BeginInvoke();
                powershell = $powershell
            }
        }     
        while (($RunspaceCollection.Runspace | sort IsCompleted -Unique).IsCompleted -ne $true)
        {
            sleep -Milliseconds 5
        }
        foreach ($runspace in $runspaceCollection)
        {
            $result += $runspace.powershell.EndInvoke($runspace.Runspace)
            $runspace.powershell.Dispose()
        }
    }catch{
        Write-Output $Error[0]
    }finally{
        $runspacePool.Dispose()
        $result | Group-Object | Select Count, Name
    }
    Write-Output ("[{0}] End" -f (Get-Date))
}

$Param = @{
    ConnectionString = "Data Source=localhost;Integrated Security=true;Pooling=True;Connection Timeout=15;Application Name=AsyncSQLQueryTest" 
    Query = "WAITFOR DELAY '00:00:30'" 
    RunspaceSize = 120
    CommandTimeout = 60
}

$sw = [system.diagnostics.stopwatch]::startNew()
1..1 | %{Start-AsyncSQLQueryTest @Param}
$sw | fl
$sw.Stop()

[System.Data.SqlClient.SqlConnection]::ClearAllPools()
