#!/bin/bash

# Set strict error handling
set -euo pipefail

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [options] <YouTube_URL> <Download_Location>

Options:
    -q, --quality   <quality>    Set video quality (default: best)
                                Options: best, 1080p, 720p, 480p, 360p
    -a, --audio-only            Download audio only (highest quality)
    -f, --format    <format>    Specify custom format (e.g., 'bestvideo+bestaudio')
    -s, --subtitle             Download subtitles (if available)
    -h, --help                 Show this help message

Speed Optimizations Enabled:
    - Multi-threaded fragment downloads (4 threads)
    - Aria2c external downloader for faster downloads
    - Optimized buffering and chunk size
    - Concurrent fragment downloads
    
Example:
    $(basename "$0") -q 1080p "https://youtube.com/watch?v=xxxx" "/downloads"
    $(basename "$0") -a "https://youtube.com/watch?v=xxxx" "/downloads"
EOF
}

# Initialize default values
QUALITY="best"
FORMAT='bestvideo+bestaudio/best'
AUDIO_ONLY=false
SUBTITLES=false
ADDITIONAL_FLAGS=()

# Speed optimization flags
SPEED_FLAGS=(
    "--no-playlist"                 # Prevent automatic playlist downloading
    "--concurrent-fragments" "4"    # Download up to 4 fragments simultaneously
    "--buffer-size" "16K"           # Optimize buffer size
    "--http-chunk-size" "10M"       # Larger chunk size for faster downloads
    "--downloader" "aria2c"         # Use aria2c for downloads
    "--downloader-args" "aria2c:-x 16 -s 16 -k 1M" # aria2c optimization args
    "--retries" "infinite"          # Retry infinitely on network errors
    "--fragment-retries" "infinite" # Retry infinitely on fragment errors
    "--skip-unavailable-fragments"  # Skip unavailable fragments
    "--no-abort-on-error"           # Don't abort on download errors
    "--merge-output-format" "mp4"   # Merge into MP4 container
)

# Argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quality)
            case $2 in
                1080p) FORMAT='bestvideo[height<=1080]+bestaudio/best[height<=1080]/best';;
                720p)  FORMAT='bestvideo[height<=720]+bestaudio/best[height<=720]/best';;
                480p)  FORMAT='bestvideo[height<=480]+bestaudio/best[height<=480]/best';;
                360p)  FORMAT='bestvideo[height<=360]+bestaudio/best[height<=360]/best';;
                best)  FORMAT='bestvideo+bestaudio/best';;
                *)     echo "Invalid quality option: $2"; exit 1;;
            esac
            shift 2
            ;;
        -a|--audio-only)
            FORMAT='bestaudio'
            AUDIO_ONLY=true
            ADDITIONAL_FLAGS+=("-x" "--audio-format" "m4a")
            shift
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -s|--subtitle)
            SUBTITLES=true
            ADDITIONAL_FLAGS+=("--write-sub" "--sub-lang" "en")
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Input validation
if [ "$#" -ne 2 ]; then
    show_help
    exit 1
fi

URL="$1"
DOWNLOAD_LOCATION="$2"

if ! [[ "$URL" =~ ^https?:// ]]; then
    echo "Error: Invalid URL format. URL must start with http:// or https://"
    exit 1
fi

# Fixed error handling block (added space before {)
REAL_PATH=$(realpath -e "$DOWNLOAD_LOCATION" 2>/dev/null) || {
    echo "Error: Invalid path or broken symbolic link: $DOWNLOAD_LOCATION"
    exit 1
}

if [ ! -d "$REAL_PATH" ] || [ ! -w "$REAL_PATH" ]; then
    echo "Error: Path does not exist or is not writable: $REAL_PATH"
    exit 1
fi

# Check for required tools
for cmd in yt-dlp aria2c; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Check for ffmpeg if needed
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Warning: ffmpeg is not installed. Merging/format conversion might fail."
fi

OUTPUT_TEMPLATE="$REAL_PATH/%(title)s.%(ext)s"

# Show download configuration
echo "Download Configuration:"
echo "URL: $URL"
echo "Save Location: $REAL_PATH"
echo "Format: $FORMAT"
echo "Audio Only: $AUDIO_ONLY"
echo "Subtitles: $SUBTITLES"
echo "Speed Optimizations: Enabled (4 threads, aria2c)"
echo "Starting download..."

# Run yt-dlp with speed optimizations
if ! yt-dlp -f "$FORMAT" \
            --output "$OUTPUT_TEMPLATE" \
            --no-warnings \
            --progress \
            "${SPEED_FLAGS[@]}" \
            "${ADDITIONAL_FLAGS[@]}" \
            "$URL"; then
    echo "Error: Download failed. Check the URL or try a different format."
    echo "Use 'yt-dlp --list-formats $URL' to see available formats."
    exit 1
fi

echo "Download completed successfully and saved to: $REAL_PATH"

# If you get format errors, try listing available formats first:
# yt-dlp --list-formats "https://youtu.be/cPpMQA3eUwY"

# Then use a specific format code with -f
# ./yt-downloader.sh -f 22 "https://youtu.be/cPpMQA3eUwY" "$HOME/Downloads"
# ./yt-downloader.sh -q 1080p "https://youtu.be/cPpMQA3eUwY " "/path/to/download"