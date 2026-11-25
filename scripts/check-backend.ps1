param([string]$ApiBaseUrl = 'https://platform.buxoroavto.uz/api/v1')
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$baseUri = [Uri]($ApiBaseUrl.TrimEnd('/') + '/')
$checks = @(
    @{ Path = 'catalog'; Expected = 200 },
    @{ Path = 'listings?per_page=1'; Expected = 200 },
    @{ Path = 'businesses?per_page=1'; Expected = 200 },
    @{ Path = 'me'; Expected = 401 }
)
foreach ($check in $checks) {
    $uri = [Uri]::new($baseUri, $check.Path)
    $status = $null
    try {
        $response = Invoke-WebRequest -Uri $uri -Headers @{ Accept = 'application/json' } -UseBasicParsing -TimeoutSec 30
        $status = [int]$response.StatusCode
        $null = $response.Content | ConvertFrom-Json
    } catch {
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
        else { throw }
    }
    if ($status -ne $check.Expected) { throw "$($check.Path): HTTP $status; kutilgan $($check.Expected)" }
    Write-Host "OK HTTP $status $($check.Path)"
}
