@ECHO OFF

REM // make sure we can write to the file kid_built.bin
REM // also make a backup to kid_built.prev.bin
IF NOT EXIST kid_built.bin goto LABLNOCOPY
IF EXIST kid_built.prev.bin del kid_built.prev.bin
IF EXIST kid_built.prev.bin goto LABLNOCOPY
move /Y kid_built.bin kid_built.prev.bin
IF EXIST kid_built.bin goto LABLERROR3
REM IF EXIST kid_built.prev.bin copy /Y kid_built.prev.bin kid_built.bin
:LABLNOCOPY

REM // delete some intermediate assembler output just in case
IF EXIST kid.p del kid.p
IF EXIST kid.p goto LABLERROR2
IF EXIST kid.h del kid.h
IF EXIST kid.h goto LABLERROR1

REM // clear the output window
cls


REM // run the assembler
REM // -xx shows the most detailed error output
REM // -c outputs a shared file (s2.h)
REM // -A gives us a small speedup
set AS_MSGPATH=build/win/msg
set USEANSI=n

"build/win/asw" -xx -c -A kid.asm

REM // if there were errors, a log file is produced
IF EXIST kid.log goto LABLERROR4

REM // combine the assembler output into a rom
IF EXIST build/win/s2p2bin kid.p kid_built.bin kid.h

REM // done -- pause if we seem to have failed, then exit
IF NOT EXIST s2.p goto LABLPAUSE
IF NOT EXIST s2built.bin goto LABLPAUSE

REM // comment this in if you want to immediately run the ROM
REM "../Fusion 3.63.exe" kid_built.bin
exit /b

:LABLPAUSE

pause


exit /b

:LABLERROR1
echo Failed to build because write access to s2.h was denied.
pause


exit /b

:LABLERROR2
echo Failed to build because write access to s2.p was denied.
pause


exit /b

:LABLERROR3
echo Failed to build because write access to s2built.bin was denied.
pause

exit /b

:LABLERROR4
REM // display a noticeable message
echo.
echo **********************************************************************
echo *                                                                    *
echo *   There were build errors/warnings. See s2.log for more details.   *
echo *                                                                    *
echo **********************************************************************
echo.
pause
