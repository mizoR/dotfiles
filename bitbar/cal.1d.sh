#!/usr/bin/env bash

year=$(date +%Y)
next_year=$((year+1))

echo "📅"
echo "---"

cal "$year" | while IFS= read -r i; do echo ". $i | font=courier"; done
cal "$next_year" | while IFS= read -r i; do echo ". $i | font=courier"; done
