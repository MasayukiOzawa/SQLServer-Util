$SourceConnectionString = "Data Source=.;Integrated Security=SSPI;Application Name=CDC Replay;Database=CDC"
$DestConnectionString = "Data Source=.;Integrated Security=SSPI;Application Name=CDC Replay;Database=CDC"

$CaptureInstance = "history_Capture"
$DestTable = "dbo.history_cdc"

$QueryGetLsn = @"
SELECT 
    start_lsn, sys.fn_cdc_get_max_lsn() AS max_lsn
FROM 
    cdc.change_tables AS ct
WHERE
    ct.capture_instance = '{0}';
"@

$queryChangeCapture = @"
SELECT 
    *,
    CASE __`$operation
        WHEN 1 THEN 'D'
        WHEN 2 THEN 'I'
        WHEN 3 THEN 'U_Old'
        WHEN 4 THEN 'U'
        ELSE NULL
    END AS operation
FROM 
	cdc.fn_cdc_get_all_changes_{0}({1}, {2}, 'all update old')
ORDER BY
	__`$start_lsn ASC,
    __`$seqval ASC
"@

<#
DROP TABLE IF EXISTS StateTBL
CREATE TABLE StateTBL
(
    CaptureInstance varchar(255) PRIMARY KEY,
    Lsn varbinary(10)
)
#>

$queryGetState = @"
SELECT CaptureInstance, sys.fn_cdc_increment_lsn(Lsn) AS NextLSN FROM StateTBL WHERE CaptureInstance = '{0}'
"@

function Convert-Bin2Hex() {
    param(
        [byte[]]$bin
    )
    $sb = New-Object System.Text.StringBuilder
    foreach ($tmp in $bin) {
        [void]$sb.Append($tmp.ToString("X2"))
    }
    return ("0x" + $sb.ToString())
}

function New-SelectCommand() {
    param(
        $SelectCommand,
        $Connection
    )
    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.CommandText = $SelectCommand
    $cmd.CommandType = [System.Data.CommandType]::Text
    $cmd.Connection = $Connection
    return $cmd
}

function New-Connection() {
    param(
        $ConnectionString
    )
    $con = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
    return $con
}
function Get-ColumnValue() {
    param(
        [System.Data.DataRow]$row ,
        $column
    )
    $retValue = ""
    if ( $row[$Column] -eq [System.DBNull]::Value) {
        $retValue = "NULL"
    }
    else {
        switch ($row[$Column].GetType().Name) {
            { @("Int32", "Int64", "Double" , "Decimal") -contains $_ } {
                $retValue = "{0}" -f $row[$Column]
            }
            "DateTime" {
                $retValue = "'{0}'" -f $row[$Column].ToString("yyyy/MM/dd HH:mm:ss.fff")
            }
            Default {
                $retValue = "'{0}'" -f $row[$Column]
            }
        }
    }
    return $retValue
}
function Invoke-CdcInsert {
    param(
        $row,
        $Table,
        [System.Data.SqlClient.SqlConnection]$Connection
    )
    $columns = New-Object System.Collections.ArrayList
    $values = New-Object System.Collections.ArrayList
    $columnList = $row | Get-Member -MemberType Properties | Where-Object Name -NotMatch "`_`_`$*" | Where-Object  Name -ne "operation"
    foreach ($column in $columnList) {
        [void]$columns.Add($column.Name)
        [void]$values.Add((Get-ColumnValue -row $row -column $column.Name))
    }
    
    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = ("INSERT INTO {0} ({1}) VALUES ({2})" -f $Table , ($columns -join ","), ($values -join ","))
    [void]$cmd.ExecuteNonQuery()
}

function Invoke-CdcDelete() {
    param(
        $row,
        $Table,
        [System.Data.SqlClient.SqlConnection]$Connection
    )
    $columns = New-Object System.Collections.ArrayList
    $values = New-Object System.Collections.ArrayList
    $columnList = $row | Get-Member -MemberType Properties | Where-Object Name -NotMatch "`_`_`$*" | Where-Object  Name -ne "operation"
    foreach ($column in $columnList) {
        [void]$columns.Add($column.Name)
        [void]$values.Add((Get-ColumnValue -row $row -column $column.Name))
    }
    $deleteCondition = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $columns.count; $i++) {
        if ( "NULL" -eq $values[$i]) {
            [void]$deleteCondition.Append((" AND {0} IS {1}" -f $columns[$i], $values[$i])) 
        }
        else {
            [void]$deleteCondition.Append((" AND {0} = {1}" -f $columns[$i], $values[$i]))
        }

    }
    if ($null -ne $columnList) {
        $cmd = $Connection.CreateCommand()
        $cmd.CommandText = ("DELETE FROM {0} WHERE 1=1 {1}" -f $Table , $deleteCondition.ToString())
        [void]$cmd.ExecuteNonQuery()    
    }
}

