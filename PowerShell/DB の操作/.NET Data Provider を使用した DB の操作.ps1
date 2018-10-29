################################################
# .NET Data Provider
################################################

$constring = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$constring.psbase.DataSource = "."
$constring.psbase.InitialCatalog = "tempdb"
$constring.psbase.IntegratedSecurity = $true

$con = New-Object System.Data.SqlClient.SqlConnection

$con.ConnectionString = $constring
$con.Open()

################################################
# SELECT の実行 (平文)
################################################
$cmd = $con.CreateCommand()
$cmd.CommandText = "SELECT object_id, name FROM sys.objects"
$ret = $cmd.ExecuteReader()
while($ret.Read()){
    "{0} {1}" -f $ret[0], $ret[1]
}
$ret.Close()

################################################
# SELECT の実行 (パラメーター)
################################################
$cmd = $con.CreateCommand()
$cmd.CommandText = "SELECT object_id, name FROM sys.objects WHERE name like @param1"
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.Parameters.Add("@param1", [System.Data.SqlDbType]::VarChar, 255) > $null
$cmd.Parameters["@param1"].Value = "sys%"

$ret = $cmd.ExecuteReader()
while($ret.Read()){
    "{0} {1}" -f $ret[0], $ret[1]
}
$ret.Close()

################################################
# ストアドプロシージャの実行 
################################################
$cmd = $con.CreateCommand()
$cmd.CommandText = "sp_configure"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure

$cmd.Parameters.Add("@configname", [System.Data.SqlDbType]::VarChar, 255) > $null
$cmd.Parameters["@configname"].Value = "show advanced options"
$cmd.Parameters["@configname"].Direction = [System.Data.ParameterDirection]::Input

$ret = $cmd.ExecuteReader()

while($ret.Read()){
    "{0} {1}" -f $ret[0], $ret[1]
}
$ret.Close()
################################################
# ストアドプロシージャの実行 (OUTPUT)
################################################
<#
create procedure usp_test
    @param1 int output
AS
BEGIN

	SET @param1 = 99999
END
#>

$cmd = $con.CreateCommand()
$cmd.CommandText = "usp_test"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure

$cmd.Parameters.Add("@param1", [System.Data.SqlDbType]::int) > $null
$cmd.Parameters["@param1"].Direction = [System.Data.ParameterDirection]::Output

$cmd.ExecuteNonQuery() > $null

$cmd.Parameters["@param1"].Value
$ret.Close()

################################################
# トランザクション
################################################
$tran = $con.BeginTransaction([System.Data.IsolationLevel]::Serializable)
$cmd = $con.CreateCommand()

$cmd.Transaction = $tran

$cmd.CommandText = "CREATE TABLE test1(Col1 int);INSERT INTO test1 VALUES(1)"
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.ExecuteNonQuery() > $null

$tran.Rollback()

################################################
# トランザクションスコープ
################################################
$con1 = New-Object System.Data.SqlClient.SqlConnection
$con1.ConnectionString = $constring

$con2 = New-Object System.Data.SqlClient.SqlConnection
$con2.ConnectionString = $constring

# オブジェクト生成後に Open し、try / catch でエラー時には、Complete しないようにする
try{
    $tranoption = New-Object System.Transactions.TransactionOptions
    $tranoption.IsolationLevel = [System.Transactions.IsolationLevel]::ReadCommitted
   
    $transcope = New-Object System.Transactions.TransactionScope -ArgumentList (New-Object System.Transactions.TransactionScopeOption)::Required, $tranoption

    $con1.Open()

    $cmd1 = $con1.CreateCommand()
    $cmd1.CommandText = "CREATE TABLE test1(Col1 int);INSERT INTO test1 VALUES(1)"
    $cmd1.ExecuteNonQuery() > $null
   
    $con2.Open()

    $cmd2 = $con2.CreateCommand()
    $cmd2.CommandText = "CREATE TABLE test2(Col1 int);INSERT INTO test2 VALUES(1)"
    $cmd2.ExecuteNonQuery() > $null
    
    $transcope.Complete()
}catch{
    Write-Output $_
}finally{
    if($transcope){
        $transcope.Dispose()
    }
}

if($con1){
    $con1.Close()
    $con1.Dispose()
}

if($con2){
    $con2.Close()
    $con2.Dispose()
}

################################################
# MARS
################################################
$constring_mars = $constring
$constring_mars.MultipleActiveResultSets = $true

$con_mars = New-Object System.Data.SqlClient.SqlConnection

$con_mars.ConnectionString = $constring_mars
$con_mars.Open()

$cmd1 = $con_mars.CreateCommand()
$cmd2 = $con_mars.CreateCommand()

$cmd1.CommandText = "SELECT 1"
$cmd1.CommandType = [System.Data.CommandType]::Text

$cmd2.CommandText = "SELECT 2"
$cmd2.CommandType = [System.Data.CommandType]::Text

$ret1 = $cmd1.ExecuteReader()
$ret2 = $cmd2.ExecuteReader()

if($con_mars){
    $con_mars.Close()
    $con_mars.Dispose()
}


if($con){
    $con.Close()
    $con.Dispose()
}

################################################
# BINARY の操作
################################################
<#
CREATE TABLE BinaryTest (Col1 varbinary(max))
#>
# https://msdn.microsoft.com/ja-jp/library/3517w44b(v=vs.90).aspx
# 以下の方法だとサイズの大きいファイルの読み込みに時間がかかるため、Binary Read する
# http://mtgpowershell.blogspot.jp/2012/11/blog-post_8534.html
# [Byte[]]$file = Get-Content -Path "C:\temp\ReplayEvents.irf" -Encoding Byte
$file = [System.IO.File]::ReadAllBytes("C:\temp\status.log")
$cmd = $con.CreateCommand()
$cmd.CommandText = "INSERT INTO BinaryTest VALUES(@param1)"
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.Parameters.Add("@param1", [System.Data.SqlDbType]::VarBinary) > $null
$cmd.Parameters["@param1"].Value = $file
$cmd.ExecuteNonQuery()

# パラメーターを使用しない場合の INSERT (バイト配列の編集に時間がかかるため推奨しない)
$Cmd.CommandText = "INSERT INTO BinaryTest VALUES({0})" -f ("0x" + [System.String]::Join("", ($file | %{"{0:X2}" -f $_})))
$cmd.ExecuteNonQuery()
$cmd.Dispose()

# バイナリのファイルの書き込み
# https://social.technet.microsoft.com/wiki/contents/articles/890.export-sql-server-blob-data-with-powershell.aspx
$bufferSize = 8192
$ExportPath = "C:\temp\AdventureWorks2014_2.bak"

$cmd = $con.CreateCommand()
$cmd.CommandText = "SELECT TOP 1 * FROM BinaryTest"
$ret = $cmd.ExecuteReader()

$out = [array]::CreateInstance("Byte", $bufferSize)

While($ret.Read()){
    $fs = New-Object System.IO.FileStream ($ExportPath), Create, Write       
    $bw = New-Object System.IO.BinaryWriter $fs       
               
    $start = 0             
    $received = $ret.GetBytes(0, $start, $out, 0, $bufferSize - 1)
    While ($received -gt 0)
    {            
       $bw.Write($out, 0, $received)       
       $bw.Flush()       
       $start += $received                 
       $received = $ret.GetBytes(0, $start, $out, 0, $bufferSize - 1)       
    }            
            
    $bw.Close()       
    $fs.Close()
}
$ret.Close()
