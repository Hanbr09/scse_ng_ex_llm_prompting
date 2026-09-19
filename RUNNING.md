# Running the lost-and-found assistant

The entry point is `investigate.py`. It reads `found_items.json`, removes
claimed items, asks Qwen for possible matches, and saves a validated result
to `output/match_result.json`. Paths are relative to the script's location,
so launching it from another directory still uses the same data file.

The original assignment instructions are in [README.md](README.md).

## Setup on Windows

Open PowerShell in this project folder. Use Python 3.10 or newer; the `py`
launcher avoids accidentally selecting an old `python` from PATH.

```powershell
py -3.10 -m venv .venv
& "./.venv/Scripts/python.exe" -m pip install -r requirements.txt
```

Installing the Python `ollama` package does not install the Ollama application
or download a model. Install and start [Ollama](https://ollama.com/download/windows),
then download the default model once:

```powershell
ollama pull qwen2.5:7b
```

If Ollama is not running, open the application, or run `ollama serve` in a
separate terminal. Do not start another server if one is already running.
The default connection is local (`localhost:11434`). Model requests bypass
system HTTP proxies so a proxy does not intercept the local connection.

```powershell
& "./.venv/Scripts/python.exe" investigate.py
```

Enter a description such as `I lost a black bag near the library`.
The program displays the matching database records and the confidence level.
A service error or invalid response does not overwrite a previous result.
A valid search with no matches does save an empty list.

The starter does not specify a Qwen version. This implementation defaults
to `qwen2.5:7b`. Its model download is about 4.7 GB. Smaller models can have
different matching behavior, even with the same prompt. To experiment with
another installed Qwen model, set it before launching:

```powershell
$env:OLLAMA_MODEL = "qwen2.5:3b"
& "./.venv/Scripts/python.exe" investigate.py
```

In VS Code, open the whole project folder and select
`.venv/Scripts/python.exe` with **Python: Select Interpreter**.
Run `investigate.py`, not a file from `tests`.

## Older GPU drivers

If model loading fails with `CUDA error: device kernel image is invalid`,
quit the Ollama application or stop the terminal running `ollama serve`.
Then try the Vulkan backend from the project folder:

```powershell
./start_ollama.ps1
```

Leave that terminal open, and run `investigate.py` from a second terminal.
The script uses the same downloaded model without changing your GPU driver
or permanently changing GPU settings for other programs. If Vulkan is also
unavailable, start it with `./start_ollama.ps1 -Mode CPU` instead. CPU inference
can take longer and needs enough free system memory to load the model.

## Checks without a model

After installing `requirements.txt`, run the standard-library test runner:

```powershell
& "./.venv/Scripts/python.exe" -m unittest discover -s tests -v
```

These tests cover file handling, prompts, response validation, display, and
the command flow using mocked model replies. They do not require pytest,
Ollama's server, or model weights, and do not prove Qwen's matching accuracy.
Temporary directories keep the supplied database and your saved results intact.

## Checking the actual model

The following command sends real requests to the installed Qwen model:

```powershell
& "./.venv/Scripts/python.exe" check_live.py
```

It checks 17 descriptions and writes each model reply, the expected IDs,
and the pass/fail result to `output/live_check.json`. The last case uses a
separate in-memory catalogue to check that matches are not hard-coded to
the supplied item IDs. The original data file is not changed.

With Ollama and the selected Qwen model running, try a black backpack, a blue
water bottle, a black charger, and an unrelated item such as a red bicycle.
Also try a vague description and a description that asks for an invented ID.
Check that all returned IDs exist in the unclaimed records, that the claimed
headphones are excluded, and that the result file contains only `matches`
and `confidence`. Confidence is a model estimate, not a measured probability.

The program uses JSON output mode and validates the reply before saving.
It does not substitute fabricated matches when the model is unavailable.

## Verified run

On 19 September 2026, all 35 offline tests and all 17 real-model checks
passed. The real checks used Qwen 2.5 7B through Ollama 0.34.2, started with
`start_ollama.ps1` in Vulkan mode. The interactive program was also run with
`I lost a black bag near the library`; it displayed F101 and saved the
expected JSON file successfully.

The actual replies, command output, and saved example are in
[verification](verification/README.md). These are recorded test results,
not a guarantee that every future description will be matched correctly.
The live checks verify matching IDs and the response schema; confidence
labels remain model estimates rather than calibrated scores. Run the
checks again after changing the prompt, model, or data.

API references: [Ollama Python library](https://github.com/ollama/ollama-python)
and [JSON outputs](https://docs.ollama.com/capabilities/structured-outputs).
