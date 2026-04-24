from __future__ import annotations

from qwen_client import QwenClient, strip_provider_metadata


def main() -> None:
    client = QwenClient()
    messages = [
        {
            "role": "system",
            "content": "Ты полезный AI-помощник. Всегда отвечай на русском языке, коротко и по делу.",
        }
    ]

    print("Qwen chat. Напиши exit для выхода.")

    while True:
        user_text = input("\nВы: ").strip()
        if user_text.lower() in {"exit", "quit"}:
            break
        if not user_text:
            continue

        messages.append({"role": "user", "content": user_text})
        response = client.chat_completion(messages)
        answer = response.get("choices", [{}])[0].get("message", {}).get("content", "")
        answer = strip_provider_metadata(answer)
        messages.append({"role": "assistant", "content": answer})
        print(f"\nQwen: {answer}")


if __name__ == "__main__":
    main()
