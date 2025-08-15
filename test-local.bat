@echo off
echo ========================================
echo    Testing Spend Management App
echo ========================================
echo.

echo [1/4] Testing Ollama connection...
curl -s http://olla.hcmutertic.com/api/tags >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Ollama connection failed
    pause
    exit /b 1
)
echo ✅ Ollama connection successful

echo.
echo [2/4] Testing AI Service...
cd ai-service
call venv\Scripts\activate
start "AI Service" python main.py
timeout /t 5 /nobreak >nul

curl -s http://localhost:8000/health >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AI Service not responding
    taskkill /f /im python.exe >nul 2>&1
    pause
    exit /b 1
)
echo ✅ AI Service is running

echo.
echo [3/4] Testing AI Analysis...
curl -X POST http://localhost:8000/analyze -H "Content-Type: application/json" -d "{\"user_id\":\"test\",\"time_range\":\"month\",\"analysis_type\":\"spending_pattern\"}" --max-time 10
if %errorlevel% neq 0 (
    echo ❌ AI Analysis failed
    taskkill /f /im python.exe >nul 2>&1
    pause
    exit /b 1
)
echo ✅ AI Analysis working

echo.
echo [4/4] Testing Frontend...
cd ..\frontend
start "Frontend" npm start
timeout /t 10 /nobreak >nul

curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Frontend not responding
    taskkill /f /im node.exe >nul 2>&1
    taskkill /f /im python.exe >nul 2>&1
    pause
    exit /b 1
)
echo ✅ Frontend is running

echo.
echo ========================================
echo    All tests passed!
echo ========================================
echo.
echo Services running:
echo - AI Service: http://localhost:8000
echo - Frontend: http://localhost:3000
echo.
echo Press any key to stop all services...
pause

echo.
echo Stopping services...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im python.exe >nul 2>&1
echo ✅ All services stopped
pause
