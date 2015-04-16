@echo off
CALL :EVALUATE "chr(8)"
REM "%result% %result%" is used to clear the previous character instead of simply moving the cursor back one
SET "backspace=%result% %result%"
:start
for /l %%G in (1,1,9) do (
	set /p "var=%%G"<nul
	call :delay 5
)
call :delay 1
for /l %%G in (1,1,9) do (
	set /p "var=%backspace%"<nul
	call :delay 5
)
call :delay 1
goto :start
goto :eof

:EVALUATE           -- evaluate with VBS and return to result variable
@IF [%1]==[] ECHO Input argument missing & GOTO :EOF 

ECHO wsh.echo "result="^&eval("%~1") > %temp%\temp.vbs 
FOR /f "delims=" %%a IN ('cscript //nologo %temp%\temp.vbs') do @SET "%%a" 
DEL %temp%\temp.vbs
GOTO:EOF

:delay
if [%1]==0 (set "num=3") else (set "num=%~1")
for /l %%G in (1,1,%num%) do ping -n 1 127.0.0.1>nul
goto :eof
