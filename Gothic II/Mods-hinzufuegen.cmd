@echo off
setlocal
rem GothicCoop - Workshop-Mods ins Coop-Gothic uebernehmen (11.11.2026)
rem Liegt im Gothic-II-Ordner des Coops (neben "System" und "Data"). Holt aus dem Steam-Workshop (Gothic II Gold Classic):
rem   D3D11-Renderer (GD3D11)          2787015529 -> System (UserSettings.ini bleibt)
rem   Gold Remaster                   2794214493 -> Data\gold_remaster.vdf (immer geladen, harter Link - kein zweites 1,7 GB)
rem   DX11-Wind-Effekte (Union-Plugin) 3493896672 -> Data\Plugins
rem   Ninja, FreeAiming, Toolkit        2786910489, 2786958841, 3524696788
rem Vorher in Steam abonnieren und Steam-Gothic einmal starten, damit Steam alles herunterlaedt.
set "G=%~dp0"
set "LOG=%~dp0Mods-hinzufuegen.log"
set "STEAM="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul ^| find /i "SteamPath"') do set "STEAM=%%b"
set "WS=%STEAM%\steamapps\workshop\content\39510"
if not exist "%WS%\" set "WS=C:\Program Files (x86)\Steam\steamapps\workshop\content\39510"
echo Workshop-Mods fuer das Coop-Gothic > "%LOG%"
echo Ziel: %G% >> "%LOG%"
echo Workshop: %WS% >> "%LOG%"
echo.
echo Workshop-Mods ins Coop-Gothic uebernehmen
echo Ziel:     %G%
echo Workshop: %WS%
echo.
tasklist /FI "IMAGENAME eq Gothic2.exe" 2>nul | find /I "Gothic2.exe" >nul
if not errorlevel 1 goto laeuft
if not exist "%WS%\" goto keinws
if not exist "%G%System\Gothic2.exe" goto keingothic

if not exist "%WS%\2787015529\system\ddraw.dll" goto ohne_d3d
robocopy "%WS%\2787015529\system" "%G%System" /E /XF UserSettings.ini /R:1 /W:1 /NFL /NDL /NJH /NP >> "%LOG%"
if errorlevel 8 goto fehler
echo [OK] D3D11-Renderer
echo OK D3D11-Renderer >> "%LOG%"
goto wind
:ohne_d3d
echo [--] D3D11-Renderer nicht im Workshop-Ordner (abonniert?)
echo FEHLT D3D11 >> "%LOG%"

:wind
if not exist "%WS%\3493896672\Data\Plugins\Union_WindDX11_Plugin.vdf" goto ohne_wind
if not exist "%G%Data\Plugins\" mkdir "%G%Data\Plugins"
copy /Y "%WS%\3493896672\Data\Plugins\Union_WindDX11_Plugin.vdf" "%G%Data\Plugins\" >> "%LOG%"
if errorlevel 1 goto fehler
echo [OK] DX11-Wind-Effekte
echo OK Wind >> "%LOG%"
goto gold
:ohne_wind
echo [--] DX11-Wind-Effekte nicht im Workshop-Ordner (abonniert?)
echo FEHLT Wind >> "%LOG%"

:gold
if not exist "%WS%\2794214493\Data\ModVDF\gold_remaster.mod" goto ohne_gold
if exist "%G%Data\gold_remaster.vdf" del "%G%Data\gold_remaster.vdf"
mklink /H "%G%Data\gold_remaster.vdf" "%WS%\2794214493\Data\ModVDF\gold_remaster.mod" >> "%LOG%" 2>&1
if not errorlevel 1 goto gold_ok
echo Harter Link ging nicht - kopiere 1,7 GB, das dauert etwas ...
copy /Y "%WS%\2794214493\Data\ModVDF\gold_remaster.mod" "%G%Data\gold_remaster.vdf" >> "%LOG%"
if errorlevel 1 goto fehler
:gold_ok
if exist "%WS%\2794214493\system\gold_remaster.ini" copy /Y "%WS%\2794214493\system\gold_remaster.ini" "%G%System\" >> "%LOG%"
echo [OK] Gold Remaster
echo OK Gold Remaster >> "%LOG%"
goto ninja
:ohne_gold
echo [--] Gold Remaster nicht im Workshop-Ordner (abonniert?)
echo FEHLT Gold >> "%LOG%"

:ninja
if not exist "%WS%\2786910489\System\Ninja.dll" goto ohne_ninja
if not exist "%G%System\BugslayerUtilG.dll" copy /Y "%G%System\BugslayerUtil.dll" "%G%System\BugslayerUtil-vor-Ninja.dll" >> "%LOG%"
copy /Y "%WS%\2786910489\System\*.dll" "%G%System\" >> "%LOG%"
if errorlevel 1 goto fehler
if exist "%WS%\2786958841\Data\FreeAiming.vdf" copy /Y "%WS%\2786958841\Data\FreeAiming.vdf" "%G%Data\" >> "%LOG%"
if exist "%WS%\3524696788\Data\Toolkit.vdf" copy /Y "%WS%\3524696788\Data\Toolkit.vdf" "%G%Data\" >> "%LOG%"
echo [OK] Ninja, FreeAiming, Toolkit
echo OK Ninja >> "%LOG%"
goto ende
:ohne_ninja
echo [--] Ninja nicht im Workshop-Ordner - FreeAiming braucht es
echo FEHLT Ninja >> "%LOG%"

:ende
echo FERTIG >> "%LOG%"
echo.
echo Fertig. Gothic jetzt wie gewohnt starten.
pause
exit /b 0

:laeuft
echo Gothic laeuft noch - bitte erst beenden, dann nochmal starten.
echo ABBRUCH Gothic laeuft >> "%LOG%"
pause
exit /b 1
:keinws
echo Steam-Workshop-Ordner nicht gefunden: %WS%
echo ABBRUCH kein Workshop >> "%LOG%"
pause
exit /b 1
:keingothic
echo Diese Datei muss im Gothic-II-Ordner des Coops liegen (neben System und Data).
echo ABBRUCH falscher Ordner >> "%LOG%"
pause
exit /b 1
:fehler
echo Fehler beim Kopieren - siehe Mods-hinzufuegen.log
echo FEHLER >> "%LOG%"
pause
exit /b 1
