#!/usr/bin/env bash

location=""  # The directory to look in
convert=0    # If true then the files are converted to h264
help=0       # If true then the help message is displayed and the script exits

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--location) location="$2"; shift ;;
		--convert) convert=1 ;;
		-h|--help) help=1 ;;
		--) shift; break ;;
	esac

	shift
done

if [[ $help == 1 || $location == "" ]]; then
    echo "Usage: find-h265.sh [--location directory/] [options]"
    echo ""
    echo "Finds all h265 encoded videos in the specified directory"
    echo ""
    echo "Options:"
    echo "  --location     The directory to look in"
    echo "  --convert      Convert the files to h264 (NOTE: This will delete the original files)"
    echo "  -h, --help     Show this help message and exit"
    exit 0
fi

shopt -s globstar

for file in "$location"/**/*.mkv; do
    format=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$file");

    if [[ $format != "h264" ]]; then
        echo "File '$file' has format '$format'"

        if [[ $convert == 1 ]]; then
            script_dir=$(dirname "$0")
            "$script_dir/convert.sh" --out "$(dirname "$file")" --remove
        fi
    fi
done

echo "[+] Completed"
