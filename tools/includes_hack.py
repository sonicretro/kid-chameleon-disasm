import math
import os

# Place it in the same folder as kid.bin and this script will
# create a subfolder hack/ that contains some .asm files with
# instructions where to put them/insert their content in kid.asm
MapHeader_Index = 0x100008
MapHeader_Offset = 0x100000
Platform_Index = 0x43A6
Platform_Offset = 0x2BB6
Bgscroll_Index = 0x7B1EC
Number_Levels = 126

f = open("kid.bin", "rb")
b = f.read()

# read /length/ bytes starting at /addr/ as integer 
btoi = lambda addr,length: int.from_bytes(b[addr:addr+length], byteorder='big')


# get a single bit from position x
def get_bit(x):
    byte = x // 8
    bitpos = x % 8
    return (b[byte] >> (7-bitpos)) & 0x01


# get a n bits starting from position x
# first bit is most significant, last bit least significant
def get_bits(x, n):
    value = 0
    for i in range(n):
        value <<= 1
        value += get_bit(x+i)
    return value


# return a set of all used platform preset addresses
def get_platform_presets(addr):
    x = btoi(addr, 2)
    presets_addrs = set()
    while x != 0xFFFF:
        x = btoi(addr, 2)
        TS = btoi(addr+8, 1)
        PPP = btoi(addr+10, 2)
        t = TS >> 7

        if TS & 0x79:
            print("bad platform!")
        if t == 0 and not (PPP+0x3602 == 0x10000 or PPP==0xFFFF):
            presets_addrs.add(PPP+0x3602) 
        addr += 12
        x = btoi(addr, 2)
    return presets_addrs


os.makedirs("hack", exist_ok=True)


mapheader_addrs = dict()
platform_addrs = dict()
enemy_addrs = dict()
foreground_addrs = dict()
background_addrs = dict()
block_addrs = dict()
bgscroll_addrs = dict()
presets_addrs = set()

fbgscroll = open("hack/bgscroll.txt", "w")
fbgscroll.write("; Replace the list of pointers at off_7B1EC with the following:\n\n")
fbgscroll.write("off_7B1EC:")

fplatforms = open("hack/platforms.txt", "w")
fplatforms.write("; Replace the offset index at MapPtfmLayout_Index with the following:\n\n")
fplatforms.write("MapPtfmLayout_Index:")

fleveldata = open("hack/leveldata.txt", "w")
# MapHeader_Index to  MainAddr_Index
fleveldata.write("; Replace everything from MapHeader_Index until right before MainAddr_Index with the content of this file:\n\n")
fleveldata.write("MapHeader_Index:\n")

# dump platform, bgscroll, header, enemy, foreground and block
# layout for each level to files.
for lev in range(Number_Levels):
    addr = btoi(MapHeader_Index+2*lev, 2) + MapHeader_Offset
    platform = btoi(Platform_Index+2*lev, 2) + Platform_Offset
    bgscroll = btoi(Bgscroll_Index+4*lev, 4)
    # need this because of load of duplicates
    if platform not in platform_addrs and platform != 0x44A2:
        platform_addrs[platform] = lev
        pa = get_platform_presets(platform)
        presets_addrs |= pa
    fplatforms.write("\t\tdc.w\tunk_{:X}-unk_2BB6\t; {:2X}\n".format(platform, lev))

    if bgscroll not in bgscroll_addrs:
        bgscroll_addrs[bgscroll] = lev
    fbgscroll.write("\t\tdc.l\tunk_{:X}\t; {:2X}\n".format(bgscroll, lev))


    if addr == 0x40FF6:
        # for some entries, the pointer points to invalid data
        # specifically, to the address after the last valid map header
        fleveldata.write("\t\tdc.w\tunk_40FF6-word_4033A\t; {:2X}\n".format(lev))
        continue
    fleveldata.write("\t\tdc.w\tstru_{:X}-word_4033A\t; {:2X}\n".format(addr, lev))

    # don't process duplicate entries.
    if addr in mapheader_addrs:
        continue

    mapheader_addrs[addr] = lev

    bgtheme = btoi(addr+3, 1) & 0x0F
    foreground = btoi(addr+12, 4)
    block = btoi(addr+16, 4)
    background = btoi(addr+20, 4)
    enemy = btoi(addr+24, 4)

    if enemy not in enemy_addrs:
        enemy_addrs[enemy] = lev
    if foreground not in foreground_addrs:
        foreground_addrs[foreground] = lev
    if block not in block_addrs:
        block_addrs[block] = lev
    if background not in background_addrs:
        if bgtheme in [3,5,7,9]: # layered
            background_addrs[background] = (1, lev)
        else: # chunked
            background_addrs[background] = (0, lev)


