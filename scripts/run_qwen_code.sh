#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export QWEN_CODE_LANG="${QWEN_CODE_LANG:-ru-RU}"

if ! command -v qwen >/dev/null 2>&1; then
  echo "Qwen Code CLI is not installed."
  echo "Install it with: npm install -g @qwen-code/qwen-code@latest"
  exit 1
fi

if [[ -z "${QWEN_API_KEY:-}" ]]; then
  TOKEN="$(python3 - <<'PY'
import json
from pathlib import Path

credentials_path = Path("credentials.json")
if not credentials_path.exists():
    raise SystemExit("credentials.json not found. Run: cp credentials.example.json credentials.json")

data = json.loads(credentials_path.read_text(encoding="utf-8"))
token = data.get("sessions", [{}])[0].get("qwen_credentials", {}).get("access_token")
if not token or token == "PASTE_YOUR_TOKEN_HERE":
    raise SystemExit("Qwen token is empty. Edit credentials.json first.")

print(token)
PY
)"
  export QWEN_API_KEY="$TOKEN"
fi

exec qwen \
  --auth-type openai \
  --model qwen3.6-plus \
  --openai-base-url "https://qwen.aikit.club/v1" \
  --openai-api-key "$QWEN_API_KEY" \
  --append-system-prompt "Treat ${ROOT_DIR} as the only project root. Resolve all relative paths against ${ROOT_DIR}. Never create, read, or modify files outside ${ROOT_DIR} unless the user explicitly asks for an absolute path outside the project. Always answer in Russian unless the user explicitly requests another language. If the user writes in Russian, do not switch to English." \
  "$@"
