:: Script created to uninstall and update Java 
:: Created By:  Thomas Patry and Brian Petr
:: Last Edited:  12-22-2014 by Brian petr
@echo off
:: Declaring Variables
::Change this if updating to new version. Make sure you update the JavaRA Defs
::Lastest version HDS Machines can you
set "java_latest=1.7.0_55"
::Metasys Java Version
set "java_6u23=Java(TM) 6 Update 23"
::Kronos Java Version
set "java_6u39=Java(TM) 6 Update 39"
::Other Variables
set "NEWJAVAVER=Java %java_latest:~2,1% Update %java_latest:~6,2%"
set "numberOfVersionsToCheck=3"

::DO NOT CHANGE ANYTHING BELOW THIS UNLESS NEEDED
set networkfolder=\\users.campus\NETLOGON\HDS\machines\shutdown\Java
set logfolder=C:\Logs

::Allow variables to be updated inside of loops
Setlocal EnableDelayedExpansion

::Checking to see if the machine is the do not install list. If in the list, will cancel the install.
for /F %%G in ( %networkfolder%\Blacklist.txt ) do (
	if /i %%G==%computername% (
		echo Will not update Java. Exiting.
		goto :eof
	)
)

if not exist "%logfolder%" mkdir "%logfolder%"
echo %date% >> %logfolder%\Java-%computername%.txt

::Checking Current Java Version

::count: number of Java versions found, both x86 and x64
set count=0

::iterations: number of possibilities: number of major Java releases to check (6, 7, 8 makes 3 releases) times 2 for x86 and x64
set /a iterations=%numberOfVersionsToCheck%*2

::half: used to split the possibilities into 2 (half for x86 and half for x64)
set /a "half=%iterations%/2"

::Loop to find all Java versions installed
for /l %%g in (1,1,%iterations%) do (

	::gmod: cycle through each version of Java to check
	set /a "gmod=%%g%%!half!"
	if !gmod! EQU 0 set "ver=(TM) 6"
	if !gmod! EQU 1 set "ver= 7"
	if !gmod! EQU 2 set "ver= 8"
	
	::if %%g<!half! do x86 registry path, else do x64 registry path
	if %%g LEQ !half! (set "regpath=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") else (set "regpath=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")
	
	::search for Java versions
	for /f "tokens=*" %%G in ('reg query "!regpath!" /s /d /f "Java!ver! Update"') do (
		set var=%%G
		
		::if first 4 letters of output are "HKEY" (used to parse output of reg query for actual registry path)
		if /i "!var:~0,4!" EQU "HKEY" (
			
			::find actual display name within that path (Java !ver! Update !number!)
			for /f "tokens=1,2*" %%H in ('reg query "%%G" /v /f "DisplayName"') do (
				set var=%%J
				
				::if first 4 letters of output are "Java" (used to parse output of reg query for relevent Java information)
				if /i "!var:~0,4!" EQU "Java" (
					
					::increase count
					set /a count=!count!+1
					
					::add java version to JAVAVER array
					set JAVAVER!count!=%%J
					
					::echo version to log file
					echo Currently installed: %%J >> %logfolder%\Java-%computername%.txt
				)
			)
		)
	)
)

::remove "(64-bit)" if necessary from JAVAVER array
for /l %%G in (1,1,%count%) do if "!JAVAVER%%G:~-7,-1!"=="64-bit" set "JAVAVER%%G=!JAVAVER%%G:~0,-9!"

::Killing any Java Processes
start /w taskkill /F /IM jusched.exe
start /w taskkill /F /IM jp2launcher.exe
start /w taskkill /F /IM java.exe
start /w taskkill /F /IM javaw.exe
start /w taskkill /F /IM jqs.exe

::Exit if current version
for /l %%G in (1,1,%count%) do if "!JAVAVER%%G!" == "%java_6u39%" goto :6u39
for /l %%G in (1,1,%count%) do if "!JAVAVER%%G!" == "%java_6u23%" goto :6u23
for /l %%G in (1,1,%count%) do if "!JAVAVER%%G!" == "%NEWJAVAVER%" goto :7u55
goto :skip_specifics

:6u23
echo Removing all versions other than Java 6 Update 23. >> %logfolder%\Java-%computername%.txt
call "%~dp0remove_java.bat" 6 23
goto :end
:6u39
echo Removing all versions other than Java 6 Update 39. >> %logfolder%\Java-%computername%.txt
call "%~dp0remove_java.bat" 6 39
goto :end
:7u55
echo Removing all versions other than Java 7 Update 55. >> %logfolder%\Java-%computername%.txt
call "%~dp0remove_java.bat" 7 55
goto :end

:skip_specifics

echo Old Version: %JAVAVER% >> %logfolder%\Java-%computername%.txt

::Remove all Java 6/7/8 versions.
call "%~dp0remove_java.bat"
%networkfolder%\JavaRa.exe /purge /silent

:: Check to see if machine is x86 or x64 type of OS
if %PROCESSOR_ARCHITECTURE%==x86 (
	%networkfolder%\"jre-%java_latest%-x86.exe" /s WEB_JAVA=1 JAVAUPDATE=0 WEB_JAVA_SECURITY_LEVEL=M
	echo %NEWJAVAVER% > "C:\Program Files\Java\jre7\%java_latest%.txt"
) else (
	%networkfolder%\"jre-%java_latest%-x86.exe" /s WEB_JAVA=1 JAVAUPDATE=0 WEB_JAVA_SECURITY_LEVEL=M
	%networkfolder%\"jre-%java_latest%-x64.exe" /s WEB_JAVA=1 JAVAUPDATE=0 WEB_JAVA_SECURITY_LEVEL=M
	echo %NEWJAVAVER% > "C:\Program Files\Java\jre7\%java_latest%.txt"
)

reg delete HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run /v SunJavaUpdateSched /f
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SunJavaUpdateSched /f

for /d %%G in (C:\Users\*) do (
for /f "usebackq" %%F in (`type "%%G\appdata\locallow\sun\java\deployment\deployment.properties"^|find /c /i "deployment.security.mixcode=HIDE_RUN"`) do (
if %%F==0 echo deployment.security.mixcode=HIDE_RUN>>"%%G\appdata\locallow\sun\java\deployment\deployment.properties"
)
)
echo Java Updated to: %NEWJAVAVER% >> %logfolder%\Java-%computername%.txt

:end
echo. >> %logfolder%\Java-%computername%.txt
echo "Java update is complete."
timeout 5
