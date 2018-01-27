#!/bin/bash
# Loop through .docx files found in a specified folder, outputing json
# files to a separate folder.
#
# Command line argument #1: DOCX Input Folder
# Command line argument #2: JSON Output Folder

if [ "$#" -ne 2 ]; then
    echo "USAGE: $(basename $0) docx_input_folder json_output_folder"
    exit
fi

for f in $1/*.docx
do
    echo "Processing $f file"
    if [ -e $2/$(basename "$f" .docx).json ]
    then
        echo "File $(basename "$f" .docx).json exists. Skipping!"
    else
        echo "Writing $(basename "$f" .docx).json"
        ruby disposition_docx_to_json.rb $f > $2/$(basename "$f" .docx).json
    fi
done
