# https://justdaveinfo.wordpress.com/2015/10/15/always-on-encrypted-generating-certificates-and-column-encryption-key-encrypted_value/
# https://msdn.microsoft.com/en-us/library/mt732057.aspx
# https://msdn.microsoft.com/en-us/library/mt755926.aspx
# https://blogs.technet.microsoft.com/dataplatform/2016/07/13/how-to-use-the-azure-key-vault-to-manage-the-key-for-a-tde-enabled-database/

$InBytes = New-Object Byte[] 32
$OutBytes = New-Object Byte[] 32

$RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider # https://msdn.microsoft.com/ja-jp/library/system.security.cryptography.rngcryptoserviceprovider(v=vs.110).aspx
$RNG.GetBytes($InBytes,0,8)
[System.BitConverter]::ToString($InBytes)

# 使用する証明書の選択
$cert = Get-ChildItem Cert:\LocalMachine\My | Out-GridView -OutputMode Single

# 暗号化文字列の生成 (証明書ストア)
$cmkprov = New-Object System.Data.SqlClient.SqlColumnEncryptionCertificateStoreProvider 
# https://msdn.microsoft.com/ja-jp/library/system.data.sqlclient.sqlcolumnencryptioncertificatestoreprovider(v=vs.110).aspx

$OutBytes = $cmkprov.EncryptColumnEncryptionKey("LocalMachine/My/$($cert.Thumbprint)","RSA_OAEP",$InBytes)
"0x" + [System.BitConverter]::ToString($OutBytes) -Replace '[-]','' | Out-GridView