#############################################################################
$sw = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host ("{0} : Start capture replay." -f (Get-Date -Format "G"))
$SourceConnection = New-Connection -ConnectionString $SourceConnectionString
$SourceConnection.Open()

# 処理の状態 (以前の処理の LSN) を取得
$cmd = $SourceConnection.CreateCommand()
$cmd.CommandText = ($queryGetState -f $CaptureInstance)
$reader = $cmd.ExecuteReader()

if ($reader.HasRows -eq $false) {
    $reader.Close()
    $state_lsn = $null
    # StateTBL にレコードが存在しない場合は、LSN を 0 でレコードを生成
    $cmd.CommandText = ("INSERT INTO StateTBL VALUES ('{0}', {1})" -f $CaptureInstance, (Convert-Bin2Hex(0x0)))
    [void]$cmd.ExecuteNonQuery()
}
else {
    [void]$reader.Read()
    $state_lsn = $reader["NextLsn"]
    $reader.Close()
}

# 処理対象のキャプチャデータの LSN の取得
$da = New-Object System.Data.SqlClient.SqlDataAdapter
$da.SelectCommand = New-SelectCommand -SelectCommand ($QueryGetLsn -f $CaptureInstance) -Connection $SourceConnection
$targetLsn = New-Object System.Data.DataTable
[void]$da.Fill($targetLsn)

if ($null -eq $state_lsn) {
    $start_lsn = Convert-Bin2Hex($targetLsn.Rows[0].start_lsn)
}
else {
    $start_lsn = Convert-Bin2Hex($state_lsn)
}
$max_lsn = Convert-Bin2Hex($targetLsn.Rows[0].max_lsn)

Write-Host ("Start LSN : {0} / End LSN : {1}" -f $start_lsn, $max_lsn)

# LSN から変更対象データを取得 (前回再生後にデータの追加あるかを確認)
if ($start_lsn -lt $max_lsn) {
    $ChangeCapture = New-Object System.Data.DataTable
    $da.SelectCommand = New-SelectCommand `
        -SelectCommand ($queryChangeCapture -f $CaptureInstance, $start_lsn, $max_lsn) `
        -Connection $SourceConnection
    $CaptureCount = $da.Fill($ChangeCapture)
    $da.SelectCommand.CommandText | clip.exe
}

$cnt = 0
# 取得したデータをもとに、送信先テーブルで再生 (本サンプルの UPDATE は 旧データを DELETE し、新データを INSERT することで実現)
if ($CaptureCount -gt 0) {
    Write-Host ("Total Capture Data : {0}" -f $CaptureCount)
    $destConnection = New-Connection -ConnectionString $DestConnectionString
    $destConnection.Open()
    
    foreach ($row in $ChangeCapture.Rows) {
        switch ($row["operation"]) {
            "D" { Invoke-CdcDelete -row $row -Connection $destConnection -Table $DestTable }
            "I" { Invoke-CdcInsert -row $row -Connection $destConnection -Table $DestTable }
            "U_Old" { Invoke-CdcDelete -row $row -Connection $destConnection -Table $DestTable }
            "U" { Invoke-CdcInsert -row $row -Connection $destConnection -Table $DestTable }
            Default { }
        }    
        if ((++$cnt % 1000) -eq 0) {
            Write-Host ("{0} : {1} rows processed." -f (Get-Date -Format "G"), $cnt)
        }
    }
    # 次回の処理のため、最後の LSN を保持しておく
    $last_lsn = Convert-Bin2Hex($row.'__$start_lsn')
    $destConnection.Close()
    $destConnection.Dispose()

    # LSN の更新 (取得時に LSN をインクリメントしているため、最後の LSN を単純に設定)
    $cmd.CommandText = ("UPDATE StateTBL SET Lsn={0} WHERE CaptureInstance='{1}'" -f $last_lsn, $CaptureInstance)
    [void]$cmd.ExecuteNonQuery()
}
else {
    Write-Host "Capture Data Not Found."
}

$SourceConnection.Close()
$SourceConnection.Dispose()

Write-Host ("{0} : End capture replay." -f (Get-Date -Format "G"))
$sw.Stop()
Write-Host ("Elapsed Time : {0}" -f $sw.Elapsed)