REM The MIT License (MIT)
REM Copyright (c) 2014 brunoais
REM Permission is hereby granted, free of charge, to any person obtaining a copy
REM of this software and associated documentation files (the "Software"), to deal
REM in the Software without restriction, including without limitation the rights
REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
REM copies of the Software, and to permit persons to whom the Software is
REM furnished to do so, subject to the following conditions:
REM 
REM The above copyright notice and this permission notice shall be included in all
REM copies or substantial portions of the Software.
REM
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
REM SOFTWARE.

@echo off
setlocal enableextensions enabledelayedexpansion

REM Parameters management (all optional)

REM Set defaults
SET PcheckDir=.

REM Searching for files with single hard link (1) or multiple hard link (2, by default)
SET PcheckKind=1

IF %1 EQU 1 (
	SET PcheckDir=.
	SET PcheckKind=1
) ELSE (
	IF "%1"=="" (
		SET PcheckDir=.
	)	
	IF "%2"=="" (
		SET PcheckKind=2
	)
)


REM Rights elevation
REM Adapted from http://superuser.com/a/757106/176343

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
	if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	echo UAC.ShellExecute "%~f0", "%PcheckDir% %PcheckKind%", "%CD%", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
    pushd "%CD%"
    CD /D "%~dp0"


REM adapted from http://stackoverflow.com/questions/17687358/batch-file-command-line-to-get-target-path-of-internet-shortcut-url-in-the

pushd %1
pushd %2

@echo off

REM For each file in directory
for %%F in (%PcheckDir%\*) do (
	call :checkHardLink "%%~dpnxF" %PcheckKind%
)
popd
popd


pause
goto end


:checkHardLink inputfile
REM Get the hardlink list.
REM This works because fsutil lists a single hardlink per line in the output
set "cmd=fsutil hardlink list %1 | find /V /C """

for /f %%l in ('!cmd!') do set copies=%%l


IF %PcheckKind% EQU 1 (
	REM Searching for files with single hard link
	IF %copies% EQU 1 (
		Echo %copies%: %1% 
	)
) ELSE (
	REM Searching for files with multiple hard link
	IF %copies% NEQ 1 (
		Echo %copies%: %1% 
	)
)
:end
