#!/bin/bash
IFS=$','
GOOGLE_PHOTOS_DIR=~/"Pictures/Google Photos Backup"

# Current Directory
CWD=$(pwd)

# Script Directory
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Change to working DIR
# cd ~/Pictures/Google\ Photos\ Backup/
cd "${GOOGLE_PHOTOS_DIR}"

# Get list of duplicate files
#find . -iname "*-00?.JPG"
#find . -iname "*-00?.MOV"

# Whitespace-safe EXCEPT newlines
find . -iname '*-00?.MOV' -print0 |
while IFS= read -r -d $'\0' line; do
	dup_file="${line}"
	file_ext="${dup_file##*.}"
	initial_file="${dup_file%-*}.${dup_file##*.}"
	#echo "diff $initial_file $dup_file"
	diff $initial_file $dup_file > /dev/null 2>&1
	error=$?
	if [ $error -eq 0 ]
	then
		echo "$initial_file and $dup_file are the same file"
		rm $dup_file
	elif [ $error -ge 1 ]
	then
		echo "$initial_file and $dup_file differ"
		#break
	else
		echo "diff $initial_file $dup_file"
		echo "There was something wrong with the diff command"
	fi
done

# Set dup_file=./2016-10-03/IMG_8260-001.JPG
# Get file_ext=JPG
#file_ext="${dup_file##*.}"
#initial_file="${dup_file%-*}.${dup_file##*.}"

#file_ext="${stringZ##*.}"
#file_name="${stringZ%.*}"
#filename="${stringZ##*/}"
# diff
