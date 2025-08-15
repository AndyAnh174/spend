@echo off
echo ========================================
echo    Setup Spend Management Project
echo ========================================
echo.

echo [1/6] Checking Ollama installation...
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Ollama not found. Please install Ollama first:
    echo Visit: https://ollama.ai/download
    pause
    exit /b 1
)
echo ✓ Ollama is installed

echo.
echo [2/6] Pulling AI model (deepseek-r1:8b)...
ollama pull deepseek-r1:8b
if %errorlevel% neq 0 (
    echo Failed to pull AI model
    pause
    exit /b 1
)
echo ✓ AI model downloaded

echo.
echo [3/6] Starting Ollama server...
start "Ollama Server" ollama serve
timeout /t 5 /nobreak >nul

echo.
echo [4/6] Installing backend dependencies...
cd backend
go mod tidy
if %errorlevel% neq 0 (
    echo Failed to install backend dependencies
    pause
    exit /b 1
)
echo ✓ Backend dependencies installed

echo.
echo [5/6] Installing frontend dependencies...
cd ..\frontend
npm install
if %errorlevel% neq 0 (
    echo Failed to install frontend dependencies
    pause
    exit /b 1
)
echo ✓ Frontend dependencies installed

echo.
echo [6/6] Installing AI service dependencies...
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
echo To start the project, run: start.bat
echo.
pause
