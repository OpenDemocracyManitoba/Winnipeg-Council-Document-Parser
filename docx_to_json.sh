#!/bin/bash
# Loop through .docx files found in a specified folder, outputing json
# files to a separate folder.
#
# Command line argument #1: DOCX Input Folder
# Command line argument #2: JSON Output Folder

for f in $1/*.docx
do
    echo "Processing $f file"
    echo "Writing $(basename "$f" .docx).json"
    ruby disposition_docx_to_json.rb $f > $2/$(basename "$f" .docx).json
done
