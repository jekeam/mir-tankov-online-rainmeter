param(
    [string]$Output = "$PSScriptRoot\@Resources\Data.inc"
)

$ErrorActionPreference = 'Stop'
$url = 'https://kttc.ru/wot/ru/info/servers-online/'
$defaults = @(
    'S1=','M1=',
    'S2=','M2=',
    'S3=','M3=',
    'S4=','M4=',
    'S5=','M5=',
    'S6=','M6=',
    'S7=','M7=',
    'S8=','M8=',
    'LastUpdate=error'
)

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $html = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20).Content
    $pairs = [regex]::Matches(
        $html,
        '<div>[^<]*:\s*<b>(\d+)</b></div>\s*<div>[^<]*:\s*<b>(RU\d+)</b></div>',
        'Singleline'
    )

    if ($pairs.Count -lt 1) {
        throw 'No server data found'
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $items = foreach ($pair in $pairs) {
        [pscustomobject]@{
            Server = $pair.Groups[2].Value
            Online = [int]$pair.Groups[1].Value
        }
    }

    $items = @($items | Sort-Object Online -Descending)
    $limit = [Math]::Min(8, $items.Count)

    for ($i = 0; $i -lt 8; $i++) {
        if ($i -lt $limit) {
            $online = $items[$i].Online.ToString() -replace '(?<=\d)(?=(\d{3})+$)', ' '
            $server = $items[$i].Server
            $lines.Add("S$($i + 1)=$server")
            $lines.Add("M$($i + 1)=$online")
        } else {
            $lines.Add("S$($i + 1)=")
            $lines.Add("M$($i + 1)=")
        }
    }

    $lines.Add("LastUpdate=$(Get-Date -Format 'HH:mm:ss')")
} catch {
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $defaults) {
        $lines.Add($line)
    }
}

$dir = Split-Path -Parent $Output
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

[IO.File]::WriteAllLines($Output, $lines, [Text.Encoding]::ASCII)
