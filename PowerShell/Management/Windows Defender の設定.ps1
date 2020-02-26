# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender
$exclusionExtension = @(".mdf", ".ldf", ".ndf", ".bak", ".trn", "trc", ".xel", ".sql")
$exclusionExtension | %{Add-MpPreference -ExclusionExtension $_}

(Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL*.MSSQLSERVER\Setup" | Get-ItemProperty -Name "SQLBinRoot") | %{
    $mssqlBin = Join-path $_.SQLBinRoot -ChildPath "sqlservr.exe"
    Add-MpPreference -ExclusionProcess $mssqlBin
}