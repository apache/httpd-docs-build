@echo off

REM   Copyright (c) 2001-2004 The Apache Software Foundation.  All rights
REM   reserved.

REM   This file is derived from the ant-1.5.3 distribution

REM   +++ Changes for dedicated httpd documentation build +++
REM
REM   - no call of antrc_pre.bat and antrc_post.bat
REM   - DEFAULT_ANT_HOME is the current directory (instead of parent)
REM   - ignore external ANT_OPTS
REM   - ignore external ANT_ARGS
REM   - ignore external CLASSPATH
REM   - set java stack size to 128 MB
REM   - lower down verbosity (because the foreach task would be _very_ verbose
REM     otherwise)
REM   - lcp.bat is found in lib/ (instead of bin/)
REM
REM   (don't know whether this all works unter win9x; tested on win2k) --nd

if "%OS%"=="Windows_NT" @setlocal

rem explicit name our build file (may be replaced by a variable some time)
rem lower down logger verbosity
set ANT_ARGS=-buildfile build.xml -logger org.apache.tools.ant.NoBannerLogger

rem raise stack size ...
set ANT_OPTS=-Xmx128m -mx128m

rem set classpath
set CLASSPATH=lib

rem set regexp engine
set REGEXP=-Dant.regexp.regexpimpl=org.apache.tools.ant.util.regexp.JakartaOroRegexp

rem %~dp0 is expanded pathname of the current script under NT
set DEFAULT_ANT_HOME=%~dp0.

if "%ANT_HOME%"=="" set ANT_HOME=%DEFAULT_ANT_HOME%
set DEFAULT_ANT_HOME=

rem Slurp the command line arguments. This loop allows for an unlimited number
rem of arguments (up to the command line limit, anyway).
set ANT_CMD_LINE_ARGS=%1
if ""%1""=="""" goto doneStart
shift
:setupArgs
if ""%1""=="""" goto doneStart
set ANT_CMD_LINE_ARGS=%ANT_CMD_LINE_ARGS% %1
shift
goto setupArgs
rem This label provides a place for the argument list loop to break out 
rem and for NT handling to skip to.

:doneStart
rem find ANT_HOME if it does not exist due to either an invalid value passed
rem by the user or the %0 problem on Windows 9x
if exist "%ANT_HOME%\lib\ant.jar" goto checkJava

echo ANT_HOME is set incorrectly or ant could not be located. Please set ANT_HOME.
goto end

:checkJava
set _JAVACMD=%JAVACMD%
set LOCALCLASSPATH=%CLASSPATH%
for %%i in ("%ANT_HOME%\lib\*.jar") do call "%ANT_HOME%\lib\lcp.bat" %%i

if "%JAVA_HOME%" == "" goto noJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if "%_JAVACMD%" == "" set _JAVACMD=%JAVA_HOME%\bin\java.exe
if exist "%JAVA_HOME%\lib\tools.jar" set LOCALCLASSPATH=%JAVA_HOME%\lib\tools.jar;%LOCALCLASSPATH%
if exist "%JAVA_HOME%\lib\classes.zip" set LOCALCLASSPATH=%JAVA_HOME%\lib\classes.zip;%LOCALCLASSPATH%
goto runAnt

:noJavaHome
if "%_JAVACMD%" == "" set _JAVACMD=java.exe
echo.
echo Warning: JAVA_HOME environment variable is not set.
echo   If build fails because sun.* classes could not be found
echo   you will need to set the JAVA_HOME environment variable
echo   to the installation directory of java.
echo.

:runAnt
"%_JAVACMD%" %ANT_OPTS% -Xbootclasspath/p:"%LOCALCLASSPATH%" -classpath "%LOCALCLASSPATH%" %REGEXP% "-Dant.home=%ANT_HOME%" org.apache.tools.ant.Main %ANT_ARGS% %ANT_CMD_LINE_ARGS%

:end
set LOCALCLASSPATH=
set _JAVACMD=
set ANT_CMD_LINE_ARGS=

if "%OS%"=="Windows_NT" @endlocal

:mainEnd
