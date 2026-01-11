param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]]$InputFiles,

    [string]$OutputFile = "output.mp4"
)

# Ensure ffmpeg exists
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "ffmpeg not found in PATH."
    exit 1
}

# Temp working directory
#$tempDir = Join-Path $env:TEMP ("ffmpeg_safe_" + [guid]::NewGuid())
$tempDir = Join-Path (Get-Location) "ffmpeg_temp"
New-Item -ItemType Directory -Path $tempDir | Out-Null

$concatFile = Join-Path $tempDir "concat.txt"
$safeFiles = @()

try {
    # --- Step 1: Transcode each input safely ---
    foreach ($file in $InputFiles) {
        $resolved = (Resolve-Path $file).Path
        $safeOut = Join-Path $tempDir ([IO.Path]::GetFileNameWithoutExtension($resolved) + "_safe.mp4")
        $safeFiles += $safeOut

        ffmpeg `
            -y `
            -fflags +genpts `
            -i "$resolved" `
            -map_metadata -1 `
            -movflags +faststart `
            -fps_mode vfr `
            -c:v libx265 `
            -preset ultrafast `
            -crf 20 `
            -x265-params "fast-decode=1" `
            -c:a aac `
            -b:a 96k `
            -ar 48000 `
            -ac 2 `
            -shortest `
            "$safeOut"

        if ($LASTEXITCODE -ne 0) {
            throw "Transcode failed for $resolved"
        }
    }

    # --- Step 2: Build concat list ---
    $safeFiles | ForEach-Object {
        $escaped = $_.Replace("'", "'\''")
        "file '$escaped'"
    } | Set-Content -Path $concatFile -Encoding UTF8

    # --- Step 3: Concat without re-encoding ---
    #ffmpeg `
    #    -y `
    #    -f concat `
    #    -safe 0 `
    #    -i "$concatFile" `
    #    -map_metadata -1 `
    #    -c copy `
    #    "$OutputFile"
		
		
	#ffmpeg `
    #-y `
    #-f concat `
    #-safe 0 `
    #-i "$concatFile" `
    #-map_metadata -1 `
    #-c:v libx265 `
    #-preset ultrafast `
    #-crf 20 `
    #-c:a aac `
    #-b:a 96k `
    #-ar 48000 `
    #-ac 2 `
    #"$OutputFile"
}
finally {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
