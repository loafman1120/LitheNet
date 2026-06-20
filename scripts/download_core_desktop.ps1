param(
    [ValidateSet("windows", "linux", "macos")]
    [string]$Platform,
    [string]$Repo = "loafman1120/singbox-ffi",
    [string]$Workflow = "Build",
    [string]$Branch = "main",
    [string]$Arch,
    [switch]$SkipDownload
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$artifactRoot = Join-Path $root "native/singboxffi/artifacts"

function Assert-Command($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found on PATH."
    }
}

function Get-DefaultPlatform {
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        return "windows"
    }
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) {
        return "linux"
    }
    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) {
        return "macos"
    }
    throw "Could not infer the host platform. Pass -Platform explicitly."
}

function Get-DefaultArch {
    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
        "X64" { return "amd64" }
        "Arm64" { return "arm64" }
        default {
            throw "Unsupported host architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
        }
    }
}

function Get-PackageRoot($PackageName) {
    $packageConfigPath = Join-Path $root ".dart_tool/package_config.json"
    if (-not (Test-Path $packageConfigPath)) {
        Assert-Command "flutter"
        Push-Location $root
        try {
            flutter pub get
        } finally {
            Pop-Location
        }
    }

    $packageConfig = Get-Content $packageConfigPath -Raw | ConvertFrom-Json
    $package = $packageConfig.packages | Where-Object { $_.name -eq $PackageName } | Select-Object -First 1
    if (-not $package) {
        throw "$PackageName was not resolved by pub get."
    }

    return [System.Uri]::new($package.rootUri).LocalPath
}

if (-not $Platform) {
    $Platform = Get-DefaultPlatform
}
if (-not $Arch) {
    $Arch = Get-DefaultArch
}

$artifactArch = $Arch
$pluginSubdir = $null
$libraryName = $null

switch ($Platform) {
    "windows" {
        $pluginArch = if ($Arch -eq "arm64") { "arm64" } else { "x64" }
        $pluginSubdir = "windows/artifacts/$pluginArch"
        $libraryName = "singboxffi.dll"
    }
    "linux" {
        $pluginArch = if ($Arch -eq "arm64") { "aarch64" } else { "x86_64" }
        $pluginSubdir = "linux/artifacts/$pluginArch"
        $libraryName = "libsingboxffi.so"
    }
    "macos" {
        $pluginSubdir = "macos/Libraries"
        $libraryName = "libsingboxffi.dylib"
    }
}

$artifactName = "singboxffi-$Platform-$artifactArch"
$artifactDir = Join-Path $artifactRoot $artifactName
$libraryPath = Join-Path $artifactDir $libraryName
$headerPath = Join-Path $artifactDir "singboxffi.h"

if (-not $SkipDownload) {
    Assert-Command "gh"

    $runId = gh run list `
        --repo $Repo `
        --workflow $Workflow `
        --branch $Branch `
        --status success `
        --limit 1 `
        --json databaseId `
        --jq '.[0].databaseId'

    if (-not $runId) {
        throw "No successful $Repo $Workflow workflow run found on $Branch."
    }

    $downloadDir = Join-Path $artifactRoot "_download-$Platform-$artifactArch"
    if (Test-Path $downloadDir) {
        Remove-Item -Recurse -Force $downloadDir
    }

    New-Item -ItemType Directory -Force $downloadDir | Out-Null
    gh run download $runId --repo $Repo --name $artifactName --dir $downloadDir

    New-Item -ItemType Directory -Force $artifactDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $downloadDir $libraryName) -Destination $libraryPath -Force
    if (Test-Path (Join-Path $downloadDir "singboxffi.h")) {
        Copy-Item -LiteralPath (Join-Path $downloadDir "singboxffi.h") -Destination $headerPath -Force
    }
    Remove-Item -Recurse -Force $downloadDir
}

if (-not (Test-Path $libraryPath)) {
    throw "Missing $libraryPath. Run this script without -SkipDownload to fetch it."
}

$packageRoot = Get-PackageRoot "singbox_ffi"
$pluginArtifactDir = Join-Path $packageRoot $pluginSubdir
New-Item -ItemType Directory -Force $pluginArtifactDir | Out-Null

Copy-Item -LiteralPath $libraryPath -Destination (Join-Path $pluginArtifactDir $libraryName) -Force
if (Test-Path $headerPath) {
    Copy-Item -LiteralPath $headerPath -Destination (Join-Path $pluginArtifactDir "singboxffi.h") -Force
}

Write-Host "Staged singbox-ffi $Platform artifacts:"
Write-Host "  source: $artifactDir"
Write-Host "  plugin: $pluginArtifactDir"
