:: Set working dir
cd %~dp0 & cd ..

:user_configuration

:: About AIR application packaging
:: http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_5.html#1035959
:: http://livedocs.adobe.com/flex/3/html/distributing_apps_4.html#1037515

:: NOTICE: all paths are relative to project root

:: Your certificate information
set CERT_NAME="R3Air"
set CERT_PASS=r3signingkeyisntthissothisfitsit
set CERT_FILE="bat\R3Air.p12"
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERT_FILE% -storepass %CERT_PASS%

:: Application descriptor
set APP_XML=application.xml

:: Files to package
set APP_DIR=bin
set FILE_OR_DIR=-C %APP_DIR% air.swf icons changelog.txt

:: Your application ID (must match <id> of Application descriptor) and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%

:: Get Ver Number
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<versionNumber>" %APP_XML%') do set VER_NUM=%%a
set VER_NUM=%VER_NUM: =%

:: Output
set AIR_PATH=air
set AIR_NAME=R3Air

:validation
findstr /C:"<id>%APP_ID%</id>" "%APP_XML%" > NUL
if errorlevel 1 goto badid
goto end

:badid
echo.
echo ERROR: 
echo   Application ID in 'bat\SetupApp.bat' (APP_ID) 
echo   does NOT match Application descriptor '%APP_XML%' (id)
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
