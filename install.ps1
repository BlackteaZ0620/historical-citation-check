$ErrorActionPreference = "Stop"

$SkillName = "historical-citation-check"
$RepoZipUrl = "https://github.com/BlackteaZ0620/historical-citation-check/archive/refs/heads/main.zip"
$InstallRoot = Join-Path $HOME ".codex\skills"
$InstallDir = Join-Path $InstallRoot $SkillName
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("historical-citation-check-" + [System.Guid]::NewGuid().ToString("N"))
$ZipPath = Join-Path $TempDir "skill.zip"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null

try {
    Write-Host "Downloading historical-citation-check..."
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $ZipPath

    Expand-Archive -LiteralPath $ZipPath -DestinationPath $TempDir -Force
    $ExtractedRoot = Get-ChildItem -LiteralPath $TempDir -Directory |
        Where-Object { $_.Name -like "historical-citation-check-*" } |
        Select-Object -First 1

    if (-not $ExtractedRoot) {
        throw "Could not find extracted skill folder."
    }

    if (Test-Path $InstallDir) {
        Remove-Item -LiteralPath $InstallDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    $FilesToCopy = @("SKILL.md", "README.md", "历史研究注释.docx")
    foreach ($FileName in $FilesToCopy) {
        $Source = Join-Path $ExtractedRoot.FullName $FileName
        if (Test-Path $Source) {
            Copy-Item -LiteralPath $Source -Destination (Join-Path $InstallDir $FileName) -Force
        }
    }

    if (-not (Test-Path (Join-Path $InstallDir "SKILL.md"))) {
        throw "SKILL.md was not installed. Please check the GitHub repository contents."
    }

    Write-Host ""
    Write-Host "historical-citation-check installed successfully."
    Write-Host "Installed to: $InstallDir"
    Write-Host "Restart Codex or open a new conversation before using the skill."
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
