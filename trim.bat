@echo off
if [%1]==[] goto :usage
Setlocal EnableDelayedExpansion
set "vart1=%~1"

:trim
set error=0
if "!%vart1%:~0,1!"==" " (
set "%vart1%=!%vart1%:~1!"
set error=1
)
if "!%vart1%:~-1,1!"==" " (
set "%vart1%=!%vart1%:~0,-1!"
set error=1
)

if %error%==1 goto :trim
set vart2=!%vart1%!
Endlocal & call set "%vart1%=%vart2%"
