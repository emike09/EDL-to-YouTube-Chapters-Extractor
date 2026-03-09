# EDL-to-YouTube-Chapters.ps1
# Converts one or more Premiere Pro EDL exports to YouTube chapter timestamps.
#
# Usage:
#   1. Drop any number of .edl files in the same folder as this script.
#   2. Run: .\EDL-to-YouTube-Chapters.ps1
#   3. A .txt file named after each EDL will appear in the same folder.
#
# Output format:
#   00:00:00 - Song Title
#   00:06:08 - Another Song
#   ...
#
# Requirements: PowerShell 7+
# Tested with EDL exports from Adobe Premiere Pro (A1 audio track, Drop Frame).

$scriptDir = $PSScriptRoot

# Find all .edl files in the script's directory
$edlFiles = Get-ChildItem -Path $scriptDir -Filter "*.edl"

if (-not $edlFiles) {
    Write-Error "No .edl files found in $scriptDir"
    exit 1
}

foreach ($edlFile in $edlFiles) {
    Write-Host "`nProcessing: $($edlFile.Name)"

    $lines   = Get-Content -Path $edlFile.FullName
    $entries = [System.Collections.Generic.List[PSCustomObject]]::new()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()

        # Match A1 audio track lines: entry# AX A C <tc> <tc> <START_TC> <tc>
        # The third timecode is the track start time — that's the YouTube chapter time.
        if ($line -match '^\d+\s+AX\s+A\s+C\s+\S+\s+\S+\s+(\d{2}:\d{2}:\d{2}):\d{2}\s+\S+') {
            $startTime = $Matches[1]   # HH:MM:SS — frame number intentionally dropped

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
        Write-Warning "No A1 track entries found in $($edlFile.Name) — skipping."
        continue
    }

    # Build output lines
    $outputLines = $entries | ForEach-Object { "$($_.Time) - $($_.Name)" }

    # Write to {EDL Filename}.txt in the same folder as the script
    $outputName = [System.IO.Path]::GetFileNameWithoutExtension($edlFile.Name) + ".txt"
    $outputPath = Join-Path $scriptDir $outputName

    $outputLines | Set-Content -Path $outputPath -Encoding UTF8

    Write-Host "Done! $($entries.Count) chapters written to: $outputName"
    Write-Host ""
    $outputLines | ForEach-Object { Write-Host "  $_" }
}
