#!/usr/bin/env bash

help=0
source=""  # Either 'local' or 'remote'

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--source) source="$2"; shift ;;
		-h|--help) help=1 ;;
		--) shift; break ;;
	esac

	shift
done

if [[ $help == 1 ]] || [[ $source != "local" && $source != "remote" ]]; then
    echo "Usage: seedbox-sync.sh --source <local|remote> [options]"
    echo ""
    echo "Syncs all media between the seedbox and the local machine"
    echo ""
    echo "Options:"
    echo "  --source    The location to use as the source (ie. 'remote' means copy from the seedbox to local and 'local' means copy from local to seedbox)"
    echo "  -h, --help  Show this help message and exit"
    exit 0
fi

movie_source=""
movie_target=""
tv_source=""
tv_target=""

# Load .env
script_dir=$(dirname "$0")
[[ ! -f "$script_dir/.env" ]] && { echo "Missing .env file" && exit 1; }
set -o allexport
source "$script_dir/.env"
set +o allexport

if [[ $source == "local" ]]; then
    echo "Syncing from local to remote"
    movie_source="/mnt/passport/Plex/media/Movies/"
    tv_source="/mnt/passport/Plex/media/TV Shows/"

    movie_target="${SEEDBOX_USER}@${SEEDBOX_HOST}:~/media/Movies/"
    tv_target="${SEEDBOX_USER}@${SEEDBOX_HOST}:~/media/TV Shows/"
fi

if [[ $source == "remote" ]]; then
    echo "Syncing from remote to local"
    movie_source="${SEEDBOX_USER}@${SEEDBOX_HOST}:~/media/Movies/"
    tv_source="${SEEDBOX_USER}@${SEEDBOX_HOST}:~/media/TV Shows/"

    movie_target="/mnt/passport/Plex/media/Movies/"
    tv_target="/mnt/passport/Plex/media/TV Shows/"
fi

# Count down from 3 before starting to allow cancelling
for i in {3..1}; do
    echo "Starting in $i..."
    sleep 1
done

echo "=== SYNCING MOVIES ==="
rsync \
    --archive \
    --compress \
    --human-readable \
    --partial \
    --progress \
    --delete \
    --hard-links \
        "$movie_source" \
        "$movie_target"

echo "=== SYNCING TV SHOWS ==="
rsync \
    --archive \
    --compress \
    --human-readable \
    --partial \
    --progress \
    --delete \
    --hard-links \
        "$tv_source" \
        "$tv_target"

echo "=== SYNC COMPLETE ==="
