#!/bin/bash
# Stream filter for Claude Code's stream-json output format.
# Extracts assistant text from JSON stream, displays it in the terminal,
# and writes the full raw stream to a log file.
#
# Usage: claude --output-format stream-json ... | stream-filter.sh <log-file>

LOG_FILE="${1:?Usage: stream-filter.sh <log-file>}"

# Ensure log file exists
> "$LOG_FILE"

while IFS= read -r line; do
  # Always write raw line to log
  echo "$line" >> "$LOG_FILE"

  # Try to extract and display assistant text content
  # stream-json emits JSON objects, one per line. We care about assistant messages.
  if echo "$line" | grep -q '"type"'; then
    # Extract text content from assistant messages
    TEXT=$(echo "$line" | python3 -c "
import sys, json
try:
    obj = json.load(sys.stdin)
    # Handle content_block_delta events (streaming text)
    if obj.get('type') == 'content_block_delta':
        delta = obj.get('delta', {})
        if delta.get('type') == 'text_delta':
            print(delta.get('text', ''), end='')
    # Handle result message with full content
    elif obj.get('type') == 'message':
        for block in obj.get('content', []):
            if block.get('type') == 'text':
                print(block.get('text', ''), end='')
except (json.JSONDecodeError, KeyError, TypeError):
    pass
" 2>/dev/null)
    if [[ -n "$TEXT" ]]; then
      printf '%s' "$TEXT"
    fi
  fi
done

# Final newline
echo ""
