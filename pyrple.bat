@echo OFF
color 5

set "SCRIPT_PATH=%~dp0"

:a 
set /p "input=Input name file (without .py, default: main.py, press enter to skip): "

if "%input%"=="" (set "input=main")

if not exist "%input%.py" (
	echo [%TIME%]: File not exist!
	pause
	cls
	goto :a
) 

:b
set "icon="
set /p "icon=Input icon file (without .ico default: icon.ico, press enter to skip): "

if not "%icon%"=="" (
	set "icon=icon"
	if not exist "%icon%.ico" (
		echo [%TIME%]: File not exist!
		pause
		cls
		goto :b
	) 
) else (
	echo [%TIME%]: Icon file <- Skip
)

cd "%SCRIPT_PATH%"

echo [%TIME%]: Search virtual env...
if not exist "%SCRIPT_PATH%.env\Scripts\activate.bat" (
	echo [%TIME%]: Virtual env is not found, installing...
	python -m venv .env
) else (	
	echo [%TIME%]: Found virtual env <- Skip
) 

echo [%TIME%]: Activate virtual env...
call ".env\Scripts\activate.bat"

echo [%TIME%]: Return to root folder...
cd /d "%SCRIPT_PATH%"

echo [%TIME%]: Search PyInstaller...
call %SCRIPT_PATH%.env\Scripts\pip.exe show PyInstaller >nul 2>nul

if %ERRORLEVEL% equ 1 (
	echo [%TIME%]: PyInstaller is not found, installing...
	python -m pip install pyinstaller --target .env\Lib\site-packages -qqq <nul
	call %SCRIPT_PATH%.env\Scripts\pip.exe show PyInstaller >nul 2>nul
	if %ERRORLEVEL% equ 1 (echo [%TIME%]: PyInstaller is not installed (Check connection to internet) ^<- ^EXIT)
) else (
	echo [%TIME%]: PyInstaller is installed.
	echo [%TIME%]: Convert to .exe...

	if not "%icon%"=="" (
		python -m PyInstaller --onefile --clean --log-level ERROR "%input%.py" --noconsole --icon "%icon%.ico"
	) else (
		python -m PyInstaller --onefile --clean --log-level ERROR "%input%.py" --noconsole
	)

	if exist ".\dist\%input%.exe" (echo [%TIME%]: BUILD SUCEFULL!) else (echo [%TIME%]: BUILD ERROR!)
)

pause
exit /B