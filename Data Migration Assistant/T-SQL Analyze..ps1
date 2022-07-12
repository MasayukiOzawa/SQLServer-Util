$scritDomFilePath = "C:\Program Files\Microsoft Data Migration Assistant\Microsoft.SqlServer.TransactSql.ScriptDom.dll"

Add-Type -Path $scritDomFilePath
$query = @"
create procedure usp_02
as
begin
	select top 10 * from person.Address AS MERGE
end
go
"@

$errors = New-Object "System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]"

$parser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser($false)
$resulsts = $parser.Parse([System.IO.StringReader]::new($query), [ref]$errors)

if($errors -ne $null){
    Write-Output $errors
}