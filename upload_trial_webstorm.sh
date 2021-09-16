#!/bin/bash

rm -rf ~/.config/JetBrains/WebStorm*/eval &&
sed -i -E 's/<property name=\"evl.*\".*\/>//' ~/.config/JetBrains/WebStorm*/options/other.xml &&
rm -rf ~/.java/.userPrefs/jetbrains/webstorm
