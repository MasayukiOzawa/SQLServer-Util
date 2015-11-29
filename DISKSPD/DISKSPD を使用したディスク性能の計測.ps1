# https://github.com/microsoft/diskspd

$Results = New-Object -TypeName System.Collections.Generic.List[PSCustomObject]
$aryBlockSize = @("4K", "8K", "64K", "128K", "256K")
$aryThread = @(1,2,8,16)
$aryPattern = @("si", "r")
$duration = 60


$TestFile = "E:\test.dat"
$DiskSpd = "C:\Diskspd-v2.0.15\amd64fre\diskspd.exe"
$BaseCmd = "$DiskSpd -c10G -b{0} -o1 -h -t{1} -{2} {3} -Rxml -d{4} $TestFile"

$Output = "C:\Result"
$Logfile = Join-Path $Output "result.txt"
if((Test-Path $Output) -eq $false){ New-Item -ItemType directory -Path $Output}

$Result = New-object -TypeName PSCustomObject | select Datetime,Path, Duration,ThreadCount,Pattern, BlockSize,ReadMBytes_sec,ReadCount_sec,WriteMBytes_sec,WriteCount_sec,ReadCmd,WriteCmd

foreach($BlockSize in $aryBlockSize){
    foreach($Thread in $aryThread){
        foreach($Pattern in $aryPattern){
            if ($Thread -eq 1 -and $Pattern -eq "si"){$Pattern = "s"}
            Write-Output ($BaseCmd -f $BlockSize, "$thread", $Pattern, "", $duration)

            # Read の測定
            [xml]$xml = Invoke-Expression ($BaseCmd -f $BlockSize, "$thread", $Pattern, "", $duration)

            # Read の測定結果を格納
            $Result.Datetime = Get-Date -Format G
            $Result.Path = $TestFile
            $Result.Duration = $xml.Results.Profile.TimeSpans.TimeSpan.Duration
            $Result.ThreadCount = $xml.Results.TimeSpan.ThreadCount
            $Result.Pattern = Switch($Pattern){
                            {"s","si" -contains $_} {"Sequential"}
                            "r"{"Random"}}
            $Result.BlockSize = $xml.Results.Profile.TimeSpans.TimeSpan.Targets.Target.BlockSize
            $Result.ReadMBytes_sec = [int64](($xml.Results.TimeSpan.Thread.Target.ReadBytes | Measure-Object -Sum).Sum / $xml.Results.TimeSpan.TestTimeSeconds / [math]::Pow(1024,2))
            $Result.ReadCount_sec = [int64](($xml.Results.TimeSpan.Thread.Target.ReadCount| Measure-Object -Sum).Sum / $xml.Results.TimeSpan.TestTimeSeconds)
            $Result.WriteMBytes_sec = 0
            $Result.WriteCount_sec = 0
            $Result.ReadCmd = $BaseCmd -f $BlockSize, "$thread", $Pattern, "", $duration
            
            Write-Output ($BaseCmd -f $BlockSize, "$thread", $Pattern, "-w100", $duration)

            # Write の測定
            $xml = Invoke-Expression ($BaseCmd -f $BlockSize, "$thread", $Pattern, "-w100", $duration)

            # Write の測定結果を格納
            $Result.WriteMBytes_sec = [int64](($xml.Results.TimeSpan.Thread.Target.WriteBytes | Measure-Object -Sum).Sum / $xml.Results.TimeSpan.TestTimeSeconds / [math]::Pow(1024,2))
            $Result.WriteCount_sec = [int64](($xml.Results.TimeSpan.Thread.Target.WriteCount | Measure-Object -Sum).Sum / $xml.Results.TimeSpan.TestTimeSeconds)
            $Result.WriteCmd = $BaseCmd -f $BlockSize, "$thread", $Pattern, "-w100", $duration

            $Result | Export-CSV -Encoding Unicode -Path $Logfile -Append -NoTypeInformation
            Write-Output $Results | ft
            $Results.Add($Result.psobject.copy()) > $null
        }
    }
}

$Results | Out-GridView -Title "DiskSpd Result"

