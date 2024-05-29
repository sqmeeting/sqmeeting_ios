#!/bin/bash

# clean old files
rm -rf ../dist

xcodebuild clean -project frtc_sdk.xcodeproj
xcodebuild -target frtc_sdk -configuration Release -project frtc_sdk.xcodeproj
if [ $? -gt 0 ]; then
    echo "Failed to build frtc_sdk!"
    exit -1
fi

