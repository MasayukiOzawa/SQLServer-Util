# DataSet

$constring = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$constring.psbase.DataSource = "."
$constring.psbase.InitialCatalog = "tempdb"
$constring.psbase.IntegratedSecurity = $true

$con = New-Object System.Data.SqlClient.SqlConnection

$con.ConnectionString = $constring
$con.Open()

# SELECT
$cmd = $con.CreateCommand()
$cmd.CommandText = "SELECT object_id, name FROM sys.objects where object_id < 100"

$da = New-Object System.Data.SqlClient.SqlDataAdapter
$da.SelectCommand = $cmd

$ds = New-Object System.Data.DataSet
$count = $da.Fill($ds)

foreach($row in $ds.tables[0].Rows){
    $row
}

Write-Output $count

# 関数からの Fill の呼び出し
function Get-FillData([System.Data.SqlClient.SqlConnection]$connection){
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT object_id, name FROM sys.objects where object_id < 100"

    $da = New-Object System.Data.SqlClient.SqlDataAdapter
    $da.SelectCommand = $cmd

    $ds = New-Object System.Data.DataSet
    # 取得した件数を呼び出し側に返さないように[void]を設定
    [void]$da.Fill($ds)
    # コレクションの型を維持
    return ,$ds
    # $ds.tables | Select-Object -ExcludeProperty Rows
}

$ret = Get-FillData($con)
$ret.GetType()

$ret = @(Get-FillData($con))
$ret.GetType()

# [void]をいつも忘れる
# http://d.hatena.ne.jp/ps1/20081119/p1
# PowerShell データベースから取得した値(DataRow)でハマった
# https://hinokinobou.wordpress.com/2013/12/20/powershell-%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E3%81%8B%E3%82%89%E5%8F%96%E5%BE%97%E3%81%97%E3%81%9F%E5%80%A4datarow%E3%81%A7%E3%83%8F%E3%83%9E%E3%81%A3%E3%81%9F/
# PowerShell] 関数でコレクションのインスタンスを返り値とする場合にコレクションの型を維持させる
# http://www.pine4.net/Memo/Article/Archives/203

function Get-FillData([System.Data.SqlClient.SqlConnection]$connection){
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT object_id, name FROM sys.objects where object_id = 3"

    $da = New-Object System.Data.SqlClient.SqlDataAdapter
    $da.SelectCommand = $cmd

    $dt = New-Object System.Data.DataTable
    # 取得した件数を呼び出し側に返さないように[void]を設定
    [void]$da.Fill($dt)
    # コレクションの型を維持
    return ,$dt
    return $dt
}

$ret = Get-FillData($con)
$ret.GetType()

$ret = @(Get-FillData($con))
$ret.GetType()


# Bulk Copy (CSV)
# https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd
<#
DROP TABLE IF EXISTS BulkTest;CREATE TABLE BulkTest (Col1 int, Col2 nvarchar(255))
#>

$source = ConvertFrom-Csv @(("1,ABC"),("2,あいうえお"),("3,森鷗外𠮟る")) -Header "Col1","Col2"
$dt = New-Object System.Data.DataTable

$col = New-Object System.Data.DataColumn
$col.ColumnName = "Col1"
$col.DataType = [System.Int32]
$dt.Columns.Add($col)

$col = New-Object System.Data.DataColumn
$col.ColumnName = "Col2"
$col.DataType = [System.String]
$dt.Columns.Add($col)

foreach($data in $source){
    $dr = $dt.NewRow()
    $dr.Item("Col1") =  $data.Col1
    $dr.Item("Col2") =  $data.Col2
    $dt.Rows.Add($dr)
}

$bc = New-Object "System.Data.SqlClient.SqlBulkCopy" $con
$bc.DestinationTableName = "dbo.BulkTest"
$bc.WriteToServer($dt)


# Bulk Copy (DataSet)
$cmd = $con.CreateCommand()
$cmd.CommandText = "SELECT object_id, name FROM sys.objects where object_id < 100"

$da = New-Object System.Data.SqlClient.SqlDataAdapter
$da.SelectCommand = $cmd

$ds = New-Object System.Data.DataSet
$count = $da.Fill($ds)

$bc = New-Object "System.Data.SqlClient.SqlBulkCopy" $con
$bc.DestinationTableName = "dbo.BulkTest"
$bc.WriteToServer($ds.Tables[0])



if($con){
    $con.Close()
    $con.Dispose()
}
