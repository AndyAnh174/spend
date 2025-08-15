@echo off
echo ========================================
echo    Starting Spend Management Project
echo ========================================
echo.

echo Starting MongoDB...
start "MongoDB" docker run --rm -p 27017:27017 --name spend-mongodb mongo:latest

echo Waiting for MongoDB to start...
timeout /t 10 /nobreak >nul

echo.
echo Starting Backend (Golang)...
cd backend
start "Backend" go run main.go

echo.
echo Starting AI Service (Python)...
cd ..\ai-service
call venv\Scripts\activate
start "AI Service" python main.py

echo.
echo Starting Frontend (React)...
cd ..\frontend
start "Frontend" npm start

echo.
echo ========================================
echo    All services started!
echo ========================================
echo.
echo Services running on:
echo - Frontend: http://localhost:3000
echo - Backend:  http://localhost:8080
echo - AI Service: http://localhost:8000
echo - MongoDB: localhost:27017
echo.
echo Press any key to stop all services...
pause

echo.
echo Stopping all services...
taskkill /f /im "go.exe" >nul 2>&1
taskkill /f /im "python.exe" >nul 2>&1
taskkill /f /im "node.exe" >nul 2>&1
docker stop spend-mongodb >nul 2>&1

echo All services stopped.
pause
