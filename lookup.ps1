# queries the given host_name for a TXT record expecting the value to be a base64 encoded DEFLATE compressed string
param (
    [string]$host_name = "base64.bonedaddy.io",
    [string]$dns_server = "8.8.8.8"
)

$dns_result = Resolve-DnsName -Name $host_name -Type TXT -Server $dns_server | Select-Object Strings
$deconstructed_query = ''

for ($i=0; $i -lt $dns_result.Strings.length; $i++) {
    $data = [System.Convert]::FromBase64String($dns_result.Strings[$i])
    $ms = New-Object System.IO.MemoryStream
    $ms.Write($data, 0, $data.Length)
    $ms.Seek(0,0) | Out-Null

    $sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress))

    while ($line = $sr.ReadLine()) {  
        $deconstructed_query += $line
    }
}

Write-Host $deconstructed_query