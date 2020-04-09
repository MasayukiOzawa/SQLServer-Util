[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12


# https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs

$response = Invoke-WebRequest -Uri https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/databases/northwind-pubs/instnwnd.sql

[byte[]]$bytes = ([System.Text.Encoding]::UTF8.GetBytes($response.Content))
[System.Text.Encoding]::Unicode.GetString($bytes[6..$bytes.Count]) | clip


$response = Invoke-WebRequest -Uri https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/databases/northwind-pubs/instpubs.sql
$response.content | clip




$downloadFile = @(
    "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak",
    "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak",
    "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2017.bak",
    "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak",
    "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak"
)

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# サンプル DB をリストアする SQL Server 上での実行を想定
$con = New-Object System.Data.SqlClient.SqlConnection("Server=localhost;Integrated Security=SSPI")
$con.Open()
$cmd = $con.CreateCommand()
$cmd.CommandTimeout = 0

# バックアップディレクトリの取得
$cmd.CommandText = "master.dbo.xp_instance_regread"
$cmd.CommandType = [System.Data.CommandType]::StoredProcedure
[void]$cmd.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@p1", [System.Data.SqlDbType]::NVarChar, 255)))
[void]$cmd.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@p2", [System.Data.SqlDbType]::NVarChar, 255)))
[void]$cmd.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@p3", [System.Data.SqlDbType]::NVarChar, 255)))
[void]$cmd.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@BackupDirectory", [System.Data.SqlDbType]::NVarChar, 512)))
$cmd.Parameters["@BackupDirectory"].Direction = [System.Data.ParameterDirection]::Output

$cmd.Parameters["@p1"].Value = "HKEY_LOCAL_MACHINE"
$cmd.Parameters["@p2"].Value = "Software\Microsoft\MSSQLServer\MSSQLServer"
$cmd.Parameters["@p3"].Value = "BackupDirectory"

[void]$cmd.ExecuteNonQuery()
$backupDir = $cmd.Parameters["@BackupDirectory"].Value

$cmd.CommandType = [System.Data.CommandType]::Text

# データディレクトリの取得
$cmd.CommandText = "SELECT SERVERPROPERTY('instancedefaultdatapath') AS Data"
$reader = $cmd.ExecuteReader()
[void]$reader.Read()
$dataDir = $reader["Data"]
$reader.Close()

# バックアップファイルをダウンロード
$downloadFile | ForEach-Object{
    Write-Host ("Downloading {0}" -f $_)
    Invoke-WebRequest -Uri $_ -OutFile (Join-Path $backupDir (($_ -split "/")[-1]))
}

$restoreBase = "RESTORE DATABASE [{0}] FROM DISK = N'{1}' WITH FILE = 1, {2} NOUNLOAD,  STATS = 5"
$moveBase = "MOVE N'{0}' TO N'{1}',`n"
$fileListOnlyBase = "RESTORE FILELISTONLY FROM DISK=N'{0}'" 
$headerOnlyBase = "RESTORE HEADERONLY FROM DISK=N'{0}'"
$changeDbOwnerBase = "USE [{0}];EXEC sp_changedbowner '{1}'"

# リストアの実行
Get-ChildItem $backupDir | ForEach-Object {
    Write-Host ("Restoring {0}" -f $_.FullName)
    $backupFile = $_.FullName
    $headerSql = $headerOnlyBase -f $backupFile
    $fileListSql = $fileListOnlyBase -f $backupFile
    
    $cmd.CommandText = $headerSql
    $reader = $cmd.ExecuteReader()
    [void]$reader.Read()
    $databasename = $reader["DatabaseName"]
    $reader.Close()
    
    $cmd.CommandText = $fileListSql
    $reader = $cmd.ExecuteReader()
    $moveSql = New-Object System.Text.StringBuilder
    
    while($reader.Read()){
        $logicalName = $reader["LogicalName"]
        $physicalName = (Join-Path $dataDir ([System.IO.Path]::GetFileName($reader["PhysicalName"])))
        
        [void]$moveSql.Append(($moveBase -f $logicalName, $physicalName))
    }
    $reader.close()
    $restoreSql = $restoreBase  -f $databasename, $backupFile, $moveSql.Tostring()
    $cmd.CommandText = $restoreSql
    [void]$cmd.ExecuteNonQuery()
    
    $cmd.CommandText = ($changeDbOwnerBase -f $databasename, $currentUser)
    [void]$cmd.ExecuteNonQuery()
}

$con.Close()
$con.Dispose()