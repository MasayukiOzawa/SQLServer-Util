# 同時実行数を指定
$runspaceSize = 5

$results = New-Object System.Collections.ArrayList

Write-Host ("{0} : Process Start." -f (Get-Date).tostring("yyyy/MM/dd HH:mm:ss.fff"))
$sw = [system.diagnostics.stopwatch]::startNew()

# DB の接続情報
$conString = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$conString["Data Source"] = "localhost"
$constring["Initial Catalog"] = "tpch"
$conString["Integrated Security"] = $true
$constring["Application Name"] = "Maintenance Query"

# 対象のインデックス情報の取得
$targetSql = @"
SELECT 
	OBJECT_SCHEMA_NAME(o.object_id) AS schema_name
	, o.name AS object_name
	, i.name AS index_name
FROM 
	sys.objects AS o
	LEFT JOIN
	sys.indexes AS i
	ON
	i.object_id = o.object_id
WHERE 
	o.is_ms_shipped = 0 AND o.type = 'U'
	AND
	i.name IS NOT NULL
ORDER BY
	o.name ASC , i.name ASC
"@

$cmd = {
    param(
        $conString,
        $schema_name,
        $object_name,
        $index_name
    )

    try {
        $ret = [PSCustomObject]@{
            startTime = (Get-Date)
            endTime   = $null
            exception = $null
        }
        $con = New-Object System.Data.SqlClient.SqlConnection
        $con.ConnectionString = $conString
        $con.Open()
        
        $cmd = $con.CreateCommand()
        $cmd.CommandTimeout = 0
        $cmd.CommandText = ("ALTER INDEX [{0}] ON [{1}].[{2}] REORGANIZE" -f $index_name, $schema_name, $object_name)
        [void]$cmd.ExecuteNonQuery()
        
        $con.Close()
        $con.Dispose()
    }
    catch {
        $ret.exception = $Error[0]
    }
    finally { 
        $ret.endTime = (Get-Date)
        if ($con -ne $null) {
            $con.Close()
            $con.Dispose()
        }
    }
    return $ret
}

# $cmd.Invoke($conString, "AAAA")

try {
    # Runspace の作成
    $runspaceCollection = New-Object System.Collections.ArrayList
    $minpoolsize = $maxpoolsize = $runspaceSize
    $runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize)
    $runspacePool.Open()

    # 処理対象の取得
    $targetCon = New-Object System.Data.SqlClient.SqlConnection
    $targetCon.ConnectionString = $conString
    $targetCon.Open()
    $da = New-Object System.Data.SqlClient.SqlDataAdapter
    $targetList = New-Object System.Data.DataTable
    $da.SelectCommand = $targetSql
    $da.SelectCommand.Connection = $targetCon
    [void]$da.Fill($targetList)

    $da.Dispose()
    $targetCon.Close()
    $targetcon.Dispose()
    
    # RunSpacePool に実行するコマンドを設定
    $cnt = 1
    foreach ($target in $targetList) {
        $posh = [PowerShell]::Create().AddScript($cmd).`
            AddArgument($conString).`
            AddArgument($target.schema_name).`
            AddArgument($target.object_name).`
            AddArgument($target.index_name)
        $posh.RunspacePool = $runspacePool
        [void]$runspaceCollection.Add(
            [PSCustomObject]@{
                no       = $cnt ++
                target   = $target
                runspace = $posh.BeginInvoke()
                posh     = $posh
            }
        )
    }
    # 実行が完了するまで待機
    while ($runspaceCollection) {
        foreach ($runspace in $RunspaceCollection) {
            if ($runspace.Runspace.IsCompleted) {
                $ret = $runspace.posh.EndInvoke($runspace.Runspace)
                $runspace.posh.Dispose()
                Write-Host ("{0} : No.{1} ({2}.{3}.{4}) Completed.[Start : {5}] [End : {6}]" -f `
                    (Get-Date).tostring("yyyy/MM/dd HH:mm:ss.fff"), `
                        $runspace.No, `
                        $runspace.target.schema_name, `
                        $runspace.target.object_name, `
                        $runspace.target.index_name, `
                        $ret.startTime, `
                        $ret.endTime
                )
                [void]$results.Add(
                    [PSCustomObject]@{
                        no          = $runspace.no
                        schema_name = $runspace.target.schema_name
                        object_name = $runspace.target.object_name
                        index_name  = $runspace.target.index_name
                        result      = $ret
                    }
                )
                $runspaceCollection.Remove($runspace)
                break
            }
        }
        start-sleep -Milliseconds 500
    }

    # 結果の確認
    if (($results.result.exception | Measure-Object).count -ne 0) {
        Write-Host "An error occurred while processing the following object."
        Write-Host ("#" * 20)
        foreach ($errorInfo in $results) {
            if ($errorinfo.result.exception -ne $Nul) {
                Write-Host ("{0}.{1}.{2} : {3}" -f $errorInfo.schema_name, $errorInfo.object_name, $errorInfo.index_name, $errorInfo.result.exception.Exception.Message)            
            }
        }
        Write-Host ("#" * 20)    
    }
}
catch {
    Write-Host $Error[0]
}
finally {
    $runspacePool.Close()
    $runspacePool.Dispose()

    Write-Host ("{0} : Process End." -f (Get-Date).tostring("yyyy/MM/dd HH:mm:ss.fff"))
    [void]$sw.stop
    Write-Host ("Total Elapsed Time : {0}" -f $sw.Elapsed)
}
