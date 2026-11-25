$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$avdRoot = if ($env:ANDROID_AVD_HOME) { $env:ANDROID_AVD_HOME } else { Join-Path $env:USERPROFILE '.android\avd' }
$avdName = 'Avto_API_36'
$avdIni = Join-Path $avdRoot "$avdName.ini"
if (Test-Path -LiteralPath $avdIni) { Write-Host "Emulator mavjud: $avdName"; return }
$cmdRoot = Join-Path $env:ANDROID_HOME 'cmdline-tools\latest'
$javaExecutable = Join-Path $env:JAVA_HOME 'bin\java.exe'
$avdArguments = @(
    "-Dcom.android.sdkmanager.toolsdir=$cmdRoot",
    '-classpath', (Join-Path $cmdRoot 'lib\avdmanager-classpath.jar'),
    'com.android.sdklib.tool.AvdManagerCli',
    'create', 'avd', '--name', $avdName,
    '--package', 'system-images;android-36;default;x86_64',
    '--device', 'pixel_5'
)
'no' | & $javaExecutable @avdArguments
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $avdIni)) { throw 'Android virtual qurilmasi yaratilmadi.' }
$configPath = Join-Path $avdRoot "$avdName.avd\config.ini"
$configText = Get-Content -LiteralPath $configPath -Raw
$configText = $configText -replace '(?m)^hw.ramSize=.*$', 'hw.ramSize=2560'
$configText = $configText -replace '(?m)^hw.cpu.ncore=.*$', 'hw.cpu.ncore=2'
$displaySettings = @{ 'hw.lcd.width' = '720'; 'hw.lcd.height' = '1560'; 'hw.lcd.density' = '320' }
foreach($entry in $displaySettings.GetEnumerator()) {
    $pattern = '(?m)^' + [regex]::Escape($entry.Key) + '=.*$'
    $line = $entry.Key + '=' + $entry.Value
    if($configText -match $pattern) { $configText = $configText -replace $pattern, $line }
    else { $configText += "`n$line`n" }
}
[IO.File]::WriteAllText($configPath, $configText, [Text.UTF8Encoding]::new($false))
Write-Host "Emulator yaratildi: $avdName"
