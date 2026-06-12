@echo off
REM Initialize VS 2022 Community MSVC environment (x64) and run cmake
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
if %errorlevel% neq 0 (
    echo [ERROR] VS environment initialization failed
    exit /b %errorlevel%
)
cmake %*
