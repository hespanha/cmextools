@echo off
REM FIX PATH
REM path
call %1 %2
REM path
shift
shift

REM COLLECT REMAINING ARGUMENTS
:loop
if [%1]==[] goto afterloop
set params=%params% %1
shift
goto loop
:afterloop

REM EXECUTE COMMAND
echo %params%
call %params%
set RETURNVALUE=%ERRORLEVEL%

EXIT /B %RETURNVALUE%


