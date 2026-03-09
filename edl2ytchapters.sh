#!/usr/bin/env bash
# edl2ytchapters.sh
# Converts one or more Premiere Pro EDL exports to YouTube chapter timestamps.
#
# Usage:
#   ./edl2ytchapters.sh Album1.edl Album2.edl ...
#   ./edl2ytchapters.sh *.edl
#
# Output: a .txt file named after each EDL, saved in the same folder as that EDL.
# Requires: bash 4+, no external dependencies.

set -euo pipefail

if [[ $# -eq 0 ]]; then
    # No args -- scan the script's own directory for .edl files
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    mapfile -t EDL_FILES < <(find "$SCRIPT_DIR" -maxdepth 1 -iname "*.edl" | sort)
    if [[ ${#EDL_FILES[@]} -eq 0 ]]; then
        echo "ERROR: No .edl files found. Pass files as arguments or drop them in the script folder."
        exit 1
    fi
else
    EDL_FILES=("$@")
fi

process_edl() {
    local edl_file="$1"
    local edl_dir
    edl_dir="$(dirname "$edl_file")"
    local edl_base
    edl_base="$(basename "$edl_file")"
    local out_name="${edl_base%.*}.txt"
    local out_path="$edl_dir/$out_name"

    echo ""
    echo "Processing: $edl_base"

    local output=""
    local start_time=""
    local prev_was_track=0

    while IFS= read -r raw_line; do
        local line
        line="$(echo "$raw_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

        # Match A1 audio track lines and capture the third timecode (HH:MM:SS), drop frames
        if [[ "$line" =~ ^[0-9]+[[:space:]]+AX[[:space:]]+A[[:space:]]+C[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+([0-9]{2}:[0-9]{2}:[0-9]{2}):[0-9]{2}[[:space:]] ]]; then
            start_time="${BASH_REMATCH[1]}"
            prev_was_track=1

        # Clip name line immediately follows the track line
        elif [[ $prev_was_track -eq 1 && "$line" =~ ^\*[[:space:]]+FROM\ CLIP\ NAME:[[:space:]]*(.+) ]]; then
            local clip_name="${BASH_REMATCH[1]}"
            # Strip file extension
            clip_name="${clip_name%.*}"
            output+="$start_time - $clip_name"$'\n'
            prev_was_track=0

        elif [[ -n "$line" ]]; then
            prev_was_track=0
        fi

    done < "$edl_file"

    if [[ -z "$output" ]]; then
        echo "WARNING: No A1 track entries found in $edl_base -- skipping."
        return
    fi

    # Write output (trim trailing newline)
    printf '%s' "${output%$'\n'}" > "$out_path"

    local count
    count=$(echo "$output" | grep -c '^' || true)
    echo "Done! $count chapters written to: $out_path"
    echo ""
    echo "$output" | while IFS= read -r chapter; do
        [[ -n "$chapter" ]] && echo "  $chapter"
    done
}

for edl in "${EDL_FILES[@]}"; do
    process_edl "$edl"
done

echo ""
echo "All done."
