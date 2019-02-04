@echo off
pushd "C:\Updates" || exit /B 1
for /D %%I in ("*") do (
    rd /S /Q "%%~I"
)
del /Q "*"
popd