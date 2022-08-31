Install-PackageProvider -Name NuGet -Force
Register-PackageSource -Name nuget.org -ProviderName NuGet -Location https://www.nuget.org/api/v2  -Trusted

Install-Package Microsoft.Data.SqlClient.SNI -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.Abstractions -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.Identity.Client -RequiredVersion 4.45.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.Identity.Client -RequiredVersion 4.38.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Runtime.CompilerServices.Unsafe -RequiredVersion 4.5.3 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.Identity.Client.Extensions.Msal -RequiredVersion 2.19.3 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.Logging -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.Tokens -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.JsonWebTokens -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.Protocols -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Buffers -RequiredVersion 4.5.1 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.IdentityModel.Tokens.Jwt -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.IdentityModel.Protocols.OpenIdConnect -RequiredVersion 6.21.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.IO -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Numerics.Vectors -RequiredVersion 4.5.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Runtime -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Memory -RequiredVersion 4.5.4 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Diagnostics.DiagnosticSource -RequiredVersion 4.6.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Runtime.InteropServices.RuntimeInformation -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Cryptography.Encoding -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Cryptography.Primitives -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Cryptography.Algorithms -RequiredVersion 4.3.1 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Cryptography.ProtectedData -RequiredVersion 4.7.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Cryptography.X509Certificates -RequiredVersion 4.3.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Net.Http -RequiredVersion 4.3.4 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Principal.Windows -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.AccessControl -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Security.Permissions -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Configuration.ConfigurationManager -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Text.Encodings.Web -RequiredVersion 4.7.2 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Threading.Tasks.Extensions -RequiredVersion 4.5.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Threading.Tasks.Extensions -RequiredVersion 4.5.4 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.Bcl.AsyncInterfaces -RequiredVersion 1.1.1 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.ValueTuple -RequiredVersion 4.5.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Text.Json -RequiredVersion 4.7.2 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package System.Memory.Data -RequiredVersion 1.0.2 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Azure.Core -RequiredVersion 1.24.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Azure.Identity -RequiredVersion 1.6.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Install-Package Microsoft.Data.SqlClient -RequiredVersion 5.0.0 -Destination "C:\sqlclient" -SkipDependencies -ProviderName NuGet
Copy-Item "C:\sqlclient\Microsoft.Data.SqlClient.SNI.5.0.0\build\net46\Microsoft.Data.SqlClient.SNI.x64.dll" "C:\sqlclient\Microsoft.Data.SqlClient.5.0.0\lib\net462"

