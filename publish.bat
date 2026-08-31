@echo off
REM ============================================================
REM  Publish the NSW PDRS site to the live GitHub Pages site:
REM    https://powertech-au.github.io/nsw-pdrs/
REM
REM  Copies index.html, calculator.html and assets\ out of the
REM  OneDrive source folder, then commits and pushes.
REM
REM  OneDrive is the source of truth. Anything edited only in
REM  this repo folder is OVERWRITTEN by this script.
REM
REM  Double-click this file to update the live site.
REM ============================================================
setlocal
cd /d "%~dp0"

set "SRC=C:\Users\Powertech\OneDrive Greg\Powertech Pty Ltd\Edapta - Documents\PDRS\PDRS website"

if not exist "%SRC%\" (
  echo ERROR: source folder not found:
  echo   %SRC%
  echo Check the SRC path in this .bat.
  pause
  exit /b 1
)

echo Copying pages from OneDrive...
copy /Y "%SRC%\index.html" "index.html" >nul
if errorlevel 1 goto copyfail
copy /Y "%SRC%\calculator.html" "calculator.html" >nul
if errorlevel 1 goto copyfail
xcopy "%SRC%\assets\*" "assets\" /E /I /Y /Q >nul
if errorlevel 1 goto copyfail

git add -A
git diff --cached --quiet
if %errorlevel%==0 (
  echo No changes to publish - live site is already up to date.
  pause
  exit /b 0
)

echo.
echo Publishing these changes:
git diff --cached --name-status
echo.

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "STAMP=%%i"
git commit -m "Update PDRS site %STAMP%"
if errorlevel 1 (
  echo ERROR: commit failed.
  pause
  exit /b 1
)

git push
if errorlevel 1 (
  echo.
  echo ERROR: push failed. Check your network and GitHub sign-in, then run this again.
  echo The commit is saved locally, so nothing is lost.
  pause
  exit /b 1
)

echo.
echo Done. Live site will refresh within about a minute:
echo   https://powertech-au.github.io/nsw-pdrs/
echo   https://powertech-au.github.io/nsw-pdrs/calculator.html
pause
exit /b 0

:copyfail
echo.
echo ERROR: could not copy files from:
echo   %SRC%
echo Nothing has been committed or pushed.
pause
exit /b 1
