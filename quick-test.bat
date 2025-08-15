@echo off
echo ========================================
echo    Quick Test - Remote Ollama Server
echo ========================================
echo.

echo Testing connection to: http://olla.hcmutertic.com
echo.

echo [1/2] Testing basic connection...
curl -s http://olla.hcmutertic.com/api/tags
if %errorlevel% neq 0 (
    echo ❌ Connection failed
    pause
    exit /b 1
)
echo ✅ Connection successful

echo.
echo [2/2] Testing AI model...
curl -X POST http://olla.hcmutertic.com/api/generate -H "Content-Type: application/json" -d "{\"model\":\"deepseek-r1:8b\",\"prompt\":\"Test\",\"stream\":false}" --max-time 10
if %errorlevel% neq 0 (
    echo ❌ AI model test failed
    pause
    exit /b 1
)
echo ✅ AI model working

echo.
echo ========================================
echo    All tests passed!
echo ========================================
echo.
echo Your remote Ollama server is working.
echo You can now run: setup-remote.bat
echo.
pause
