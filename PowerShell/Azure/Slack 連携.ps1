[CmdletBinding()] 
Param(
    [String]$TargetDB = $ENV:SQLAZURECONNSTR_DestinationDB,
    [String]$APIURI = $ENV:SlackApiUri,
    [String]$Channel = "sqlmonitor"
)
$ErrorActionPreference = "Stop"

$sql = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MasayukiOzawa/MonitorDB/master/02.Regular%20Execution/03.Data%20Usage%20Check.sql" -UseBasicParsing).Content

# https://github.com/PowerShell/PowerShell/issues/5007
# http://robertwesterlund.net/post/2014/12/27/removing-utf8-bom-using-powershell
[byte[]]$UTF8BOM = 0xEF, 0xBB, 0xBF

# BOM 付きの場合、クエリ実行時にエラーとなるため、BOM を取り除く
if((Compare-Object $UTF8BOM ([System.Text.Encoding]::UTF8.GetBytes($sql))[0..2] -PassThru) -eq $null){
    [byte[]]$bytes = ([System.Text.Encoding]::UTF8.GetBytes($sql))[3..([System.Text.Encoding]::UTF8.GetByteCount($sql))]
    $sql = [System.Text.Encoding]::UTF8.GetString($bytes)
}


$SourceConnection = New-Object System.Data.SqlClient.SqlConnection
$SourceConnection.ConnectionString = $TargetDB
$SourceConnection.Open()

$cmd = $SourceConnection.CreateCommand()
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.CommandText = $sql

$Adapter = New-Object System.Data.SqlClient.SqlDataAdapter -ArgumentList $cmd
$DataSet = New-Object System.Data.DataSet
$Adapter.Fill($DataSet)

$SourceConnection.Close()
$SourceConnection.Dispose()

# $Msg = "object_name | index_name | row_count | reserved_page_size_KB | used_page_size_KB | avg_row_size_bytes`n"
$TotalReservedPages = 0
$Fields = @()
foreach($Row in $DataSet.Tables[0].Rows){
    $Fields += @{
        title=("{0}" -f $Row.object_name)
        value=("*{0}* `nrow_count : {1:#,##0}`nreserved_page_size_KB : {2:#,##0}`nused_page_size_KB : {3:#,##0}`n avg_row_size_bytes: {4:#,##0}`n========" -f $Row.index_name, $Row.row_count, $Row.reserved_page_size_KB, $Row.used_page_size_KB, $Row.avg_row_size_bytes)
        short="true"

    }
    $TotalReservedPages += $Row.reserved_page_size_KB
}
$Msg =　"合計で *{0:#,##0} MB* 使用しています。" -f ($TotalReservedPages / 1024)

$DataSet.Dispose()
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($Msg)

$Payload = @{
    channel = $Channel
    username = "Database Usage"
    text =[System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($utf8Bytes)
    fields = $Fields
}

Invoke-WebRequest -Uri $APIURI -Method Post -Body ($Payload | ConvertTo-Json) -UseBasicParsing