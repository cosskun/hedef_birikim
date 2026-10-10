@echo off
title HedefBirikim Baslatici
cls

echo ======================================================
echo             HEDEF BIRIKIM - BASLATICI
echo ======================================================
echo.
echo   [1] Google Chrome ile Baslat (Web - Onerilen)
echo   [2] Windows Masaustu Uygulamasi Olarak Baslat
echo   [3] Microsoft Edge ile Baslat
echo   [4] Cikis
echo.
echo ======================================================
set /p secim="Seciminizi yapin (1-4): "

if "%secim%"=="1" goto CHROME
if "%secim%"=="2" goto WINDOWS
if "%secim%"=="3" goto EDGE
if "%secim%"=="4" goto EXIT

echo Gecersiz secim, Chrome baslatiliyor...
goto CHROME

:CHROME
cls
echo ======================================================
echo  HedefBirikim Google Chrome uzerinde baslatiliyor...
echo  (Acildiginda F12 tusuna basip Ctrl+Shift+M ile
echo   telefon ekrani boyutunda test edebilirsiniz)
echo ======================================================
echo.
flutter run -d chrome
pause
goto EXIT

:WINDOWS
cls
echo ======================================================
echo  HedefBirikim Windows Masaustu Olarak Baslatiliyor...
echo ======================================================
echo.
flutter run -d windows
pause
goto EXIT

:EDGE
cls
echo ======================================================
echo  HedefBirikim Microsoft Edge uzerinde baslatiliyor...
echo ======================================================
echo.
flutter run -d edge
pause
goto EXIT

:EXIT
exit
