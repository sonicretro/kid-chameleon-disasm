@ECHO OFF
REM // build the ROM
call build %1

REM  // compare built ROM against original ROM
echo -------------------------------------------------------------
IF EXIST kid_built.bin ( fc /b kid.bin kid_built.bin
) ELSE echo kid_built.bin does not exist, probably due to an assembly error

pause