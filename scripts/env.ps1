$ErrorActionPreference = 'Stop'
$toolchainRoot = if ($env:AVTO_TOOLCHAIN_HOME) { $env:AVTO_TOOLCHAIN_HOME } else { 'C:\x_programs\avto-toolchain' }
$sdkRoot = Join-Path $toolchainRoot 'flutter'
$androidRoot = Join-Path $toolchainRoot 'android-sdk'
$javaSettingsPath = Join-Path $toolchainRoot 'java\installed.json'
if (Test-Path -LiteralPath $javaSettingsPath) {
    $javaSettings = Get-Content -LiteralPath $javaSettingsPath -Raw | ConvertFrom-Json
    $env:JAVA_HOME = $javaSettings.java_home
}
if (Test-Path -LiteralPath $androidRoot) {
    $env:ANDROID_HOME = $androidRoot
    $env:ANDROID_SDK_ROOT = $androidRoot
}
$pathEntries = @((Join-Path $sdkRoot 'bin'), (Join-Path $androidRoot 'platform-tools'), (Join-Path $androidRoot 'emulator'), (Join-Path $androidRoot 'cmdline-tools\latest\bin'))
if ($env:JAVA_HOME) { $pathEntries += (Join-Path $env:JAVA_HOME 'bin') }
$env:Path = (@($pathEntries | Where-Object { Test-Path -LiteralPath $_ }) + $env:Path) -join ';'
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    throw 'Flutter topilmadi. README.md dagi Windows sozlash bo limini bajaring.'
}
$script:AvtoFlutter = $flutterCommand.Source
