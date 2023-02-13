#!/bin/bash

# Convert all .mkv h265 videos in the specified directory to h264 encoded .mp4 files

RED="\033[0;31m"
RESET="\033[0m"

out_dir="./"  # The directory to output the converted files to
single=""
help=0  # If true then the help message is displayed and the script exits
remove=0  # If true then the original files are removed

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--single) single="$2"; shift ;;
		--out) out_dir="$2"; shift ;;
		--remove) remove=1 ;;
		-h|--help) help=1 ;;
		--) shift; break ;;
	esac

	shift
done

if [[ "$help" == 1 ]]; then
	echo "Usage: convert.sh [--out output/dir/] [options]"
	echo ""
	echo "Converts all .mkv files in the current directory to h264 encoded .mp4 files"
	echo ""
	echo "Options:"
	echo "  --single    Convert a single file"
	echo "  --out       The directory to output the converted files to, relative to the file being converted (Defaults to ./)"
	echo "  -h, --help  Show this help message and exit"
	echo "  --remove    Remove the original files after conversion"
	exit 0
fi

function convert_file() {
	file="$1"

	echo "[+] Converting '$file'"

	file_dir=$(dirname "$file")
	file=$(basename "$file")

	cd "$file_dir"

	audio_format=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$file")
	video_format=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$file")

	if [[ "$video_format" == "h264" ]]; then
		echo "[-] Video is already h264 encoded, skipping..."
		continue
	fi

	if [[ "$video_format" != "hevc" ]]; then
		# NOTE: The below code _might_ work for av1 encoded videos, but I haven't tested it
		echo -e "${RED}[-] File format is $video_format, cannot auto convert...${RESET}"
		return
	fi

	if [[ "$audio_format" == "aac" ]]; then
		ffmpeg -loglevel panic -i "$file" -c:v libx264 -crf 23 -preset medium -c:a copy -movflags +faststart "${out_dir}/${file%.*}.mp4" >/dev/null
	else
		ffmpeg -loglevel panic -i "$file" -c:v libx264 -crf 23 -preset medium -c:a aac -movflags +faststart "${out_dir}/${file%.*}.mp4" >/dev/null
	fi

	[[ $remove == 1 ]] && rm -f "$file"
	cd -
}

processed=0

if [[ $single != "" ]]; then
	convert_file "$single"
	processed=1
else
	for file in *.mkv; do
		convert_file "$file"
		processed=$(( processed + 1 ))
	done
fi

echo "[+] Completed, processed $processed file(s)"
