#!/bin/bash
# Highlight the focused workspace. $1 is the workspace id this item represents;
# FOCUSED_WORKSPACE comes from the aerospace_workspace_change event that
# ~/.aerospace.toml fires via exec-on-workspace-change.
#
# Colours follow i3's bar (config:594-596), where the FOCUSED workspace is the
# darker one — focused bg #222222, inactive bg #5f676a.

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" background.color=0xff222222 label.color=0xffeeeeee
else
    sketchybar --set "$NAME" background.color=0xff5f676a label.color=0xffa9a9a9
fi
