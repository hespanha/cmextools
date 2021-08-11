REM This file is part of Tencalc.
REM
REM Copyright (C) 2012-21 The Regents of the University of California
REM (author: Dr. Joao Hespanha).  All rights reserved.

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


