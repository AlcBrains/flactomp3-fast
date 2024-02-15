#!/bin/bash
#===============================================================================
#          FILE:  flactomp3.sh
#         USAGE:  ./flactomp3.sh <folderName>
#
#   DESCRIPTION: Finds all flac files in a specified folder and converts them to mp3
#  REQUIREMENTS:  ffmpeg
#        AUTHOR:  Christopher K.
#       CREATED:  12/04/2021
#===============================================================================

#just in case
trap "exit" INT

# Script name
scriptName=$0

# Usage function
function usage {
    echo "usage: $scriptName <folder>"
    echo "    <folder>: the folder in which the script will search for any FLAC files"
    echo "              to convert to MP3"
    exit 1
}

# Check for arguments 
[ -z "$1" ] && { usage; }

# Check if directory exists
[ ! -d "$1" ] && echo "Directory $1 does not exist. Exiting..." >&2 && exit 1

# Check if ffmpeg is installed
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "Error: ffmpeg is not installed. Exiting..."; exit 1; }

# Directory containing FLAC files
fullDir=$(readlink -f "$1")

# Find all FLAC files
flacFiles=("$fullDir"/*.flac)
[ ${#flacFiles[@]} -eq 0 ] && echo "Directory $fullDir has no FLAC files. Exiting..." >&2 && exit 1

# Convert function
convert_to_mp3() {
    inFile="$1"
    outFile="${inFile%.flac}.mp3"
    ffmpeg -y -i "$inFile" -hide_banner -loglevel error -b:a 320k "$outFile"
}

export -f convert_to_mp3

# Parallelize conversion
echo "Converting FLAC files to MP3..."
parallel -j $(nproc) convert_to_mp3 ::: "${flacFiles[@]}"

echo "Conversion completed successfully."