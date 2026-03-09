# EDL-to-YouTube-Chapters.ps1
# Converts one or more Premiere Pro EDL exports to YouTube chapter timestamps.
#
# Usage — three ways to run:
#   1. Drag and drop .edl files onto EDL2YTChapters.bat (Windows)
#   2. Pass .edl files as arguments: .\EDL-to-YouTube-Chapters.ps1 "Album1.edl" "Album2.edl"
#   3. Drop .edl files in the same folder as this script and run with no arguments
#
# Output: a .txt file named after each EDL, saved in the same folder as that EDL.
#
# Output format:
#   00:00:00 - Song Title
#   00:06:08 - Another Song
#   ...
#
# Requirements: PowerShell 7+
# Tested with EDL exports from Adobe Premiere Pro (A1 audio track, Drop Frame).

param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$EDLPaths
)

# --- Resolve which files to process ---
if ($EDLPaths -and $EDLPaths.Count -gt 0) {
    # Files passed as arguments (drag-and-drop via .bat, or direct CLI use)
    $edlFiles = $EDLPaths | ForEach-Object { Get-Item -LiteralPath $_ } | Where-Object { $_.Extension -ieq '.edl' }
} else {
    # Fallback: scan the script's own directory
    $edlFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.edl"
}

if (-not $edlFiles) {
    Write-Error "No .edl files found. Drop .edl files onto EDL2YTChapters.bat, or place them in the script folder."
    exit 1
}

# --- Process each EDL ---
foreach ($edlFile in $edlFiles) {
    Write-Host "`nProcessing: $($edlFile.Name)"

    $lines   = Get-Content -Path $edlFile.FullName
    $entries = [System.Collections.Generic.List[PSCustomObject]]::new()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()

        # Match A1 audio track lines: entry# AX A C <tc> <tc> <START_TC> <tc>
        # The third timecode is the track start time -- that's the YouTube chapter time.
        if ($line -match '^\d+\s+AX\s+A\s+C\s+\S+\s+\S+\s+(\d{2}:\d{2}:\d{2}):\d{2}\s+\S+') {
            $startTime = $Matches[1]   # HH:MM:SS -- frame number intentionally dropped

            # Clip name is on the very next non-blank line
            $j = $i + 1
            while ($j -lt $lines.Count -and $lines[$j].Trim() -eq '') { $j++ }

            if ($j -lt $lines.Count -and $lines[$j] -match '\* FROM CLIP NAME:\s*(.+)') {
                $clipName = $Matches[1].Trim()
                # Strip file extension (.wav, .aiff, .mp3, etc.)
                $clipName = [System.IO.Path]::GetFileNameWithoutExtension($clipName)

                $entries.Add([PSCustomObject]@{
                    Time = $startTime
                    Name = $clipName
                })
            }
        }
    }

    if ($entries.Count -eq 0) {
        Write-Warning "No A1 track entries found in $($edlFile.Name) -- skipping."
        continue
    }

    # Build output lines
    $outputLines = $entries | ForEach-Object { "$($_.Time) - $($_.Name)" }

    # Output .txt lands in the same folder as the source EDL
    $outputName = [System.IO.Path]::GetFileNameWithoutExtension($edlFile.Name) + ".txt"
    $outputPath = Join-Path $edlFile.DirectoryName $outputName

    $outputLines | Set-Content -Path $outputPath -Encoding UTF8

    Write-Host "Done! $($entries.Count) chapters written to: $outputPath"
    Write-Host ""
    $outputLines | ForEach-Object { Write-Host "  $_" }
}

Write-Host "`nAll done. Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
