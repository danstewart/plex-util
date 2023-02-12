# Plex Util

Collection of scripts to help managing plex content.  

### Details

| Script | Description |
| ----- | -------- |
| `convert.sh` | Converts media files from h265 to h265 |
| `find-h265.sh` | Finds all h265 media files in a given directory |
| `seedbox-sync.sh` | Sync to and from a seedbox |


### Set up

Some scripts rely on a `.env` file existing in the script directory, it should contain:
```
SEEDBOX_USER="username"
SEEDBOX_HOST="hostname"
```
