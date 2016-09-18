# https://sveroa.com/2014/05/06/perfmon-create-collector-set-with-powershell/

Param(
  [string]$name = "MyCollectorSet",
  [int]$interval = 15,
  [string]$path = "%systemdrive%\PerfLogs\",
  [parameter(mandatory=$true)]
  [string]$CounterFile,
  [string]$Instance,
  [switch]$Start
)

# Data Collector Set の設定
$datacollectorset = New-Object -COM Pla.DataCollectorSet
$datacollectorset.DisplayName = $name
# $datacollectorset.Duration = 50400 # 全体の期間
$datacollectorset.SubdirectoryFormat = 1 
$datacollectorset.SubdirectoryFormatPattern = "yyyyMMdd\-NNNNNN"
$datacollectorset.RootPath = (Join-Path $path $name)

# データコレクターの設定
$DataCollector = $datacollectorset.DataCollectors.CreateDataCollector(0) 
$DataCollector.FileName = $name
$DataCollector.FileNameFormat = 0x1 
# $DataCollector.FileNameFormatPattern = "yyyy\-MM\-dd"
$DataCollector.SampleInterval = $interval
$DataCollector.LogAppend = $true

# カウンターの設定

if($Instance){
    $counters = ((Get-Content $counterfile) -replace "SQLServer:", "MSSQL`$$($Instance):" | ConvertFrom-Json)
}else{
    $counters = (Get-Content $counterfile | ConvertFrom-Json)
}

$DataCollector.PerformanceCounters = $counters.CounterName

# スケジュールの設定
<#
$StartDate = [DateTime]('2013-01-01 06:00:00')
$NewSchedule = $datacollectorset.schedules.CreateSchedule()
$NewSchedule.Days = 127
$NewSchedule.StartDate = $StartDate
$NewSchedule.StartTime = $StartDate
#>


try
{
    # $datacollectorset.schedules.Add($NewSchedule)
    $datacollectorset.DataCollectors.Add($DataCollector) 
    $datacollectorset.Commit("$name" , $null , 0x0003) | Out-Null
    if($start){
        $datacollectorset.start($false)
    }
}
catch [Exception] 
{ 
    Write-Host "Exception Caught: " $_.Exception -ForegroundColor Red 
    return 
} 