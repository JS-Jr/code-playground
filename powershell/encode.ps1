param (
    [Parameter(Mandatory=$true)]
    [string]$Video,

    [string[]]$Subs,

    [Parameter(Mandatory=$true)]
    [string]$Output
)

$args = @(
    "-hide_banner"
    "-y"
    "-i", $Video
)

# Subtitle inputs
if ($Subs) {
    foreach ($sub in $Subs) {
        $args += "-i"
        $args += $sub
    }
}

# Map video + audio
$args += @(
    "-map", "0:v:0"
    "-map", "0:a:0?"
)

# Map subtitles
if ($Subs) {
    for ($i = 0; $i -lt $Subs.Count; $i++) {
        $args += "-map"
        $args += "$($i + 1):s:0"
    }
}

# Encoding
$args += @(
    "-c:v", "libx265"
    "-preset", "fast"
    "-crf", "24"

    # Modern replacement for -vsync vfr
    "-fps_mode", "vfr"

    "-c:a", "aac"
    "-b:a", "96k"

    "-c:s", "copy"
    "-map_metadata", "0"

    "-f", "matroska"
    $Output
)

ffmpeg @args
