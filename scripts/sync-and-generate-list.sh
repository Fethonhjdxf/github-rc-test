#!/bin/bash

# List all remotes
remotes=$(rclone listremotes)

# Create a temporary file to store all file lists
temp_file="docs/file-list.json"
echo "[]" > $temp_file

# Iterate through each remote and list files
for remote in $remotes; do
    rclone lsjson $remote --recursive | jq -s '.[]' >> $temp_file
done
