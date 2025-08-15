@echo off
echo ========================================
echo    Testing AI Service Only
echo ========================================
echo.

echo [1/3] Testing Ollama connection...
curl -s http://olla.hcmutertic.com/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Ollama connection failed
    pause
    exit /b 1
)
echo ✅ Ollama connection successful

echo.
echo [2/3] Starting AI Service...
cd ai-service
call venv\Scripts\activate
start "AI Service" python main.py
timeout /t 5 /nobreak >nul

echo.
echo [3/3] Testing AI Service...
curl -s http://localhost:8000/health
if %errorlevel% neq 0 (
    echo ❌ AI Service not responding
    taskkill /f /im python.exe >nul 2>&1
    pause
    exit /b 1
)
echo ✅ AI Service is running

echo.
echo ========================================
echo    AI Service Test Complete!
echo ========================================
echo.
echo AI Service running at: http://localhost:8000
echo.
echo Testing AI Analysis...
curl -X POST http://localhost:8000/analyze -H "Content-Type: application/json" -d "{\"user_id\":\"test\",\"time_range\":\"month\",\"analysis_type\":\"spending_pattern\"}"
echo.
echo.
echo Press any key to stop AI Service...
pause

echo.
echo Stopping AI Service...
taskkill /f /im python.exe >nul 2>&1
echo ✅ AI Service stopped
pause