fleveldata.write("\nMapOrder_Index:\n")
fleveldata.write("\tinclude\t\"level/maporder.asm\"\n")


for addr,lev in sorted(mapheader_addrs.items()):
    foreground = btoi(addr+12, 4)
    block = btoi(addr+16, 4)
    background = btoi(addr+20, 4)
    enemy = btoi(addr+24, 4)
    fleveldata.write("stru_{:X}:\tmaphdr\t\"level/header/{:02X}.bin\", unk_{:X}, unk_{:X}, unk_{:X}, stru_{:X}\n".format(addr, lev, foreground, block, background, enemy))

for addr,lev in sorted(foreground_addrs.items()):
    fleveldata.write("unk_{:X}:\tbinclude\t\"level/foreground/{:02X}.bin\"\n\talign 2\n".format(addr, lev))

for addr,tl in sorted(background_addrs.items()):
    bgtype = tl[0] # 0=chunked, 1=layered
    lev = tl[1]
    if bgtype == 0:
        btype = btoi(addr, 1)
        if btype == 0x80:
            w1 = btoi(addr, 2)
            l2 = btoi(addr+2, 4)
            ref_addr = btoi(addr+6, 4)
            fleveldata.write("unk_{:X}:\tdc.w\t${:X}\n\tdc.l\t${:X}\n\tdc.l\tunk_{:X}\n".format(addr,w1,l2,ref_addr))
        else:
            fleveldata.write("unk_{:X}:\tbinclude\t\"level/background/{:02X}.bin\"\n\talign 2\n".format(addr, lev))
    else: # layered format
        fleveldata.write("unk_{:X}:\tbinclude\t\"level/background/{:02X}_layered.bin\"\n".format(addr, lev))

for addr,lev in sorted(block_addrs.items()):
    fleveldata.write("unk_{:X}:\tbinclude\t\"level/block/{:02X}.bin\"\n\talign 2\n".format(addr, lev))

for addr,lev in sorted(enemy_addrs.items()):
    fleveldata.write("stru_{:X}:\tdc.l\tstru_{:X}+$10\n\tbinclude\t\"level/enemy/{:02X}.bin\"\n".format(addr, addr, lev))

fleveldata.close()


# make an additional file of the platform presets that are
# actually in used in the game. This is mainly useful for hacks,
# and not used in the bit-perfect disassembly.
fpresets = open("hack/platform_scripts.asm", "w")
fpresets.write("; Replace level/platform_scripts.asm with this file.\n")
fpresets.write("; At the beginning of kid.asm, set platforms_asm = 1.\n\n")
for addr0 in sorted(presets_addrs):
    addr = addr0
    fpresets.write("PlatformScript_{:X}:\t; relative offset: {:04X}\n".format(addr0, addr0-0x3602))
    while True:
        count = btoi(addr+0, 2)
        xvel = btoi(addr+2, 4)
        if xvel > 0x80000000:
            xvel -= 0x100000000
        yvel = btoi(addr+6, 4)
        if yvel > 0x80000000:
            yvel -= 0x100000000
        if count != 0xFFFF:
            cmd = "\tptfm_move\t${:X}, ${:X}, ${:X}\n".format(count, xvel, yvel)
            cmd = cmd.replace("$-", "-$") # minus sign needs to be before $ sign
            fpresets.write(cmd)
        else:
            fpresets.write("\tdc.w\t$FFFF\n")
            if xvel == addr0:
                fpresets.write("\tdc.l\tPlatformScript_{:X}\n".format(xvel))
            else:
                fpresets.write("\tdc.l\tPlatformScript_{:X}+${:X}\n".format(addr0, xvel-addr0))
            break
        addr += 10
fpresets.close()



fplatforms.write("""\n\n; Replace the list of includes starting at unk_2BB6 and ending
    after unk_35C4 (before the else) with the following:\n\n""")
for addr,lev in sorted(platform_addrs.items()):
    fplatforms.write("unk_{:X}:\tinclude\t\"level/platform/{:02X}.asm\"\n".format(addr, lev))
fplatforms.close()

fbgscroll.write("""\n\n; Replace the list of bincludes starting at unk_9F9F2 and ending
    after unk_A0934 (where the filler bytes are) with the following:\n\n""")
for addr,lev in sorted(bgscroll_addrs.items()):
    fbgscroll.write("unk_{:X}:\tbinclude\t\"level/bgscroll/{:02X}.bin\"\n".format(addr, lev))
fbgscroll.close()


print("DONE: See the hack/ subfolder for more info.")