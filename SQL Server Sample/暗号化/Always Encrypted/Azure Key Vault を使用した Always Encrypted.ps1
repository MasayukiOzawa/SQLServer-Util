$clientid = "<クライアント ID>" # Azure AD のアプリケーションから取得
$clientSecret = "<キー>" # Azure AD のアプリケーションから取得
$connectionString = "<接続文字列>;Column Encryption Setting=enabled";

$assemblypath = "C:\KeyVault\" # 参照するアセンブリの配置パス

$assembly = @(
"System.Data"
, "$assemblypath\Hyak.Common.dll"
, "$assemblypath\Newtonsoft.Json.dll"
, "$assemblypath\Microsoft.Azure.KeyVault.dll"
, "$assemblypath\Microsoft.Azure.Common.dll"
, "$assemblypath\Microsoft.Azure.Common.NetFramework.dll"
, "$assemblypath\Microsoft.Threading.Tasks.dll"
, "$assemblypath\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
, "$assemblypath\Microsoft.SqlServer.Management.AlwaysEncrypted.AzureKeyVaultProvider.dll"
)

$assembly -like "*.dll" | %{Add-Type -Path $_}

<#
使用している NuGet パッケージ
Install-Package Microsoft.Azure.KeyVault
https://www.nuget.org/packages/Microsoft.Azure.KeyVault/
Install-Package Microsoft.IdentityModel.Clients.ActiveDirectory -Version 2.19.208020213
https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory
AlwaysEncryptedAzureKeyVaultProviderは2016 の SSMS のものを使用している
#>

$script = @"
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.SqlServer.Management.AlwaysEncrypted.AzureKeyVaultProvider;
using System.Data.SqlClient;

namespace AzureKeyVault
{
    public static class Keyvault
    {
        private static ClientCredential _clientCredential;

        public static Dictionary<string, SqlColumnEncryptionKeyStoreProvider> InitializeAzureKeyVaultProvider(string clientId, string clientSecret)
        {

            _clientCredential = new ClientCredential(clientId, clientSecret);

            // Direct the provider to the authentication delegate
            SqlColumnEncryptionAzureKeyVaultProvider azureKeyVaultProvider = new SqlColumnEncryptionAzureKeyVaultProvider(GetToken);

            Dictionary<string, SqlColumnEncryptionKeyStoreProvider> providers = new Dictionary<string, SqlColumnEncryptionKeyStoreProvider>();
            providers.Add(SqlColumnEncryptionAzureKeyVaultProvider.ProviderName, azureKeyVaultProvider);

            // register the provider with ADO.net
            return providers;
        }

        public async static Task<string> GetToken(string authority, string resource, string scope)
        {
            var authContext = new AuthenticationContext(authority);
            AuthenticationResult result = await authContext.AcquireTokenAsync(resource, _clientCredential);

            if (result == null)
                throw new InvalidOperationException("Failed to obtain the JWT token");

            return result.AccessToken;
        }
    }
}

"@

Add-Type -TypeDefinition $script -Language CSharp -ReferencedAssemblies $assembly

[System.Data.SqlClient.SqlConnection]::RegisterColumnEncryptionKeyStoreProviders([AzureKeyVault.KeyVault]::InitializeAzureKeyVaultProvider($ClientId, $ClientSecret))
# ここまでが、Azure Key Vault を Always Encrypted で使用するためのプロバイダーの登録

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
 
 
# データの追加
$command = $connection.CreateCommand()
$command.CommandType = [System.Data.CommandType]::Text
 
$command.CommandText = "INSERT INTO AlwaysEncrypted VALUES(@Name,@PersonalId,@Age)"
 
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name",[Data.SQLDBType]::NVarChar, 60))) | Out-Null
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PersonalId",[Data.SQLDBType]::VarChar, 11))) | Out-Null
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Age",[Data.SQLDBType]::Int))) | Out-Null
 
$Command.Parameters[0].Value = "Jim Gray"
$Command.Parameters[1].Value = "111-22-3333"
$Command.Parameters[2].Value = 63
 
$command.ExecuteNonQuery() | Out-Null

# データの検索
$command = $connection.CreateCommand()
$command.CommandType = [System.Data.CommandType]::Text
$command.CommandText = "SELECT * FROM AlwaysEncrypted WHERE PersonalID = @PersonalID"
 
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PersonalId",[Data.SQLDBType]::VarChar, 11))) | Out-Null
 
$command.Parameters[0].Value = "111-22-3333"
 
$reader = $command.ExecuteReader()
while($reader.Read())
{ 
    Write-Output ("{0} {1} {2}" -f $reader[0], $reader[1], $reader[2])
 }
 $reader.Close() 

 $connection.Close()

