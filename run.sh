#!/bin/bash
# Forge requires a configured set of both JVM and program arguments.
# Add custom JVM arguments to the user_jvm_args.txt
# Add custom program arguments {such as nogui} to this file in the next line before the "$@" or
#  pass them to this script directly

currentHash=$(cat default-config.hash 2>/dev/null || echo "")
API_URL="https://api.github.com/repos/Emergent-Civilization/Neolithic/branches/dev"
newHash=$(curl -Ls "$API_URL" | grep -o '"sha": "[^"]*"' | head -1 | cut -d\" -f4)

if [ "$currentHash" != "$newHash" ]; then
    rm -rf Emergent-Civilization-Neolithic-* default-config.zip
    curl -L -o Neolithic.zip https://api.github.com/repos/Emergent-Civilization/Neolithic/zipball/dev && \
    jar xf Neolithic.zip && \
    EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "Emergent-Civilization-Neolithic-*" | head -n 1) && \
    cp -r "$EXTRACTED_DIR"/* . && \
    cp -r "$EXTRACTED_DIR"/.[^.]* . 2>/dev/null || true && \
    rm -rf "$EXTRACTED_DIR" Neolithic.zip Neolithic.hash && \
    echo "$newHash" > Neolithic.hash
fi

#Uncomment the next line to sync mods from a pakku server-pack export

#java -Xmx5g -jar pakku.jar export 

# Local Server-Pack Extraction (Condensed Logic)
SERVERPACK_ZIP="/home/container/build/serverpack/TerraFirmaGreg-Modern-DEV.zip"
TEMP_DIR="./.tmp_mod_extract_$$" && mkdir -p "$TEMP_DIR" 2>/dev/null
if [ -f "$SERVERPACK_ZIP" ] && [ -d "$TEMP_DIR" ]; then
    (cd "$TEMP_DIR" && jar xf "$SERVERPACK_ZIP") && \
    SOURCE_MODS_PATH=$(find "$TEMP_DIR" -maxdepth 2 -type d -name "mods" | head -n 1) && \
    rm -rf mods && \
    cp -r "$SOURCE_MODS_PATH" . && \
    rm -rf "$TEMP_DIR"
fi


java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.10/unix_args.txt "$@"

