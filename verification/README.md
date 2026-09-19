# Verification record

These files were captured from a real local run on 19 September 2026.
The model was not mocked, and the returned matches were not replaced by
Python matching rules.

## Environment

- Windows, Python 3.10.11, `ollama` Python package 0.6.2.
- Ollama server 0.34.2, started using `start_ollama.ps1` in Vulkan mode.
- Model: `qwen2.5:7b`, Q4_K_M quantization, context length 2048.
- Model manifest digest: `845dbda0ea48ed749caafd9e6037047aa19acfcfd82e704d7ca97d631a0b697e`.
- Model weights SHA-256: `2bada8a7450677000f678be90653b85d364de7db25eb5ea54136ada5f3933730`.

The complete downloaded weights were checked against the official digest
before inference. Vulkan was used because this machine's existing NVIDIA
driver failed to load the model using the CUDA backend.

## Results

`python -m unittest discover -s tests -v` passed all 35 offline tests.
Those tests use mocked responses to check program behavior, not model accuracy.

`python check_live.py` passed all 17 real-model checks. [live_check.json](live_check.json)
contains each description, expected IDs, raw model reply, validated result,
and pass/fail status. Cases include partial details, synonyms, different
locations, multiple matches, Chinese input, embedded instructions, and
unrelated item types. The last case uses an independent in-memory catalogue
with different IDs; it does not change `found_items.json`.

`python investigate.py` was then run with this input:

```text
I lost a black bag near the library.
```

[cli_example.txt](cli_example.txt) is the captured console output with trailing whitespace removed;
[match_result.json](match_result.json) is a copy of the resulting saved file.
The returned match was F101. The process exited successfully, and the saved
file was checked to contain only `matches` and `confidence`.

The 17 cases check matching IDs and the required JSON structure. They are a
finite sample, not a guarantee for arbitrary descriptions. Confidence is a
model estimate and is not calibrated by these tests. Results can change with
different model versions, prompts, data, or inference settings.
