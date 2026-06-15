param(
    [string]$Version = '1.0.0'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$skinName = 'MirTankovOnline'
$packageName = "MirTankovOnline-v$Version"
$buildRoot = Join-Path $root '.build'
$stage = Join-Path $buildRoot $packageName
$dist = Join-Path $root 'dist'
$rmskin = Join-Path $dist "$packageName.rmskin"
$zip = Join-Path $dist "$packageName.zip"

if (Test-Path -LiteralPath $stage) {
    Remove-Item -LiteralPath $stage -Recurse -Force
}

New-Item -ItemType Directory -Force -Path (Join-Path $stage "Skins\$skinName") | Out-Null
New-Item -ItemType Directory -Force -Path $dist | Out-Null

Copy-Item -LiteralPath (Join-Path $root "RainmeterSkin\$skinName\MirTankovOnline.ini") -Destination (Join-Path $stage "Skins\$skinName\MirTankovOnline.ini") -Force
Copy-Item -LiteralPath (Join-Path $root "RainmeterSkin\$skinName\Fetch-MirTankovOnline.ps1") -Destination (Join-Path $stage "Skins\$skinName\Fetch-MirTankovOnline.ps1") -Force
Copy-Item -LiteralPath (Join-Path $root "RainmeterSkin\$skinName\ManualRefresh.vbs") -Destination (Join-Path $stage "Skins\$skinName\ManualRefresh.vbs") -Force
Copy-Item -LiteralPath (Join-Path $root "RainmeterSkin\$skinName\@Resources") -Destination (Join-Path $stage "Skins\$skinName\@Resources") -Recurse -Force

$manifest = @"
[rmskin]
Name=Mir Tankov Online
Author=jekeam
Version=$Version
MinimumRainmeter=4.5
MinimumWindows=10.0
LoadType=Skin
Load=$skinName\MirTankovOnline.ini
MergeSkins=1
"@

Set-Content -LiteralPath (Join-Path $stage 'RMSKIN.ini') -Value $manifest -Encoding Unicode

if (Test-Path -LiteralPath $zip) {
    Remove-Item -LiteralPath $zip -Force
}

if (Test-Path -LiteralPath $rmskin) {
    Remove-Item -LiteralPath $rmskin -Force
}

Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
Move-Item -LiteralPath $zip -Destination $rmskin -Force

Write-Output $rmskin

