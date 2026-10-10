@echo off
chcp 65001 >nul
title HedefBirikim - Birikim & Portfoy Takip

echo ========================================================
echo        HEDEF BIRIKIM UYGULAMASI BASLATILIYOR
echo ========================================================
echo.
echo Proje Dizini: C:\Users\Superuser\.gemini\Project\hedef_birikim
echo Tarayici: Google Chrome
echo.
echo Lutfen bekleyin, uygulama aciliyor...
echo ========================================================
echo.

cd /d "C:\Users\Superuser\.gemini\Project\hedef_birikim"

flutter run -d chrome

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [BILGI] Chrome ile baslatilamadi, varsayilan cihaz deneniyor...
    flutter run -d edge
)

echo.
echo Uygulama kapatildi. Pencereyi kapatmak icin herhangi bir tusa basin.
pause >nul
