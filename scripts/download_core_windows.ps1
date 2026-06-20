param(
    [string]$Repo = "loafman1120/singbox-ffi",
    [string]$Workflow = "Build",
    [string]$Branch = "main",
    [string]$Arch,
    [switch]$SkipDownload
)

$script = Join-Path $PSScriptRoot "download_core_desktop.ps1"
$scriptArgs = @{
    Platform = "windows"
    Repo = $Repo
    Workflow = $Workflow
    Branch = $Branch
}

if ($Arch) {
    $scriptArgs.Arch = $Arch
}
if ($SkipDownload) {
    $scriptArgs.SkipDownload = $true
}

& $script @scriptArgs
