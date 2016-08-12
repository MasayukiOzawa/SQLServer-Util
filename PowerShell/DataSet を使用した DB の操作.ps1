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
