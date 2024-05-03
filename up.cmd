@ECHO off
SETLOCAL EnableDelayedExpansion
PUSHD "%~dp0"


:: Settings:

:: Clean up your desktop of any .lnk clutter left behind by installers.
:: WARNING! Will delete any shortcuts indiscriminately.
:: Commandline: --cleanup-desktop
SET cleanup-desktop=1

:: Commandline: --no-color
SET no-color=0


:: Ensure we're running in cmd
REM IF /I "%COMSPEC:~-7%" NEQ "CMD.EXE" (
IF /I "%1" NEQ "CMDCEPTION" (
	CMD /C "%0" CMDCEPTION
	EXIT/B
)

:: Ensure we're administrator
NET session >nul 2>&1
IF !ERRORLEVEL! NEQ 0 (
	WHERE sudo >nul 2>&1
	ECHO.
	IF !ERRORLEVEL! EQU 0 (
		sudo CMD /C "%0"
		EXIT/B
	) ELSE (
		ECHO Missing 'sudo', can't elevate current process.
	)
	EXIT/B
)


:color
SET choco_color=
SET winget_color=[94m
SET tnuc_color=[95m
SET wup_color=[97m
SET color_reset= [0m
SET color_green=[92m
SET color_yellow=[93m
GOTO :parse


:debug
SET cleanup-desktop=1
GOTO :eof


:cleanup-desktop
SET cleanup-desktop=1
GOTO :eof


:no-color
SET choco_color=--no-color
SET winget_color=
SET color_reset=.
SET color_green=
SET color_yellow=
GOTO :eof


:parse
SET PARAMS="%TEMP%\update-params"
ECHO %0 %* > %PARAMS%
FOR %%P IN (debug,no-color,cleanup-desktop) DO (
	FOR /F "usebackq tokens=*" %%Q IN (`ECHO --%%P ^| sed "s/-/\\-/g" ^| sed "s/\W*$/(?:\\W)/"`) DO SET param="%%Q"
	grep -o -P !param! !PARAMS!
	IF !ERRORLEVEL! EQU 0 CALL :%%P
)
GOTO :begin


:begin
@REM goto :tnuc
@REM goto :winget


:choco
WHERE choco
IF %ERRORLEVEL% NEQ 0 (
	ECHO Chocolatey (choco) not found.
	GOTO :wup
)
TITLE Chocolatey outdated
SET choco_outdated="%TEMP%\choco-outdated.lst"
SET choco_package_pattern="[[:alpha:]][[:alnum:]\.\+_-]+(?=\|)"
choco outdated %choco_color% > %choco_outdated%
ECHO|SET /P=%color_green%
head -n3 %choco_outdated%
ECHO|SET /P=%color_reset%
grep -P  %choco_package_pattern% %choco_outdated%
ECHO|SET /P=%color_yellow%
grep -P "\d package\(s\)" %choco_outdated%
ECHO|SET /P=%color_reset%
SET cIDS=
FOR /F "usebackq tokens=*" %%I IN (`grep -c -P %choco_package_pattern% %choco_outdated%`) DO SET cIDS=%%I
IF !cIDS! NEQ 0 (
	TITLE Install updates?
	SET /P yn="Install updates? (Y/N)"
	IF /I "!yn!" == "y" (
		FOR /F "usebackq tokens=*" %%I IN (`grep -o -P  %choco_package_pattern% %choco_outdated%`) DO (
			TITLE Updating %%I
			choco upgrade -y %%I
		)
	)
)
IF %ERRORLEVEL% NEQ 0 GOTO :END
ECHO.
ECHO.


:winget
WHERE winget
IF %ERRORLEVEL% NEQ 0 (
	ECHO Windows Package Manager (winget) not found.
	GOTO :tnuc
)
TITLE winget upgrade --source=winget
FOR /F "tokens=*" %%F IN ('winget --version') DO ( SET winget_version=%%F )
ECHO|SET /P="%winget_color%Windows Package Manager %winget_version%"
ECHO%color_reset%
SET winget_exclusions="%USERPROFILE%\winget-exclude.lst"
SET winget_updates="%TEMP%\winget-update.lst"
SET winget_ids=%TEMP%\winget-id.lst
SET winget_package_pattern="(?<= )[[:alnum:]]+[[:alpha:]][[:alnum:]\+_-]+(\.[[:alnum:]\+_-]+)+"
winget upgrade --source=winget > %winget_updates%
SET UPS=
:: FOR /F "usebackq tokens=*" %%P IN (`tail -n3 %winget_updates% ^| grep -o -P "^\d+(?= upgrades available)" -m1`) DO SET UPS=%%P
FOR /F "usebackq tokens=*" %%P IN (`grep -P "^\d+(?= upgrades available)" -m1 "%winget_updates%" -m1`) DO SET UPS=%%P
IF /I "%UPS%" EQU "" (
	tail -n1 %winget_updates%
) ELSE (
	SET /A "UPS+=3"
	grep -o -P "Name[^\n]*" %winget_updates%
	grep -o -P -- "-----*" %winget_updates%
	tail -n!UPS! %winget_updates% > %winget_updates%.tmp
	@REM grep -v -P "(upgrades available|--include-unknown)" %winget_updates%.tmp
	MOVE/Y %winget_updates%.tmp %winget_updates% >nul 2>&1
	IF EXIST %winget_exclusions% (
		grep -v -f %winget_exclusions% %winget_updates% | grep -o -P %winget_package_pattern% > "%winget_ids%"
	) ELSE (
		sort %winget_updates% | grep -o -P %winget_package_pattern% > "%winget_ids%"
	)
	grep -f "%winget_ids%" %winget_updates%
	SET IDS=
	FOR /F "usebackq tokens=*" %%I IN (`wc -l ^< "%winget_ids%"`) DO SET IDS=%%I
	IF !IDS! NEQ 0 (
		TITLE Install !IDS! updates?
		SET /P yn="Install !IDS! updates? (Y/N)"
		IF /I "!yn!" == "y" (
			FOR /F "usebackq tokens=*" %%P IN (%winget_ids%) DO (
				TITLE Updating %%P
				ECHO %%P
				winget upgrade --silent %%P
			)
		)
	) ELSE (
		ECHO No applicable updates available.
	)
)
IF %ERRORLEVEL% NEQ 0 GOTO :END
ECHO.
ECHO.


:tnuc
WHERE TinyNvidiaUpdateChecker
IF %ERRORLEVEL% NEQ 0 (
	ECHO TinyNvidiaUpdateChecker not found.
	GOTO :wup
)
TITLE TinyNvidiaUpdateChecker
ECHO|SET /P="%tnuc_color%"
TinyNvidiaUpdateChecker --noprompt --confirm-dl
ECHO%color_reset%
IF %ERRORLEVEL% NEQ 0 GOTO :END
ECHO.
ECHO.


:wup
TITLE Windows Update
ECHO|SET /P="%wup_color%"
ECHO Windows Update
powershell -Command Get-WindowsUpdate
REM TITLE Installing Windows Updates
powershell -Command Install-WindowsUpdate
ECHO%color_reset%
IF %ERRORLEVEL% NEQ 0 GOTO :END
ECHO.
ECHO.

:END
TITLE Cleaning up
IF %cleanup-desktop% EQU 1 DEL/Q "%USERPROFILE%\Desktop\*.lnk" >nul 2>&1
POPD
