@echo off
echo ========================================
echo    Installing Go for Windows
echo ========================================
echo.

echo [1/3] Downloading Go...
powershell -Command "Invoke-WebRequest -Uri 'https://go.dev/dl/go1.21.6.windows-amd64.msi' -OutFile 'go-installer.msi'"

if %errorlevel% neq 0 (
    echo Failed to download Go
    pause
    exit /b 1
)
echo ✓ Go downloaded

echo.
echo [2/3] Installing Go...
msiexec /i go-installer.msi /quiet

if %errorlevel% neq 0 (
    echo Failed to install Go
    pause
    exit /b 1
)
echo ✓ Go installed

echo.
echo [3/3] Cleaning up...
del go-installer.msi

echo.
echo ========================================
echo    Go installation completed!
echo ========================================
echo.
echo Please restart your terminal/PowerShell
echo Then run: setup-remote.bat
echo.
pause
