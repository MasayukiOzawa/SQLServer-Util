using namespace Microsoft.Data.SqlClient
using namespace System.Diagnostics

Add-Type -Path C:\PackageDLL\Microsoft.Data.SqlClient.dll

$elapsedTime = 0
$cpuTime = 0

$totalCpuTime = 0
$totalElapsedTime = 0
$totalProcTime = 0

$conString_japan = "Data Source=xxxxxx.database.windows.net;User Id=xxxxx;Password=xxxxxx;Initial Catalog=DB01"
$conString_us = "Data Source=xxxxxx.database.windows.net;User Id=sxxxxxx;Password=xxxxxx;Initial Catalog=DB01"

$handler = [SqlInfoMessageEventHandler]{
    param(
    $sender,
    $event
    )
    $con.FireInfoMessageEventOnUserErrors = $false
    if($event.errors.class -gt 0){
        Write-Host ("Error : {0}" -f $event.errors.Message) -ForegroundColor Red
    }else{
        $lines = $event.Message -split "`n"
        $cnt = 0
        foreach($line in $lines){
            if ($line -like "*実行時間*" -or $line -like "*Execution Time*"){
                $reg = [System.Text.RegularExpressions.Regex]::new('.*CPU time = (?<cpu>.*?) ms,  elapsed time = (?<elapsed>.*?) ms.')
                $ret = $reg.Match($lines[$cnt+1])
                $global:cpuTime = [int]$ret.Groups["cpu"].Value 
                $global:elapsedTime = [int]$ret.Groups["elapsed"].Value 
                $global:totalCpuTime += [int]$ret.Groups["cpu"].Value 
                $global:totalElapsedTime += [int]$ret.Groups["elapsed"].Value 
            }
            $cnt ++
        }
    }
}

function Test-SqlLateyncy($conString, $location){
    $global:totalElapsedTime = 0
    $global:totalProcTime = 0
    
    $con = New-Object SqlConnection -ArgumentList $conString
    $con.FireInfoMessageEventOnUserErrors = $true
    
    $con.Open()
    $con.add_InfoMessage($handler)
    
    $cmd = $con.CreateCommand()
    $cmd.CommandText = "SET STATISTICS TIME ON;"
    [void]$cmd.ExecuteNonQuery()
    $cmd.CommandText = "INSERT INTO INSTEST VALUES(1)"
    
    Write-host "$location Test Start."
    $sw = [Stopwatch]::StartNew()
    1..10 | ForEach-Object {
        $sw.Start()
        [void]$cmd.ExecuteNonQuery()
        $sw.Stop()
        Write-Host ("{0:0##} : CPU Time : {1} ms , Elapsed TIme : {2} ms , Execution Time : {3} ms" -f $_, $cpuTime, $elapsedTime, $sw.ElapsedMilliseconds)
        $totalProcTime += $sw.ElapsedMilliseconds
        $sw.Reset()
    }
    Write-Host ("Total Query Elapsed Time : $totalElapsedTime ms")
    Write-Host ("Total Proc Elapsed Time : $totalProcTime ms")
    
    $con.Close()
    $con.Dispose()
    [SqlConnection]::ClearAllPools()
    Write-host "$location Test End.`n"
}

Test-SqlLateyncy $conString_japan "Japan East"
Test-SqlLateyncy $conString_us "US East"