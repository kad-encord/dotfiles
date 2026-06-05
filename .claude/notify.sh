#!/bin/bash
PROJECT="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)"
/opt/homebrew/bin/terminal-notifier \
  -title "Claude · ${PROJECT:-agent}" \
  -message "${1:-needs you}"
