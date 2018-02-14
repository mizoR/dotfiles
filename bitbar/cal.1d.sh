#!/usr/bin/env bash

echo "📅"
echo "---"

cal -h -3 | while IFS= read -r i; do echo ". $i | font=courier color=black"; done
