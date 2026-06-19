$ErrorActionPreference = "Stop"

$repo = "loafman1120/singbox-ffi"
$workflow = "build.yml"
$artifactName = "singboxffi-windows-amd64"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "native/windows"

New-Item -ItemType Directory -Force $outDir | Out-Null
$runs = gh run list --repo $repo --workflow $workflow --branch main --status success --limit 1 --json databaseId | ConvertFrom-Json
if (-not $runs -or $runs.Count -eq 0) {
    throw "No successful $repo $workflow run found"
}

gh run download $runs[0].databaseId --repo $repo --name $artifactName --dir $outDir

Write-Host "Downloaded singbox-ffi shared artifact to $outDir"
