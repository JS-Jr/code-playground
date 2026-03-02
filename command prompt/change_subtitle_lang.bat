for %%i in (*.mkv) do (
    ffmpeg -i "%%i" -map 0 -c copy -scodec copy -metadata:s:s:4 language=jpn "output_%%i"
)
