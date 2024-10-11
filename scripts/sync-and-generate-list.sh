#!/bin/bash

# List all remotes
remotes=$(rclone listremotes)

# Create a temporary file to store all file lists
temp_file="docs/file-list.json"
echo "[]" > $temp_file

# Google Drive base URL
gdrive_base_url="https://drive.google.com/uc?export=download&id="

# OneDrive base URL (example, you may need to customize it)
onedrive_base_url="https://onedrive.live.com/download?cid="

# Function to generate Google Drive file ID
get_gdrive_file_id() {
    file_path="$1"
    echo "$file_path" | sed -e 's/.*\/\([^\/]*\)$/\1/'  # Extract file ID from path
}

# Function to generate OneDrive file URL
get_onedrive_file_url() {
    file_path="$1"
    echo "$onedrive_base_url$file_path"  # Assuming path is correct, might need customization
}

# Iterate through each remote and list files
for remote in $remotes; do
    case $remote in
        *gdrive*)
            rclone lsjson $remote --recursive | jq --arg gdrive_base_url "$gdrive_base_url" -r '.[] | {Path: .Path, Name: .Name, Url: ($gdrive_base_url + (.Path | @uri))}' >> $temp_file
            ;;
        *onedrive*)
            rclone lsjson $remote --recursive | jq --arg onedrive_base_url "$onedrive_base_url" -r '.[] | {Path: .Path, Name: .Name, Url: ($onedrive_base_url + (.Path | @uri))}' >> $temp_file
            ;;
        *)
            rclone lsjson $remote --recursive | jq --arg remote $remote -r '.[] | {Path: .Path, Name: .Name, Url: $remote + ":" + (.Path | @uri)}' >> $temp_file
            ;;
    esac
done
