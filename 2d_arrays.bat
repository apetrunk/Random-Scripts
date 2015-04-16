@echo off
SetLocal EnableDelayedExpansion
for /l %%G in (1,1,5) do (for /l %%H in (1,1,5) do (set /a "array[%%G][%%H]=%%G*%%H"))
if [%1]==[] (set /p "place=Enter array index (x,y): ") else (if [%2]==[] (set "place=%~1") else (set "place=%~1,%~2"))
for /f "tokens=1 delims=," %%G in ("%place%") do set "x=%%G"
for /f "tokens=2 delims=," %%G in ("%place%") do set "y=%%G"
echo x=%x% y=%y%

echo array[%x%][%y%] = !array[%x%][%y%]!

call set "output=%%array[%x%][%y%]%%"
echo array[%x%][%y%] = %output%
