# Qwen Code CLI Starter

Минимальный шаблон для запуска `Qwen Code CLI` как coding agent через OpenAI-compatible API.

Главная идея: папка `qwen_free_cli` добавляется внутрь любого проекта, а `Qwen Code` запускается из нее и работает с файлами родительского проекта.

## Что получится

После настройки можно открыть проект в PyCharm, VS Code или обычном терминале и запустить:

```bash
./qwen_free_cli/scripts/run_qwen_code.sh
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
  -> запускается из ./qwen_free_cli
  -> берет access_token из ./qwen_free_cli/credentials.json
  -> подключается к https://qwen.aikit.club/v1
  -> использует модель qwen3.6-plus
  -> читает и меняет файлы родительского проекта
```

Мы не используем `Qwen OAuth` в окне IDE. Запуск идет через `--auth-type openai`, поэтому CLI получает ключ напрямую из проекта.

## Установка с GitHub

Создай или открой папку своего проекта:

```bash
mkdir my_project
cd my_project
```

Склонируй `qwen_free_cli` внутрь проекта:

```bash
git clone https://github.com/Staks-sor/qwen_free_cli.git
```

Установи `Qwen Code CLI`:

```bash
npm install -g @qwen-code/qwen-code@latest
```

Создай Python-окружение в корне своего проекта:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r qwen_free_cli/requirements.txt
```

На Windows PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r qwen_free_cli\requirements.txt
```

Важно: `.venv` создается в корне твоего проекта, а зависимости берутся из `qwen_free_cli/requirements.txt`.


## Настройка ключа

Скопируй шаблон:

```bash
cp qwen_free_cli/credentials.example.json qwen_free_cli/credentials.json
```

На Windows PowerShell:

```powershell
copy qwen_free_cli\credentials.example.json qwen_free_cli\credentials.json
```

Открой `qwen_free_cli/credentials.json` и вставь свой токен:

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

Файл `qwen_free_cli/credentials.json` добавлен в `.gitignore`, поэтому он не должен попадать на GitHub.

## Запуск агента

Сделай скрипт исполняемым:

```bash
chmod +x qwen_free_cli/scripts/run_qwen_code.sh
```

Запусти интерактивный режим:

```bash
./qwen_free_cli/scripts/run_qwen_code.sh
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
./qwen_free_cli/scripts/run_qwen_code.sh "ответь одним словом: тест" --output-format text
```

подходит для быстрых текстовых проверок, но некоторые OpenAI-compatible endpoints могут вернуть tool-call как обычный текст вместо реального изменения файлов.

## Быстрая проверка API через Python

```bash
python3 qwen_free_cli/chat.py
```

Это не coding agent, а простой чат через тот же API-ключ. Он нужен только для проверки, что токен и endpoint работают.

## PyCharm и VS Code

Этот проект не привязан к конкретной IDE.

В PyCharm:

```bash
./qwen_free_cli/scripts/run_qwen_code.sh
```

можно запускать прямо во встроенном терминале.

В VS Code:

```bash
./qwen_free_cli/scripts/run_qwen_code.sh
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
./qwen_free_cli/scripts/run_qwen_code.sh
```

Если агент создает файлы не там, проси явно указывать относительный путь:

```text
Создай файл ./demo/test.txt
```

Если one-shot режим вернул JSON с tool-call, но файл не появился, используй интерактивную сессию:

```bash
./qwen_free_cli/scripts/run_qwen_code.sh
```
