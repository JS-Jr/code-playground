for %%i in (*.mkv) do (
    ffmpeg -i "%%i" -c:s copy -map 0:s:0 "output_%%~ni.ass"
)