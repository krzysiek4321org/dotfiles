#!/bin/sh

CONFIG_LIST_FILE=CONFIGLIST

while read -r file; do
    resfile="$HOME/.$file"
    if [ -L "$resfile" ]; then
        printf "%s: Uninstalling" "$file"
        rm "$resfile"
    else
        continue
    fi
    bakfile="${resfile}.bak"
    if [ -e "$bakfile" ]; then
        printf " and restoring previous"
        mv "$bakfile" "$resfile"
    fi
    printf "\n"
done < "$CONFIG_LIST_FILE"
