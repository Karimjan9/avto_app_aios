param([string]$InstallRoot = 'C:\x_programs\avto-toolchain')
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$appRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $appRoot 'toolchain.windows.json') -Raw | ConvertFrom-Json
$cacheRoot = Join-Path $env:LOCALAPPDATA 'AvtoDev\downloads'
$null = New-Item -ItemType Directory -Force -Path $InstallRoot, $cacheRoot
$InstallRoot = (Resolve-Path -LiteralPath $InstallRoot).Path

function Get-VerifiedArchive([string]$Name, [string]$Url, [string]$Sha256) {
    $archive = Join-Path $cacheRoot "$Name.zip"
    if (-not (Test-Path -LiteralPath $archive)) {
        Write-Host "Yuklanmoqda: $Name"
        Invoke-WebRequest -Uri $Url -OutFile $archive -UseBasicParsing
    }
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $Sha256) {
        throw "${Name}: arxiv nazorat summasi mos kelmadi. $archive faylini tekshiring."
    }
    return $archive
}

$flutterRoot = Join-Path $InstallRoot 'flutter'
if (-not (Test-Path -LiteralPath (Join-Path $flutterRoot 'bin\flutter.bat'))) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git for Windows kerak.' }
    git clone --depth 1 --branch $manifest.flutter.version --single-branch $manifest.flutter.repository $flutterRoot
    if ($LASTEXITCODE -ne 0) { throw 'Flutter Git manbasi olinmadi.' }
    $actualRevision = git -C $flutterRoot rev-parse HEAD
    if ($actualRevision -ne $manifest.flutter.revision) { throw 'Flutter versiyasi kutilgan commit bilan mos emas.' }
    git -C $flutterRoot switch -c stable
    git -C $flutterRoot config remote.origin.fetch '+refs/heads/stable:refs/remotes/origin/stable'
    git -C $flutterRoot fetch --depth 1 origin stable
    git -C $flutterRoot branch --set-upstream-to=origin/stable stable
}
$installedRevision = git -C $flutterRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $installedRevision -ne $manifest.flutter.revision) {
    throw 'Mavjud Flutter SDK versiyasi mos emas. Boshqa -InstallRoot katalogini tanlang.'
}

$javaRoot = Join-Path $InstallRoot 'java'
$javaSettingsPath = Join-Path $javaRoot 'installed.json'
if (-not (Test-Path -LiteralPath $javaSettingsPath)) {
    $archive = Get-VerifiedArchive 'jdk-21' $manifest.jdk.url $manifest.jdk.sha256
    $null = New-Item -ItemType Directory -Force -Path $javaRoot
    Expand-Archive -LiteralPath $archive -DestinationPath $javaRoot
    $javaExecutable = Get-ChildItem -Path (Join-Path $javaRoot '*\bin\java.exe') | Select-Object -First 1
    if (-not $javaExecutable) { throw 'JDK arxivida java.exe topilmadi.' }
    $javaHome = Split-Path (Split-Path $javaExecutable.FullName -Parent) -Parent
    $settings = @{ java_home = $javaHome; sha256 = $manifest.jdk.sha256 } | ConvertTo-Json
    [IO.File]::WriteAllText($javaSettingsPath, $settings, [Text.UTF8Encoding]::new($false))
}

$androidRoot = Join-Path $InstallRoot 'android-sdk'
$cmdRoot = Join-Path $androidRoot 'cmdline-tools'
if (-not (Test-Path -LiteralPath (Join-Path $cmdRoot 'latest\bin\android.exe'))) {
    $archive = Get-VerifiedArchive 'android-tools-23' $manifest.android_tools.url $manifest.android_tools.sha256
    $null = New-Item -ItemType Directory -Force -Path $cmdRoot
    Expand-Archive -LiteralPath $archive -DestinationPath $cmdRoot
    Rename-Item -LiteralPath (Join-Path $cmdRoot 'cmdline-tools') -NewName 'latest'
}

$env:AVTO_TOOLCHAIN_HOME = $InstallRoot
. (Join-Path $PSScriptRoot 'env.ps1')
$userVariables = @{ AVTO_TOOLCHAIN_HOME = $InstallRoot; JAVA_HOME = $env:JAVA_HOME; ANDROID_HOME = $androidRoot; ANDROID_SDK_ROOT = $androidRoot }
foreach ($entry in $userVariables.GetEnumerator()) { [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'User') }
$userEntries = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { $_ })
$newEntries = @((Join-Path $flutterRoot 'bin'), (Join-Path $env:JAVA_HOME 'bin'), (Join-Path $androidRoot 'platform-tools'), (Join-Path $androidRoot 'emulator'), (Join-Path $cmdRoot 'latest\bin'))
foreach ($newEntry in $newEntries) { if ($userEntries -notcontains $newEntry) { $userEntries += $newEntry } }
[Environment]::SetEnvironmentVariable('Path', ($userEntries -join ';'), 'User')

$androidCli = Join-Path $cmdRoot 'latest\bin\android.exe'
foreach ($package in $manifest.android_packages) {
    $packagePath = Join-Path $androidRoot ($package.Replace('/', '\'))
    if (Test-Path -LiteralPath (Join-Path $packagePath 'package.xml')) { continue }
    Write-Host "Android paketi: $package"
    ('y' + "`n") * 100 | & $androidCli "--sdk=$androidRoot" --no-metrics sdk install $package
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $packagePath 'package.xml'))) {
        throw "Android paketi o'rnatilmadi: $package"
    }
}

& $script:AvtoFlutter config --android-sdk $androidRoot --jdk-dir $env:JAVA_HOME --no-enable-windows-desktop
if ($LASTEXITCODE -ne 0) { throw 'Flutter konfiguratsiyasi saqlanmadi.' }
if (Get-Command code -ErrorAction SilentlyContinue) { code --install-extension Dart-Code.flutter }
$vscodeSettingsPath = Join-Path $appRoot '.vscode\settings.json'
if (Test-Path -LiteralPath $vscodeSettingsPath) {
    $vscodeSettings = Get-Content -LiteralPath $vscodeSettingsPath -Raw | ConvertFrom-Json
    $vscodeSettings.'dart.flutterSdkPath' = $flutterRoot.Replace('\', '/')
    [IO.File]::WriteAllText($vscodeSettingsPath, ($vscodeSettings | ConvertTo-Json -Depth 10), [Text.UTF8Encoding]::new($false))
}
Push-Location $appRoot
try {
    & $script:AvtoFlutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter paketlari olinmadi.' }
} finally { Pop-Location }
& (Join-Path $PSScriptRoot 'create-emulator.ps1')
Write-Host 'Muhit tayyor. Tekshirish: .\dev.ps1 doctor'
