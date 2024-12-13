@echo off

if "%~1"=="" (
    echo "Error: Custom token is required as the first argument."
    echo "Usage: reinstall_r7agent.bat <CUSTOMTOKEN>"
    exit /b 1
)

set CUSTOMTOKEN=%~1


REM Download the installer if it does not already exist
if not exist C:\PROGRAMDATA\R7AgentInstaller4.msi (
    curl -o C:\PROGRAMDATA\R7AgentInstaller4.msi https://eu.storage.endpoint.ingress.rapid7.com/public.razor-prod-0.eu-central-1.insight.rapid7.com/endpoint/agent/1731698680/windows/x86_64/PyForensicsAgent-x64.msi --insecure
    if %ERRORLEVEL% neq 0 (
        echo "Error: Failed to download the installer."
        exit /b 1
    )
)

REM Check the size of the downloaded file
for %%A in (C:\PROGRAMDATA\R7AgentInstaller4.msi) do set FileSize=%%~zA
if %FileSize% lss 56770560 (
    echo "Error: Downloaded file size is less than 54 MB. File size: %FileSize% bytes." >> C:\PROGRAMDATA\R7ScriptLogs.log
	exit /b 1
)


REM Proceed with uninstallation if the MSI file exists
if exist C:\PROGRAMDATA\R7AgentInstaller4.msi (
    msiexec /x {59FA94BA-F32D-44DF-B5A2-088EB1F1EE64} /quiet /l*v C:\PROGRAMDATA\insight_agent_Uninstall_log.log
    timeout /t 180 /nobreak >nul
    msiexec /i C:\PROGRAMDATA\R7AgentInstaller4.msi /quiet /l*v C:\PROGRAMDATA\insight_agent_install_log.log CUSTOMTOKEN=%CUSTOMTOKEN%
) else (
    echo "Error: Installer file not found. The download might have failed."
    exit /b 1
)
exit /b 0
