#!/bin/bash
# make sure you always put $f in double quotes to avoid any nasty surprises i.e. "$f"
for f in $@
do
    echo "Processing $f file"
    echo "Writing $(basename "$f" .docx).json"
done
