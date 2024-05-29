#!/bin/bash

POD_PRJ=Pods/Pods.xcodeproj
xcodebuild clean -project ${POD_PRJ}
xcodebuild -alltargets -configuration Debug -project ${POD_PRJ}
xcodebuild -alltargets -configuration Release -project ${POD_PRJ}

