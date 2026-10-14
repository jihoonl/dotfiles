#!/usr/bin/env bash
jq -r '.context_window | select(.current_usage) | "ctx \(.total_input_tokens / 1000 | floor)k/\(.context_window_size / 1000 | floor)k tokens (\(.used_percentage)%)"'
