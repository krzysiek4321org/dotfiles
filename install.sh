#!/bin/sh

CONFIG_LIST_FILE=CONFIGLIST


while read -r file; do
    if [ ! -e "$file" ]; then
        echo "Error: $file doesn't exist! Skipping"
        continue
    fi
    resfile="$HOME/.$file"
    if [ -e "$resfile" ]; then
        if [ -L "$resfile" ]; then
            rm "$resfile"
        else
            mv "$resfile" "${resfile}.bak"
        fi
    fi
    absolutefile=$(realpath "$file")
    echo "Installing $file"
    ln -s "$absolutefile" "$resfile" 
done < "$CONFIG_LIST_FILE"
