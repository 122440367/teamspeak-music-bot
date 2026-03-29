@echo off
title TSMusicBot
echo Starting TSMusicBot...
echo.

:: Check if node is available
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo Node.js is not installed. Please install Node.js 20 LTS from https://nodejs.org
    pause
    exit /b 1
)

:: Check if ffmpeg is available
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo FFmpeg not found in PATH. Checking local directory...
    if exist "%~dp0ffmpeg\ffmpeg.exe" (
        set PATH=%~dp0ffmpeg;%PATH%
        echo Using bundled FFmpeg.
    ) else (
        echo FFmpeg is required. Please install FFmpeg or place it in the ffmpeg\ directory.
        pause
        exit /b 1
    )
)

:: Install dependencies if needed
if not exist "%~dp0node_modules" (
    echo Installing dependencies...
    cd /d "%~dp0"
    call npm install --production
)

:: Start the application
cd /d "%~dp0"
node dist/index.js

pause
