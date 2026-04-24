# Qwen Code CLI Starter

Минимальный шаблон для запуска `Qwen Code CLI` как coding agent через OpenAI-compatible API.

Главная идея: `Qwen Code` запускается в терминале, получает API-ключ из локального `credentials.json` и работает с файлами текущего проекта.

## Что получится

После настройки можно открыть проект в PyCharm, VS Code или обычном терминале и запустить:

```bash
./scripts/run_qwen_code.sh
```

Дальше агенту можно писать обычные задачи:

```text
Объясни структуру проекта.
```

```text
Создай папку ./demo и файл ./demo/test.txt с текстом "hello".
```

```text
Создай файл ./src/main.py с простой функцией main() и объясни, что сделал.
```

## Как это работает

`Qwen Code CLI` - это не сама модель. Это терминальный агент для программирования.

Схема такая:

```text
Qwen Code CLI
  -> берет access_token из credentials.json
  -> подключается к https://qwen.aikit.club/v1
  -> использует модель qwen3.6-plus
  -> читает и меняет файлы текущего проекта
```

Мы не используем `Qwen OAuth` в окне IDE. Запуск идет через `--auth-type openai`, поэтому CLI получает ключ напрямую из проекта.

## Установка с GitHub

Склонируй репозиторий:

```bash
git clone https://github.com/Staks-sor/qwen_free_cli.git
cd qwen_free_cli
```

Установи `Qwen Code CLI`:

```bash
npm install -g @qwen-code/qwen-code@latest
```

Создай Python-окружение:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

На Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Настройка ключа

Скопируй шаблон:

```bash
cp credentials.example.json credentials.json
```

На Windows PowerShell:

```powershell
copy credentials.example.json credentials.json
```

Открой `credentials.json` и вставь свой токен:

```json
{
  "sessions": [
    {
      "qwen_credentials": {
        "access_token": "PASTE_YOUR_TOKEN_HERE"
      }
    }
  ]
}
```

Реальный токен нужно вставить вместо `PASTE_YOUR_TOKEN_HERE`.

Файл `credentials.json` добавлен в `.gitignore`, поэтому он не должен попадать на GitHub.

## Запуск агента

Сделай скрипт исполняемым:

```bash
chmod +x scripts/run_qwen_code.sh
```

Запусти интерактивный режим:

```bash
./scripts/run_qwen_code.sh
```

Для проверки можно написать:

```text
Привет. Ответь на русском и скажи, в какой папке проекта ты работаешь.
```

Потом проверь работу с файлами:

```text
Создай папку ./demo и файл ./demo/test.txt с текстом "Qwen работает из проекта".
```

Важно: для создания и изменения файлов используй именно интерактивную сессию.

One-shot режим:

```bash
./scripts/run_qwen_code.sh "ответь одним словом: тест" --output-format text
```

подходит для быстрых текстовых проверок, но некоторые OpenAI-compatible endpoints могут вернуть tool-call как обычный текст вместо реального изменения файлов.

## Быстрая проверка API через Python

```bash
python chat.py
```

Это не coding agent, а простой чат через тот же API-ключ. Он нужен только для проверки, что токен и endpoint работают.

## PyCharm и VS Code

Этот проект не привязан к конкретной IDE.

В PyCharm:

```bash
./scripts/run_qwen_code.sh
```

можно запускать прямо во встроенном терминале.

В VS Code:

```bash
./scripts/run_qwen_code.sh
```

можно запускать во встроенном терминале. Если есть расширения для агентов, они не обязательны: этот шаблон уже работает через CLI.

## Что внутри проекта

- `scripts/run_qwen_code.sh` - главный запуск `Qwen Code CLI`.
- `.qwen/settings.json` - настройки Qwen Code для проекта.
- `QWEN.md` - правила для агента: русский язык и работа только внутри текущей папки.
- `qwen_client.py` - минимальный Python-клиент для API.
- `chat.py` - простой терминальный чат для проверки API.
- `credentials.example.json` - безопасный шаблон токена.

## Безопасность

Не публикуй реальные токены.

Перед пушем на GitHub проверь:

```bash
git status
```

В репозиторий должен попадать `credentials.example.json`, но не должен попадать `credentials.json`.

## Частые ошибки

Если `Qwen Code` просит `Qwen OAuth`, значит агент запущен не через этот скрипт. Запускай так:

```bash
./scripts/run_qwen_code.sh
```

Если агент создает файлы не там, проси явно указывать относительный путь:

```text
Создай файл ./demo/test.txt
```

Если one-shot режим вернул JSON с tool-call, но файл не появился, используй интерактивную сессию:

```bash
./scripts/run_qwen_code.sh
```
