@echo off
setlocal
cd /d "%~dp0"

set "JAVA_COMMAND=C:\Program Files\Java\jdk-17\bin\java.exe"

if not exist "%JAVA_COMMAND%" (
    echo JDK 17 was not found at:
    echo %JAVA_COMMAND%
    pause
    exit /b 1
)

if not exist "vape421-experimental-service-0.1.0.jar" (
    echo Missing service artifact: vape421-experimental-service-0.1.0.jar
    pause
    exit /b 1
)

if not exist "data" mkdir "data"

"%JAVA_COMMAND%" -jar "vape421-experimental-service-0.1.0.jar" ^
    --bind-address 127.0.0.1 ^
    --http-port 8080 ^
    --zeus-port 8091 ^
    --data-file "data/vape-service.json"

if errorlevel 1 (
    echo.
    echo Service exited with an error.
    pause
)
