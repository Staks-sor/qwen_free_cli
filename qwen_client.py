from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

import requests

from config import API_BASE_URL, DEFAULT_MODEL, DEFAULT_TEMPERATURE, DEFAULT_TIMEOUT


DETAILS_BLOCK_RE = re.compile(
    r"\s*<details>\s*<summary><\/summary>\s*```[\s\S]*?Response ID:[\s\S]*?Request ID:[\s\S]*?```\s*<\/details>\s*$",
    re.MULTILINE,
)


def strip_provider_metadata(text: str) -> str:
    return DETAILS_BLOCK_RE.sub("", text or "").strip()


class QwenClient:
    def __init__(self, api_token: str | None = None, base_url: str = API_BASE_URL):
        self.api_token = api_token or self._load_token()
        self.base_url = base_url.rstrip("/")

        if not self.api_token:
            raise RuntimeError(
                "Qwen token not found. Set QWEN_API_KEY or edit credentials.json."
            )

    def _load_token(self) -> str | None:
        env_token = os.getenv("QWEN_API_KEY") or os.getenv("QWEN_AIKIT_API_KEY")
        if env_token:
            return env_token

        for credentials_path in (
            Path("credentials.json"),
            Path(__file__).resolve().parent / "credentials.json",
        ):
            if not credentials_path.exists():
                continue

            data = json.loads(credentials_path.read_text(encoding="utf-8"))
            token = data.get("sessions", [{}])[0].get("qwen_credentials", {}).get("access_token")
            if token:
                return token

        return None

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Origin": "https://chat.qwen.ai",
            "Referer": "https://chat.qwen.ai/",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "application/json",
        }

    def chat_completion(
        self,
        messages: list[dict[str, str]],
        model: str = DEFAULT_MODEL,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int | None = None,
    ) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "stream": False,
        }
        if max_tokens is not None:
            payload["max_tokens"] = max_tokens

        response = requests.post(
            f"{self.base_url}/chat/completions",
            headers=self._headers(),
            json=payload,
            timeout=DEFAULT_TIMEOUT,
        )

        if response.status_code != 200:
            raise RuntimeError(f"Qwen API error {response.status_code}: {response.text}")

        return response.json()

    def simple_ask(self, prompt: str, system_prompt: str = "Отвечай на русском языке.") -> str:
        response = self.chat_completion(
            [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt},
            ]
        )
        content = response.get("choices", [{}])[0].get("message", {}).get("content", "")
        return strip_provider_metadata(content)
