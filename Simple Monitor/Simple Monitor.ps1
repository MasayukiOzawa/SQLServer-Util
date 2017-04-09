[CmdletBinding()]
param(
    $server = "",
    $user = "",
    $password = "",
    $outputdir = "C:\Simple Monitor",
    $database = "",
    $interval = 5,
    $isAzure = $false
)
$ErrorActionPreference = "Continue"

Clear-Host

Write-Output "Press Ctrl+C to exit."

# PS1 と同じディレクトリ内の SQL ファイルを実行する
# Box と SQL Database でし応するクエリが異なる場合、Box or Azure のファイル名で使い分ける
if($isAzure){
    $sqllist = Get-ChildItem -Path (Split-Path $MyInvocation.MyCommand.Path -Parent) | ? Name -Match "^[0-9].*sql" | ? Name -NotLike "*Box*"
}else{
    $sqllist = Get-ChildItem -Path (Split-Path $MyInvocation.MyCommand.Path -Parent) | ? Name -Match "^[0-9].*sql" | ? Name -NotLike "*Azure*"
}


$outfilepath = (Join-Path $outputdir (Get-Date).ToString("yyyyMMdd"))
if (-not (Test-Path $outfilepath)){
    New-Item -Path $outfilepath -ItemType Directory | Out-Null
}
if (-not (Test-Path (Join-Path $outputdir "Results"))){
    New-Item -Path (Join-Path $outputdir "Results") -ItemType Directory | Out-Null
}

if (-not[String]::IsNullOrEmpty($user)){
    $param = @{
        UserName = $user
        Password = $password
    }
}else{
    $param = @{}
}
while($true){
    foreach($sqlfile in $sqllist){
        try{
            $outfile = ($sqlfile.BaseName -split "_")[0] + ".txt"
            Invoke-Sqlcmd -ServerInstance $server @param -Database $database -InputFile $sqlfile.FullName | Export-Csv -Path (Join-Path $outfilepath $outfile) -NoTypeInformation -Append -Force

            # PBI Desktop でオリジナルのファイルを読み込むと、ファイルロックしてしまうことがあるので、二次ディレクトリに退避し、PBI Desktop ではそちらにアクセス
            Copy-Item (Join-Path $outfilepath $outfile) (Join-Path $outputdir "Results") -Force
        }catch{
            Write-Host ("{0}:{1}"-f (Get-Date),$Error[0].Exception.Message)
        }
    }

    Start-Sleep -Seconds $interval
}