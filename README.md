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

---

## Files

| File | Purpose |
|---|---|
| `EDL-to-YouTube-Chapters.ps1` | Core script — PowerShell 7, all platforms |
| `EDL2YTChapters.bat` | Windows drag-and-drop launcher |
| `edl2ytchapters.sh` | Bash launcher for macOS / Linux |

---

# Usage

## Windows — Drag and Drop

1. Export your sequence(s) from Premiere: `File → Export → EDL...`
2. Place `EDL2YTChapters.bat` and `EDL-to-YouTube-Chapters.ps1` in the same folder anywhere on your machine.
3. Select one or more `.edl` files in Explorer and drag them onto `EDL2YTChapters.bat`.
4. A console window opens, processes each file, and waits for a keypress. A `.txt` file appears next to each source EDL.

> **First run only:** Windows may warn that the `.bat` is from an unknown publisher. Click **More info → Run anyway**. You can also right-click → Properties → Unblock on both files to suppress future warnings.

---

A file named after each EDL will appear in the same folder. Open, copy, paste into YouTube.

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
