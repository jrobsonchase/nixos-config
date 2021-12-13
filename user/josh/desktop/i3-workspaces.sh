#!/usr/bin/env bash

for i in $HOME/.i3/workspaces.d/*.json; do
	workspace_name=$(basename -s .json "$i")
	i3-msg "workspace \"$workspace_name\"; append_layout \"$i\""
done

for i in $HOME/.i3/workspaces.d/*.sh; do
	$i
done

i3-msg "workspace 1"
