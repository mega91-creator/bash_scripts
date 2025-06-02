#!/bin/bash

# Usage: ./download_with_ftp_alternative.sh "http://example.com/path/to/file"

url="$1"
http_base_url="${url%/*}"
ftp_base_url=$(echo "$http_base_url" | sed 's#^http\(s\)\?#ftp#')

file_name="${url##*/}"
ftp_url="${ftp_base_url}/${file_name}"

# Check if the FTP alternative exists
if curl --output /dev/null --silent --head --fail "${ftp_url}"; then
    echo "FTP alternative found. Downloading with aria2c using FTP."
    aria2c -x10 -s10 -d ~/Downloads -o "${file_name}" "${ftp_url}"
else
    echo "No FTP alternative found. Downloading with aria2c using the original URL."
    aria2c -x10 -s10 -d ~/Downloads -o "${file_name}" "${url}"
fi