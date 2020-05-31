Set-Location "C:\Program Files\Microsoft Corporation\RMLUtils"
$loopCount = 10

$cmd = @"
.\ostress.exe --% -Slocalhost -E -dPubDB -Q"INSERT INTO ChangeTrackingTBL (C2, C3) VALUES({0}, NEWID())" -n100 -r100 -q | select-string "elapsed time"
"@
$results = New-Object System.Collections.ArrayList

1..$loopCount | ForEach-Object{
    $ret = Invoke-Expression -Command ($cmd -f $_)
    
    if (($ret -split " ") -eq "ms"){
        [void]$results.Add([timespan]::new(0,0,0,0,($ret -split " ")[-2]))
        Write-Host ("{0:00#} : {1} ms" -f $_, ($ret -split " ")[-2])
    } else{
        [void]$results.Add([timespan]($ret -split " ")[-1])
        Write-Host ("{0:00#} : {1} sec" -f $_, ($ret -split " ")[-1])
    }
}

$result = ($results.TotalMilliseconds | Measure-Object -Sum -Average)
Write-Host ("Average : {0:#,##0.00} ms / Total {1:#,##0.00} ms" -f $result.Average, $result.Sum)