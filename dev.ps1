param(
    [ValidateSet('android','apk','doctor','devices','emulator','get','check','backend')]
    [string]$Action = 'android',
    [string]$Device = '',
    [string]$ApiBaseUrl = 'https://platform.buxoroavto.uz/api/v1'
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')
Push-Location $PSScriptRoot
try {
    $apiDefine = "--dart-define=API_BASE_URL=$ApiBaseUrl"
    switch ($Action) {
        'doctor' { & $script:AvtoFlutter doctor -v }
        'devices' { & $script:AvtoFlutter devices }
        'get' { & $script:AvtoFlutter pub get }
        'check' {
            & $script:AvtoFlutter analyze
            if ($LASTEXITCODE -ne 0) { throw 'Flutter analyze xato bilan tugadi.' }
            & $script:AvtoFlutter test
        }
        'android' {
            $androidDevice = if ($Device) { $Device } else { 'emulator-5554' }
            $flutterArguments = @('run', '-d', $androidDevice, $apiDefine)
            & $script:AvtoFlutter @flutterArguments
        }
        'apk' { & $script:AvtoFlutter build apk --debug $apiDefine }
        'emulator' {
            $emulatorPath = Join-Path $env:ANDROID_HOME 'emulator\emulator.exe'
            if (-not (Test-Path -LiteralPath $emulatorPath)) { throw 'Android Emulator o rnatilmagan.' }
            $avdName = if ($Device) { $Device } else { 'Avto_API_36' }
            # This action opens the interactive emulator the developer uses to test the app.
            Start-Process -FilePath $emulatorPath -ArgumentList @('-avd', $avdName, '-no-boot-anim', '-gpu', 'swiftshader') -WindowStyle Normal
        }
        'backend' { & (Join-Path $PSScriptRoot 'scripts\check-backend.ps1') -ApiBaseUrl $ApiBaseUrl }
    }
    if ($LASTEXITCODE -ne 0 -and $Action -notin @('backend','emulator')) { throw "Flutter buyrug i xato bilan tugadi: $LASTEXITCODE" }
} finally { Pop-Location }
