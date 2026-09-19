param(
    [ValidateSet('Vulkan', 'CPU')]
    [string]$Mode = 'Vulkan'
)

$ErrorActionPreference = 'Stop'
$command = Get-Command ollama -ErrorAction SilentlyContinue
if ($command) {
    $ollamaPath = $command.Source
} else {
    $ollamaPath = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
}
if (-not (Test-Path -LiteralPath $ollamaPath)) {
    throw 'Install Ollama first: https://ollama.com/download/windows'
}

# These settings affect only this terminal and its child process.
$env:CUDA_VISIBLE_DEVICES = '-1'
if ($Mode -eq 'CPU') {
    $env:GGML_VK_VISIBLE_DEVICES = '-1'
    $env:OLLAMA_VULKAN = '0'
} else {
    $env:GGML_VK_VISIBLE_DEVICES = $null
    $env:OLLAMA_VULKAN = '1'
}
$env:OLLAMA_HOST = '127.0.0.1:11434'
$env:OLLAMA_CONTEXT_LENGTH = '2048'
$env:OLLAMA_NO_CLOUD = '1'
$env:NO_PROXY = 'localhost,127.0.0.1'

Write-Output "Starting Ollama in $Mode mode. Keep this terminal open."
Write-Output 'If port 11434 is busy, stop the other Ollama server before using this script.'
& $ollamaPath serve
exit $LASTEXITCODE
