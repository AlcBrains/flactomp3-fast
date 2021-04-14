#!/bin/bash
#===============================================================================
#          FILE:  test.sh
#         USAGE:  ./test.sh <folderName>
#
#   DESCRIPTION: Finds all flac files in a specified folder and converts them to mp3
#  REQUIREMENTS:  ffmpeg
#        AUTHOR:  Christopher K.
#       CREATED:  12/04/2021
#===============================================================================

#just in case
trap "exit" INT

scriptName=$0

echo "FLAC to mp3 Converter"

function usage {
    echo "usage: $scriptName <folder>"
    echo "	<folder>: the folder in which the script will search for any FLAC files"
    echo "	to convert to MP3"
    exit 1
}

# Checking for arguments 
[ -z $1 ] && { usage; }

# If directory doesn't exist, exit
[ ! -d "$1" ] && echo "Directory $1 does not exist. Exiting..." && exit 1

# If missing ffmpeg, exit
[ ! -x "$(command -v ffmpeg)" ] && echo 'Error: ffmpeg is not installed. Exiting...' >&2 && exit 1

fullDir=$(readlink -f "$1")

echo "Scanning folder "$fullDir" for FLAC files..."
flacFiles=$(ls "$fullDir" | grep .flac | wc -l)
[ $flacFiles -lt 1 ] && echo "Directory "$fullDir" has no FLAC files. Exiting..." && exit 1

echo "Found $flacFiles files"

counter=0
pids=()
for inFile in "$fullDir"/*.flac; do
	let counter+=1
	# ah, sed: the crazy person's regex
	outFile=`echo "$inFile" | sed 's/\(.*\.\)flac/\1mp3/'`
 	# force overwrite, no banner only log if something goes wrong
	ffmpeg -y -i "$inFile" -hide_banner -loglevel error -b:a 320k "$outFile" &
	pids+=($!)
done

done=0
total=${#pids[@]}
echo "Waiting for ffmpeg to complete all processes ($done/$total done)"

for pid in ${pids[@]}; do
	wait $pid
	let done+=1
	echo "Finished parsing $done/$total "
done

echo "All done!"