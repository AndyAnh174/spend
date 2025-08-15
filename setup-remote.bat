@echo off
echo ========================================
echo    Setup Spend Management Project
echo    (Using Remote Ollama Server)
echo ========================================
echo.

echo [1/5] Checking remote Ollama server...
curl -s http://olla.hcmutertic.com/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to connect to remote Ollama server
    echo Please check: http://olla.hcmutertic.com
    pause
    exit /b 1
)
echo ✓ Remote Ollama server is accessible

echo.
echo [2/5] Checking AI model availability...
curl -s http://olla.hcmutertic.com/api/tags | findstr "deepseek-r1:8b" >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: deepseek-r1:8b model not found on remote server
    echo Available models:
    curl -s http://olla.hcmutertic.com/api/tags
    echo.
    echo Please ensure the model is available on the remote server
    pause
)
echo ✓ AI model check completed

echo.
echo [3/5] Installing backend dependencies...
cd backend
go mod tidy
if %errorlevel% neq 0 (
    echo Failed to install backend dependencies
    pause
    exit /b 1
)
echo ✓ Backend dependencies installed

echo.
echo [4/5] Installing frontend dependencies...
cd ..\frontend
npm install
if %errorlevel% neq 0 (
    echo Failed to install frontend dependencies
    pause
    exit /b 1
)
echo ✓ Frontend dependencies installed

echo.
echo [5/5] Installing AI service dependencies...
cd ..\ai-service
python -m venv venv
call venv\Scripts\activate
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install AI service dependencies
    pause
    exit /b 1
)
echo ✓ AI service dependencies installed

echo.
echo ========================================
echo    Setup completed successfully!
echo ========================================
echo.
echo Configuration:
echo - Remote Ollama Server: http://olla.hcmutertic.com
echo - AI Model: deepseek-r1:8b
echo - Backend: http://localhost:8080
echo - Frontend: http://localhost:3000
echo - AI Service: http://localhost:8000
echo.
echo To start the project, run: start.bat
echo.
pause
