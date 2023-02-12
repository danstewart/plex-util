#!/bin/bash

# Convert all .mkv h265 videos in the specified directory to h264 encoded .mp4 files

RED="\033[0;31m"
RESET="\033[0m"

out_dir="./"  # The directory to output the converted files to
help=0  # If true then the help message is displayed and the script exits
remove=0  # If true then the original files are removed

while [[ "$#" -gt 0 ]]; do
	case "$1" in
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
	echo "  --out       The directory to output the converted files to (Defaults to ./)"
	echo "  -h, --help  Show this help message and exit"
	echo "  --remove    Remove the original files after conversion"
	exit 0
fi

processed=0
for file in *.mkv; do
	echo "[+] Converting '$file'"

	audio_format=$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$file")
	video_format=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$file")

	if [[ "$video_format" == "h264" ]]; then
		echo "[-] Video is already h264 encoded, skipping..."
		continue
	fi

	if [[ "$video_format" != "h265" ]]; then
		# NOTE: The below code _might_ work for av1 encoded videos, but I haven't tested it
		echo -e "${RED}[-] File format is $format, cannot auto convert...${RESET}"
		continue
	fi

	if [[ "$audio_format" == "aac" ]]; then
		ffmpeg -loglevel panic -i "$file" -c:v libx264 -crf 23 -preset medium -c:a copy -movflags +faststart "${out_dir}/${f%.*}.mp4" >/dev/null
	else
		ffmpeg -loglevel panic -i "$file" -c:v libx264 -crf 23 -preset medium -c:a aac -movflags +faststart "${out_dir}/${f%.*}.mp4" >/dev/null
	fi

	processed=$(( processed + 1 ))
	[[ $remove == 1 ]] && rm -f "$file"
done


echo "[+] Completed, processed $processed file(s)"
