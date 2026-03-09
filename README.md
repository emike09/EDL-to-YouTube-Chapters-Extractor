# EDL to YouTube Chapters

A lightweight PowerShell 7 script that converts an Adobe Premiere Pro EDL export into YouTube chapter timestamps — no plugins, no online tools, no LLMs required.

If you compose music albums or long-form videos in Premiere and publish them to YouTube, this script turns your EDL into a ready-to-paste chapter list in seconds.

## Output Example

```
00:00:00 - Afterglow Geometry
00:06:08 - Stone Basin at Dusk
00:11:43 - Sand Patterns Under Starlight
00:18:28 - Slickrock Mesas
00:24:20 - Breathing Mountains
...
```

Paste that directly into the YouTube description and chapters are live.

## Requirements

- **PowerShell 7+** (cross-platform: Windows, macOS, Linux)
- An EDL exported from **Adobe Premiere Pro** (A1 audio track)

## Usage

1. Export your sequence(s) from Premiere as EDL files:
   `File → Export → EDL...`

2. Drop one or more `.edl` files into the same folder as `EDL-to-YouTube-Chapters.ps1`.

3. Run the script:
   ```powershell
   .\EDL-to-YouTube-Chapters.ps1
   ```

4. A `.txt` file named after each EDL will appear in the same folder. Open, copy, paste into YouTube.

The script processes all `.edl` files in the folder in a single run — useful if you're batch converting a back-catalogue of albums at once.

## How It Works

Premiere EDL exports follow a consistent format. Each track entry looks like this:

```
001  AX       A     C        00:00:00:00 00:06:08:03 00:00:00:00 00:06:08:03
* FROM CLIP NAME: Afterglow Geometry.wav
```

The script:
- Matches lines belonging to the **A1 audio track** (`AX  A`)
- Extracts the **third timecode** on each line — the track start time
- Drops the trailing **frame number** (`:xx`), since YouTube chapters only need `HH:MM:SS`
- Strips the **file extension** from the clip name
- Writes everything out in YouTube chapter format

## Notes

- The first chapter **must start at `00:00:00`** for YouTube to recognize the chapter list. Premiere sequences that start at the beginning will produce this automatically.
- If your EDL has multiple tracks, only the **A1 audio track** entries are processed. Video and other tracks are ignored.
- Clip name extensions (`.wav`, `.aiff`, `.mp3`, etc.) are all handled automatically.
- All `.edl` files present in the folder are processed in a single run. Each gets its own `.txt` output file.

## License

MIT — do whatever you want with it.