Add-Type -Path "C:\sqlclient\System.Threading.Tasks.Extensions.4.5.0\lib\netstandard2.0\System.Threading.Tasks.Extensions.dll"
Add-Type -Path "C:\sqlclient\System.Threading.Tasks.Extensions.4.5.4\lib\netstandard2.0\System.Threading.Tasks.Extensions.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Bcl.AsyncInterfaces.1.1.1\lib\net461\Microsoft.Bcl.AsyncInterfaces.dll"
Add-Type -Path "C:\sqlclient\System.Memory.4.5.4\lib\net461\System.Memory.dll"
Add-Type -Path "C:\sqlclient\System.Diagnostics.DiagnosticSource.4.6.0\lib\net46\System.Diagnostics.DiagnosticSource.dll"
Add-Type -Path "C:\sqlclient\System.Text.Json.4.7.2\lib\net461\System.Text.Json.dll"
Add-Type -Path "C:\sqlclient\System.Memory.Data.1.0.2\lib\net461\System.Memory.Data.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Identity.Client.4.45.0\lib\net461\Microsoft.Identity.Client.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Identity.Client.4.38.0\lib\net461\Microsoft.Identity.Client.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.Logging.6.21.0\lib\net472\Microsoft.IdentityModel.Logging.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.Tokens.6.21.0\lib\net472\Microsoft.IdentityModel.Tokens.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Identity.Client.Extensions.Msal.2.19.3\lib\net45\Microsoft.Identity.Client.Extensions.Msal.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Identity.Client.Extensions.Msal.2.19.3\lib\net45\Microsoft.Identity.Client.Extensions.Msal.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.Abstractions.6.21.0\lib\net472\Microsoft.IdentityModel.Abstractions.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.JsonWebTokens.6.21.0\lib\net472\Microsoft.IdentityModel.JsonWebTokens.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.Protocols.6.21.0\lib\net472\Microsoft.IdentityModel.Protocols.dll"
Add-Type -Path "C:\sqlclient\Microsoft.IdentityModel.Protocols.OpenIdConnect.6.21.0\lib\net472\Microsoft.IdentityModel.Protocols.OpenIdConnect.dll"
Add-Type -Path "C:\sqlclient\System.IdentityModel.Tokens.Jwt.6.21.0\lib\net472\System.IdentityModel.Tokens.Jwt.dll"
Add-Type -Path "C:\sqlclient\System.Buffers.4.5.1\lib\net461\System.Buffers.dll"
Add-Type -Path "C:\sqlclient\System.Configuration.ConfigurationManager.5.0.0\lib\net461\System.Configuration.ConfigurationManager.dll"
Add-Type -Path "C:\sqlclient\System.IO.4.3.0\lib\net462\System.IO.dll"
Add-Type -Path "C:\sqlclient\System.Net.Http.4.3.4\lib\net46\System.Net.Http.dll"
Add-Type -Path "C:\sqlclient\System.Numerics.Vectors.4.5.0\lib\net46\System.Numerics.Vectors.dll"
Add-Type -Path "C:\sqlclient\System.Runtime.4.3.0\lib\net462\System.Runtime.dll"
Add-Type -Path "C:\sqlclient\System.Runtime.CompilerServices.Unsafe.4.5.3\lib\net461\System.Runtime.CompilerServices.Unsafe.dll"
Add-Type -Path "C:\sqlclient\System.Runtime.InteropServices.RuntimeInformation.4.3.0\lib\net45\System.Runtime.InteropServices.RuntimeInformation.dll"
Add-Type -Path "C:\sqlclient\System.Security.AccessControl.5.0.0\lib\net461\System.Security.AccessControl.dll"
Add-Type -Path "C:\sqlclient\System.Security.Cryptography.Algorithms.4.3.1\lib\net463\System.Security.Cryptography.Algorithms.dll"
Add-Type -Path "C:\sqlclient\System.Security.Cryptography.Encoding.4.3.0\lib\net46\System.Security.Cryptography.Encoding.dll"
Add-Type -Path "C:\sqlclient\System.Security.Cryptography.Primitives.4.3.0\lib\net46\System.Security.Cryptography.Primitives.dll"
Add-Type -Path "C:\sqlclient\System.Security.Cryptography.ProtectedData.4.7.0\lib\net461\System.Security.Cryptography.ProtectedData.dll"
Add-Type -Path "C:\sqlclient\System.Security.Cryptography.X509Certificates.4.3.0\lib\net461\System.Security.Cryptography.X509Certificates.dll"
Add-Type -Path "C:\sqlclient\System.Security.Permissions.5.0.0\lib\net461\System.Security.Permissions.dll"
Add-Type -Path "C:\sqlclient\System.Security.Principal.Windows.5.0.0\lib\net461\System.Security.Principal.Windows.dll"
Add-Type -Path "C:\sqlclient\System.Text.Encodings.Web.4.7.2\lib\net461\System.Text.Encodings.Web.dll"
Add-Type -Path "C:\sqlclient\System.ValueTuple.4.5.0\lib\net47\System.ValueTuple.dll"
Add-Type -Path "C:\sqlclient\Azure.Core.1.24.0\lib\net461\Azure.Core.dll"
Add-Type -Path "C:\sqlclient\Microsoft.Data.SqlClient.5.0.0\lib\net462\Microsoft.Data.SqlClient.dll"


$Error[0].Exception.LoaderExceptions

$con = New-Object Microsoft.Data.SqlClient.Sqlconnection("Server=tcp:localhost;Integrated Security=True")
# $con = New-Object Microsoft.Data.SqlClient.Sqlconnection("Server=tcp:localhost;Integrated Security=True;Encrypt=Strict")
# $con = New-Object Microsoft.Data.SqlClient.Sqlconnection("Server=tcp:localhost;Integrated Security=True;Encrypt=True;TrustServerCertificate=true")
# $con = New-Object Microsoft.Data.SqlClient.Sqlconnection("Server=tcp:localhost;Integrated Security=True;Encrypt=False")

$con.Open()

$cmd = $con.CreateCommand()
$cmd.CommandText ="SELECT @@VERSION"
$cmd.ExecuteScalar()

