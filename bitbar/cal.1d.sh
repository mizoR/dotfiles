#!/usr/bin/env bash

echo "📅"
echo "---"

cal -h -3 | while IFS= read -r i; do echo "$i | trim=false font=courier color=black"; done
