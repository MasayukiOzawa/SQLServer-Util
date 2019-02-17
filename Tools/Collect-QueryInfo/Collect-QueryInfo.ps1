$ErrorActionPreference = "Stop"

Clear-Host
$collectFilePath = ".\"

$collectTableList = @("00_Indexstats", "01_BatchResp", "02_WaitStats")
$collectIntervalList = @(60, 30, 60)


$collectFileList = Get-ChildItem -Recurse -Path $collectFilePath | Where-Object Name -eq "Collect.sql" | Sort-Object DirectoryName

$script = {
    $CollectTable = $args[0]
    $collectSql = Get-Content -Path $args[1] -Raw

    $dropExists = $false
    $interval = $args[2]
    $cmdTimeout = 30

    $srcCon_string = "Server=tcp:localhost;Integrated Security=SSPI;Initial Catalog=tpch;APP=Collect-QueryInfo"
    $destCon_string = "Server=tcp:localhost;Integrated Security=SSPI;Initial Catalog=CollectData;APP=Collect-QueryInfo"

    $dropTBLSql = @"
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = '{0}')
BEGIN
	DROP TABLE [{0}]
END;
"@.Replace("{0}", $collectTable)

    $createTBLSql = @"
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = '{0}')
BEGIN
CREATE TABLE [{0}] 
(
    {1}
,INDEX CIX_{0} CLUSTERED(collect_date, server_name) WITH(DATA_COMPRESSION=PAGE)
)
END
"@.Replace("{0}", $collectTable)

    # Connection Open
    $srcCon = New-Object System.Data.SqlClient.SqlConnection
    $srcCon.ConnectionString = $srcCon_string
    $srcCon.Open()

    $destCon = New-Object System.Data.SqlClient.SqlConnection
    $destCon.ConnectionString = $destCon_string
    $destCon.Open()

    # データ格納用のテーブルのスキーマ作成
    $cmd = $srcCon.CreateCommand()
    $cmd.CommandTimeout = $cmdTimeout
    $cmd.CommandText = "sp_describe_first_result_set"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $cmd.Parameters.Add("@tsql", [System.Data.SqlDbType]::NVarChar, -1) | Out-Null
    $cmd.Parameters["@tsql"].Value = $collectSql

    $da = New-Object System.Data.SqlClient.SqlDataAdapter -ArgumentList $cmd
    $descTable = New-Object System.Data.DataTable
    $recCount = $da.Fill($descTable)

    $stringBuilder = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $recCount; $i++) {
        $stringBuilder.Append($("{0} {1}" -f $descTable.Rows[$i].name, $descTable.Rows[$i].system_type_name)) | Out-Null
        if ($i -lt $recCount - 1) {
            $stringBuilder.Append(",`n")  | Out-Null
        }
    }

    # 情報格納用のテーブルを作成
    $ddl = $createTBLSql.Replace("{1}", $stringBuilder.ToString())

    $cmd = $destCon.CreateCommand()
    $cmd.CommandTimeout = $cmdTimeout
    $cmd.CommandType = [System.Data.CommandType]::Text
    if ($dropExists -eq $true) {
        $cmd.CommandText = $dropTBLSql + $ddl	
    }
    else {
        $cmd.CommandText = $ddl	
    }
    try {
        $cmd.ExecuteNonQuery() | Out-Null
    }
    catch {
        Write-Host $_.Exception
    }

    $retData = New-Object System.Data.SqlClient.SqlDataAdapter -ArgumentList $collectSql, $srcCon
    $ds = New-Object System.Data.DataSet
    $retData.Fill($ds, "dmv_perf") | Out-Null

    # 情報の取得と格納
    $cmd = $srcCon.CreateCommand()
    $cmd.CommandTimeout = $cmdTimeout
    $cmd.CommandType = [System.Data.CommandType]::Text
    $cmd.CommandText = $collectSql
    $da = New-Object System.Data.SqlClient.SqlDataAdapter
    $da.SelectCommand = $cmd
    $dt = New-Object System.Data.DataTable
    $bc = New-Object System.Data.SqlClient.SqlBulkCopy -ArgumentList $destCon
    $bc.DestinationTableName = "[{0}]" -f $collectTable

    while ($true) {
        try {
            [void]$da.Fill($dt)
            $bc.WriteToServer($dt)
            $dt.Clear()
            Write-Host ("{0} {1} Collected." -f (Get-Date), $args[0])
        }
        catch {
            Write-Host $_.Exception
        }
        Start-Sleep -Seconds $interval
    }

    # オブジェクト解放
    $srcCon.Close()
    $srcCon = $null

    $destCon.Close()
    $destCon = $null
}

$jobAry = @()
for ($i = 0; $i -lt $collectTableList.Length; $i++) {
    Write-Host ("{0} {1} {2}" -f  
        $collectTableList[$i], 
        $collectFileList[$i].FullName,
        $collectIntervalList[$i]
    )
    $jobAry += Start-Job -ScriptBlock $script -ArgumentList $collectTableList[$i], $collectFileList[$i].FullName, $collectIntervalList[$i]
}

$jobAry | Get-Job
Start-Sleep -Seconds 10
Get-Job | Receive-Job

while($true){
    Get-Job | Receive-Job
    Start-Sleep -Seconds 10
}

<#
Get-Job | Receive-Job
Get-Job | Stop-Job
Get-Job | Remove-Job
#>