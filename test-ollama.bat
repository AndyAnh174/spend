@echo off
echo ========================================
echo    Testing Remote Ollama Connection
echo ========================================
echo.

echo [1/3] Testing basic connection...
curl -s http://olla.hcmutertic.com/api/tags
if %errorlevel% neq 0 (
    echo ❌ Failed to connect to Ollama server
    echo Please check if the server is running
    pause
    exit /b 1
)
echo ✓ Connection successful

echo.
echo [2/3] Testing AI model generation...
curl -X POST http://olla.hcmutertic.com/api/generate -H "Content-Type: application/json" -d "{\"model\":\"deepseek-r1:8b\",\"prompt\":\"Hello, test message\",\"stream\":false}" --max-time 10
if %errorlevel% neq 0 (
    echo ❌ Failed to generate response from AI model
    echo This might indicate the model is not available
    pause
    exit /b 1
)
echo ✓ AI model test successful

echo.
echo [3/3] Testing AI service integration...
cd ai-service
call venv\Scripts\activate
python -c "import httpx; import asyncio; async def test(): client = httpx.AsyncClient(); response = await client.post('http://olla.hcmutertic.com/api/generate', json={'model': 'deepseek-r1:8b', 'prompt': 'Test', 'stream': False}); print('✓ AI Service can connect to remote Ollama'); await client.aclose(); asyncio.run(test())"
if %errorlevel% neq 0 (
    echo ❌ AI Service integration test failed
    pause
    exit /b 1
)
echo ✓ AI Service integration successful

echo.
echo ========================================
echo    All tests passed!
echo ========================================
echo.
echo Your remote Ollama server is working correctly.
echo You can now run the full application.
echo.
pause
