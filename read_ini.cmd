@ECHO off
REM How to read key=value pairs from an .ini like file and make them take effect as vars in a .cmd
SETLOCAL
SET INIFILE="%USERPROFILE%\up.cmd.ini"
IF EXIST %INIFILE% (
  FOR /F "usebackq tokens=*" %%A IN (%INIFILE%) DO SET %%A
)
