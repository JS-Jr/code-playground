rem Loop through all CBZ files and rename them
for %%i in (*.cbz) do (
    ren "%%i" "%%~ni.rar"
)

echo File extension change completed.
