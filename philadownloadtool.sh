#!/bin/bash

# Usage: ./philadownloadtool.sh "URL"

# Function to extract sig and expire from URL
extract_params() {
    local url="$1"
    local sig=$(echo "$url" | grep -oP 'sig=\K[^&]+')
    local expire=$(echo "$url" | grep -oP 'expire=\K[^&]+')
    echo "$sig:$expire"
}

# Function to update files with new sig and expire
update_files() {
    local old_sig="$1"
    local old_expire="$2"
    local new_sig="$3"
    local new_expire="$4"
    local file_base="$5"
    
    # Update both main file and .aria2 control file if they exist
    for file in "$HOME/Downloads/${file_base}"*; do
        if [[ -f "$file" ]]; then
            # Create backup before modifying
            cp "$file" "${file}.bak"
            
            # Update parameters in the file
            sed -i "s/sig=${old_sig}/sig=${new_sig}/g" "$file"
            sed -i "s/expire=${old_expire}/expire=${new_expire}/g" "$file"
            
            echo "Updated parameters in $file"
        fi
    done
}

# Function to attempt download
download_attempt() {
    local url="$1"
    local file_name="$2"
    local http_base_url="${url%/*}"
    local ftp_base_url=$(echo "$http_base_url" | sed 's#^http\(s\)\?#ftp#')
    local ftp_url="${ftp_base_url}/${file_name}"

    # Extract initial sig and expire
    local params=$(extract_params "$url")
    local old_sig=$(echo "$params" | cut -d: -f1)
    local old_expire=$(echo "$params" | cut -d: -f2)

    # Try FTP first
    if curl --output /dev/null --silent --head --fail "${ftp_url}"; then
        echo "FTP alternative found. Downloading with aria2c using FTP."
        aria2c -x10 -s10 -d ~/Downloads -o "${file_name}" "${ftp_url}"
        return $?
    else
        echo "No FTP alternative found. Downloading with aria2c using HTTP."
        aria2c -x10 -s10 -d ~/Downloads -o "${file_name}" "${url}"
        return $?
    fi
}

# Main execution
url="$1"
if [ -z "$url" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

file_name="${url##*/}"
file_base="${file_name%.aria2}"  # Remove .aria2 if present

# First download attempt
if ! download_attempt "$url" "$file_name"; then
    echo "Download failed or interrupted. Checking for expired URL..."
    
    # Ask user for new URL if the old one expired
    echo "Please provide the new URL if available (or press Enter to exit):"
    read new_url
    
    if [ -n "$new_url" ]; then
        # Extract old and new parameters
        old_params=$(extract_params "$url")
        new_params=$(extract_params "$new_url")
        
        old_sig=$(echo "$old_params" | cut -d: -f1)
        old_expire=$(echo "$old_params" | cut -d: -f2)
        new_sig=$(echo "$new_params" | cut -d: -f1)
        new_expire=$(echo "$new_params" | cut -d: -f2)
        
        # Update existing files with new parameters
        update_files "$old_sig" "$old_expire" "$new_sig" "$new_expire" "$file_base"
        
        # Retry download with new URL
        echo "Resuming download with updated URL..."
        download_attempt "$new_url" "$file_name"
    else
        echo "No new URL provided. Exiting."
        exit 1
    fi
fi