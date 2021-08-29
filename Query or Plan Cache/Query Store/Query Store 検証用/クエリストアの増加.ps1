1..5 | % {
    Start-job -ScriptBlock {
        1.. 20000 | % {
            Add-Type -AssemblyName System.Web
            $con = new-Object System.Data.SqlClient.SqlConnection("Server=localhost;Integrated Security=SSPI;database=TESTDB")
            $con.Open()
            $cmd = $con.CreateCommand()
            $cmd.CommandText = ("SELECT '{0}' AS c, * FROM T1" -f [System.Web.Security.Membership]::GeneratePassword(100, 0))
            [void]$cmd.ExecuteNonQuery()

            $con.Close()
        }
    }
}
While((get-job -State Running) -ne $null){
    Write-Host ("{0} : {1}/{2} Waiting...." -f (Get-Date), (Get-Job -State Running).Count, (Get-Job).Count)
    Start-Sleep -Seconds 10
}

Get-Job | Remove-Job