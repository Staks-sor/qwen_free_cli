#!/usr/bin/env bash
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="${QWEN_PROJECT_ROOT:-$(cd "$TOOL_DIR/.." && pwd)}"
cd "$PROJECT_ROOT"

export QWEN_CODE_LANG="${QWEN_CODE_LANG:-ru}"
export LANG="${LANG:-ru_RU.UTF-8}"
export LC_ALL="${LC_ALL:-ru_RU.UTF-8}"

if ! command -v qwen >/dev/null 2>&1; then
  echo "Qwen Code CLI is not installed."
  echo "Install it with: npm install -g @qwen-code/qwen-code@latest"
  exit 1
fi

if [[ -z "${QWEN_API_KEY:-}" ]]; then
  export QWEN_TOOL_DIR="$TOOL_DIR"
  TOKEN="$(python3 - <<'PY'
import json
from pathlib import Path

import os

credentials_path = Path(os.environ["QWEN_TOOL_DIR"]) / "credentials.json"
if not credentials_path.exists():
    raise SystemExit("credentials.json not found in qwen_free_cli.")

data = json.loads(credentials_path.read_text(encoding="utf-8"))
token = data.get("sessions", [{}])[0].get("qwen_credentials", {}).get("access_token")
if not token or token == "PASTE_YOUR_TOKEN_HERE":
    raise SystemExit("Qwen token is empty. Edit credentials.json first.")

print(token)
PY
)"
  export QWEN_API_KEY="$TOKEN"
fi

export QWEN_AIKIT_API_KEY="${QWEN_AIKIT_API_KEY:-$QWEN_API_KEY}"

script -q /dev/null qwen \
  --auth-type openai \
  --model qwen3.6-plus \
  --openai-base-url "https://qwen.aikit.club/v1" \
  --openai-api-key "$QWEN_API_KEY" \
  --append-system-prompt "Ты русскоязычный coding agent. Always treat ${PROJECT_ROOT} as the only project root. Resolve all relative paths against ${PROJECT_ROOT}. The helper folder ${TOOL_DIR} contains Qwen launch files; do not edit it unless the user explicitly asks. Never create, read, or modify files outside ${PROJECT_ROOT} unless the user explicitly asks for an absolute path outside the project. Всегда отвечай на русском языке, если пользователь явно не попросил другой язык. Если пользователь пишет на русском, не переходи на английский. Не добавляй HTML-блоки, details, summary, Response ID или Request ID в ответы." \
  "$@" | python3 -c '
import sys

inside_details = False

for line in sys.stdin:
    line = line.replace("^D\b\b", "").replace("\x04", "")

    if "<details" in line:
        inside_details = True
        continue

    if inside_details:
        if "</details>" in line:
            inside_details = False
        continue

    sys.stdout.write(line)
    sys.stdout.flush()
'
