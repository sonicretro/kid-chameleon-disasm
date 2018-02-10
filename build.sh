#! /bin/sh -e
# -e stops it on an error

echo Assembling...

env AS_MSGPATH=build/linux/msg build/linux/asl -xx -c -A -U kid.asm

if [ -f kid.p ]; then
    build/linux/s2p2bin kid.p kid_built.bin kid.h
    # ../Fusion kid_built.bin
    exit 1
fi

