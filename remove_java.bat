@echo off
SetLocal EnableDelayedExpansion
if [%2]==[] (set "keep=0") else (
set "keep=1"
set "arg1= %~1"
if "!arg1!"==" 6" set "arg1=(TM)!arg1!"
set "arg2=%~2"
)
for /l %%g in (1,1,6) do (
	set /a gmod2=%%g%%2
	if !gmod2! EQU 1 (set "regpath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") else (set "regpath=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
	if %%g==1 set "ver=(TM) 6"
	if %%g==2 set "ver=(TM) 6"
	if %%g==3 set "ver= 7"
	if %%g==4 set "ver= 7"
	if %%g==5 set "ver= 8"
	if %%g==6 set "ver= 8"
	for /f "tokens=*" %%G in ('reg query "!regpath!" /s /d /f "Java!ver! Update"') do (
		set var=%%G
		if /i "!var:~0,4!" EQU "HKEY" (
			set run=1
			if %keep%==1 (
				for /f "tokens=*" %%K in ('reg query "%%G" /v /f "DisplayName"') do (
					if "%%K" NEQ "!var2:Java%arg1% Update %arg2%=!" (
						set run=0
						echo Not removing Java%arg1% Update %arg2%
					)
				)
			)
			if !run!==1 (
				for /f "tokens=1,2*" %%H in ('reg query "%%G" /v /f "UninstallString"') do (
					set var=%%J
					if /i "!var:~0,11!" EQU "MsiExec.exe" (
						for /f "tokens=1,2*" %%K in ('reg query "%%G" /v /f "DisplayName"') do if "%%K"=="DisplayName" echo Removing %%M
						%%J /quiet
					)
				)
			)
		)
	)
)
for /d %%G in ("C:\Program Files\Java\*") do for %%H in ("%%~G\*.txt") do del /q "%%H"
