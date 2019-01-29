import math
import os
from shutil import copyfile

# Place it in the same folder as kid.bin and this script will
# generate files for all 126 level slots that can be edited.
Platform_Index = 0x43A6
Bgscroll_Index = 0x7B1EC
Number_Levels = 126

# The instruction
# move.l    #MapHeader_Index,a0
# appears twice in the ROM, at addresses 11A42 and 19AEA.
# It is compiled into 207C XXXX XXXX, where X is the address
# of MapHeader_Index. In the original ROM, this is 0x40342,
# in hacks this is 0x100008.
# If these two addresses don't match, then something strange
# is going on in the ROM and we abort.
Pointer1To_Mapheader_Index = 0x11A44
Pointer2To_Mapheader_Index = 0x19AEC
# Same for the base address.
Pointer1To_Mapheader_BaseAddress = 0x11A50
Pointer2To_Mapheader_BaseAddress = 0x19AF8
# addi.l  #Platform_Offset,d7 instruction @2382
PointerTo_Platform_Offset = 0x2384

f = open("kid.bin", "rb")
b = f.read()

# read /length/ bytes starting at /addr/ as integer 
btoi = lambda addr,length: int.from_bytes(b[addr:addr+length], byteorder='big')

# Get the main addresses of the level index.
MapHeader_BaseAddress1 = btoi(Pointer1To_Mapheader_BaseAddress, 4)
MapHeader_BaseAddress2 = btoi(Pointer2To_Mapheader_BaseAddress, 4)
if MapHeader_BaseAddress1 == MapHeader_BaseAddress2:
    MapHeader_BaseAddress = MapHeader_BaseAddress1
else:
    print("Something seems to be broken in the ROM. Aborting.")
    exit(-1)
MapHeader_Index1 = btoi(Pointer1To_Mapheader_Index, 4)
MapHeader_Index2 = btoi(Pointer2To_Mapheader_Index, 4)
if MapHeader_Index1 == MapHeader_Index2:
    MapHeader_Index = MapHeader_Index1
else:
    print("Something seems to be broken in the ROM. Aborting.")
    exit(-1)
# Also get the platform offset.
Platform_Offset = btoi(PointerTo_Platform_Offset, 4)
# We're doing these things so splitting works both for hacks
# and the original game.


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

# functions to make a blank template files of various types.
def make_enemy_template(lev):
    with open("level/enemy/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x00\x00\x00\x00\xff\xff\xff\xff\xff\xff\x7d\x00\x00\x00')

def make_foreground_template(lev):
    with open("level/foreground/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x00\x06\xa3\x46\x8d\x1a\x34\x60\x00\x01\x67\x01\xfe\x01\xfe\x01\xfe\x01\xfe\x00\x00')

def make_header_template(lev):
    with open("level/header/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x02\x02\x04\x04\x00\x30\x01\x00\x01\xb0\x01\x00')

def make_platform_template(lev):
    with open("level/platform/{:02X}.asm".format(lev) , "w") as ftemp:
        ftemp.write('    ptfm\t0,0,0,0,0,0,0,0,0,0,PlatformScript_Nothing-PlatformScript_BaseAddress\n')
        ftemp.write('    dc.w\t$FFFF\n')

def make_block_template(lev):
    with open("level/block/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x40\x74\xff\xf0')

def make_bgscroll_template(lev):
    with open("level/bgscroll/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x00' * 0x23 + b'\xff')

def make_background_template(lev):
    with open("level/background/{:02X}.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\xff\xff')

def make_layered_background_template(lev):
    with open("level/background/{:02X}_layered.bin".format(lev) , "wb") as ftemp:
        ftemp.write(b'\x10' * 0x24)


# os.makedirs("hack", exist_ok=True)

# dicts that map each address to a map number.
mapheader_addrs = dict()
platform_addrs = dict()
enemy_addrs = dict()
foreground_addrs = dict()
background_addrs = dict() # also type: chunked or layered
block_addrs = dict()
bgscroll_addrs = dict()
presets_addrs = set()


# First pass: populate the background dict.
# This is necessary as some backgrounds refer to others.
for lev in range(Number_Levels):
    addr = btoi(MapHeader_Index+2*lev, 2) + MapHeader_BaseAddress
    if addr == 0x40FF6 or addr == MapHeader_BaseAddress:
        continue
    background = btoi(addr+20, 4)
    bgtheme = btoi(addr+3, 1) & 0x0F
    if background not in background_addrs:
        if btoi(background, 2) == 0x8000: # copied
            copied_addr = btoi(background+6, 4) # address of copied layout
            background_addrs[background] = (2, lev, copied_addr)
        elif bgtheme in [3,5,7,9]: # layered
            background_addrs[background] = (1, lev)
        else: # chunked
            background_addrs[background] = (0, lev)

# create file with map header index and populate dictionaries
# mapping addresses to their level number
fheader_idx = open("level/mapheader_index.asm", "w")
fheader_def = open("level/mapheader_definitions.asm", "w")
fbg = open("level/background_includes.asm", "w")
ffg = open("level/foreground_includes.asm", "w")
fblock = open("level/block_includes.asm", "w")
fenemy = open("level/enemy_includes.asm", "w")
fbgs_idx = open("level/bgscroll_index.asm", "w")
fbgs_inc = open("level/bgscroll_includes.asm", "w")
fplat_inc = open("level/platform_includes.asm", "w")
fplat_idx = open("level/platform_index.asm", "w")
flevelfiles = open("level/level_files.txt", "w")

for lev in range(Number_Levels):
    addr = btoi(MapHeader_Index+2*lev, 2) + MapHeader_BaseAddress

    # Every map gets its own set of files.
    fheader_idx.write("\t\tdc.w\tMapHeader_{:02X}-MapHeader_BaseAddress\t; {:2X}\n".format(lev, lev))
    fheader_def.write("MapHeader_{:02X}:\tmaphdr\t\"level/header/{:02X}.bin\", ForegroundLayout_{:02X}, BlockLayout_{:02X}, BackgroundLayout_{:02X}, EnemyLayout_{:02X}\n".format(lev, lev, lev, lev, lev, lev))
    flevelfiles.write("{:02X}\tplatform/{:02X}.bin bgcsroll/{:02X}.bin header/{:02X}.bin enemy/{:02X}.bin foreground/{:02X}.bin block/{:02X}.bin".format(lev, lev, lev, lev, lev, lev, lev))
    ffg.write("ForegroundLayout_{:02X}:\tbinclude\t\"level/foreground/{:02X}.bin\"\n\talign 2\n".format(lev, lev))
    fblock.write("BlockLayout_{:02X}:\tbinclude\t\"level/block/{:02X}.bin\"\n\talign 2\n".format(lev, lev))
    fenemy.write("EnemyLayout_{:02X}:\tdc.l\tEnemyLayout_{:02X}+$10\n\tbinclude\t\"level/enemy/{:02X}.bin\"\n".format(lev, lev, lev))
    fbgs_idx.write("\t\tdc.l\tBackgroundScroll_{:02X}\t; {:2X}\n".format(lev, lev))
    fbgs_inc.write("BackgroundScroll_{:02X}:\tbinclude\t\"level/bgscroll/{:02X}.bin\"\n".format(lev, lev))
    fplat_idx.write("\t\tdc.w\tPlatformLayout_{:02X}-PlatformLayout_BaseAddress\t; {:2X}\n".format(lev, lev))
    fplat_inc.write("PlatformLayout_{:02X}:\tinclude\t\"level/platform/{:02X}.asm\"\n".format(lev, lev))

    foreground = btoi(addr+12, 4)
    block = btoi(addr+16, 4)
    background = btoi(addr+20, 4)
    enemy = btoi(addr+24, 4)
    bgscroll = btoi(Bgscroll_Index+4*lev, 4)
    platform = btoi(Platform_Index+2*lev, 2) + Platform_Offset

    # Handle invalid header entries
    if addr == 0x40FF6 or addr == MapHeader_BaseAddress:
        # for some entries, the pointer points to invalid data
        # specifically, to the address after the last valid map header
        # In hacks, invalid entries seems to point at the base address.
        # ftemp.write("\t\tdc.w\tMapHeader_Invalid-MapHeader_BaseAddress\t; {:2X}\n".format(lev))
        # Create blank templates for this level.
        make_foreground_template(lev)
        make_background_template(lev)
        make_block_template(lev)
        make_enemy_template(lev)
        make_header_template(lev)
        fbg.write("BackgroundLayout_{:02X}:\tbinclude\t\"level/background/{:02X}.bin\"\n\talign 2\n".format(lev, lev))
        flevelfiles.write(" background/{:02X}.bin\n".format(lev))

    # Handle duplicate entries.
    elif addr in mapheader_addrs:
        # duplicate entry: we only need to put the right label in the index,
        # but no further processing needed as this has already been processed.
        # ftemp.write("\t\tdc.w\tMapHeader_{:02X}-MapHeader_BaseAddress\t; {:2X}\n".format(mapheader_addrs[addr], lev))
        # Make copies of the files of the original level.
        orig_lev = mapheader_addrs[addr]
        copyfile("level/foreground/{:02X}.bin".format(orig_lev), "level/foreground/{:02X}.bin".format(lev))
        copyfile("level/block/{:02X}.bin".format(orig_lev), "level/block/{:02X}.bin".format(lev))
        copyfile("level/enemy/{:02X}.bin".format(orig_lev), "level/enemy/{:02X}.bin".format(lev))
        copyfile("level/header/{:02X}.bin".format(orig_lev), "level/header/{:02X}.bin".format(lev))
        if background_addrs[background][0] == 0: # chunked
            copyfile("level/background/{:02X}.bin".format(orig_lev), "level/background/{:02X}.bin".format(lev))
            fbg.write("BackgroundLayout_{:02X}:\tbinclude\t\"level/background/{:02X}.bin\"\n\talign 2\n".format(lev, lev))
            flevelfiles.write(" background/{:02X}.bin\n".format(lev))
        elif background_addrs[background][0] == 1: # layered
            copyfile("level/background/{:02X}_layered.bin".format(orig_lev), "level/background/{:02X}_layered.bin".format(lev))
            fbg.write("BackgroundLayout_{:02X}:\tbinclude\t\"level/background/{:02X}_layered.bin\"\n\talign 2\n".format(lev, lev))
            flevelfiles.write(" background/{:02X}_layered.bin\n".format(lev))
        else: #copied
            copied_addr = background_addrs[background][2]
            copied_lev = background_addrs[copied_addr][1]
            fbg.write("BackgroundLayout_{:02X}:\tdc.w\t$8000\n\tdc.l\t$0\n\tdc.l\tBackgroundLayout_{:02X}\n".format(lev, copied_lev))
            flevelfiles.write(" background/{:02X}.bin\n".format(copied_lev)) # background files are never layered

    # New valid entry
    else:
        mapheader_addrs[addr] = lev

        if enemy not in enemy_addrs:
            enemy_addrs[enemy] = lev
        else: # duplicate enemy layout
            copyfile("level/enemy/{:02X}.bin".format(enemy_addrs[enemy]), "level/enemy/{:02X}.bin".format(lev))

        if foreground not in foreground_addrs:
            foreground_addrs[foreground] = lev
        else: # duplicate fg layout
            copyfile("level/foreground/{:02X}.bin".format(foreground_addrs[foreground]), "level/foreground/{:02X}.bin".format(lev))

        if block not in block_addrs:
            block_addrs[block] = lev
        else: # duplicate block layout
            copyfile("level/block/{:02X}.bin".format(block_addrs[block]), "level/block/{:02X}.bin".format(lev))

        orig_lev = background_addrs[background][1]
        if background_addrs[background][0] == 0: # chunked
            if orig_lev != lev: # two levels sharing same bg --> make copy
                copyfile("level/background/{:02X}.bin".format(orig_lev), "level/background/{:02X}.bin".format(lev))
            fbg.write("BackgroundLayout_{:02X}:\tbinclude\t\"level/background/{:02X}.bin\"\n\talign 2\n".format(lev, lev))
            flevelfiles.write(" background/{:02X}.bin\n".format(lev))
        elif background_addrs[background][0] == 1: # layered
            if orig_lev != lev: # two levels sharing same bg --> make copy
                copyfile("level/background/{:02X}_layered.bin".format(orig_lev), "level/background/{:02X}_layered.bin".format(lev))
            fbg.write("BackgroundLayout_{:02X}:\tbinclude\t\"level/background/{:02X}_layered.bin\"\n\talign 2\n".format(lev, lev))
            flevelfiles.write(" background/{:02X}_layered.bin\n".format(lev))
        else: #copied
            copied_addr = background_addrs[background][2]
            copied_lev = background_addrs[copied_addr][1]
            fbg.write("BackgroundLayout_{:02X}:\tdc.w\t$8000\n\tdc.l\t$0\n\tdc.l\tBackgroundLayout_{:02X}\n".format(lev, copied_lev))
            flevelfiles.write(" background/{:02X}.bin\n".format(copied_lev)) # background files are never layered


    if bgscroll in bgscroll_addrs:
        # Duplicate entry --> copy file
        orig_lev = bgscroll_addrs[bgscroll]
        copyfile("level/bgscroll/{:02X}.bin".format(orig_lev), "level/bgscroll/{:02X}.bin".format(lev))
    else:
        # New valid entry
        bgscroll_addrs[bgscroll] = lev


    if platform in platform_addrs:
        # Duplicate entry --> copy file
        orig_lev = platform_addrs[platform]
        copyfile("level/platform/{:02X}.asm".format(orig_lev), "level/platform/{:02X}.asm".format(lev))
    # elif platform == 0x44A2:
    #     # blank entry
    #     make_platform_template(lev)
    else:
        # New valid entry
        platform_addrs[platform] = lev
        pa = get_platform_presets(platform)
        presets_addrs |= pa


fheader_idx.close()
fheader_def.close()
ffg.close()
fbg.close()
fblock.close()
fenemy.close()
fbgs_idx.close()
fbgs_inc.close()
fplat_idx.close()
fplat_inc.close()
flevelfiles.close()


# make an additional file of the platform presets that are
# actually in used in the game. This is mainly useful for hacks,
# and not used in the bit-perfect disassembly.
ftemp = open("level/platform_scripts.asm", "w")
ftemp.write("PlatformScript_Nothing  = $10000\n\nPlatformScript_BaseAddress:\n")
for addr0 in sorted(presets_addrs):
    addr = addr0
    ftemp.write("PlatformScript_{:X}:\t; relative offset: {:04X}\n".format(addr0, addr0-0x3602))
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
            ftemp.write(cmd)
        else:
            ftemp.write("\tdc.w\t$FFFF\n")
            if xvel == addr0:
                ftemp.write("\tdc.l\tPlatformScript_{:X}\n".format(xvel))
            else:
                ftemp.write("\tdc.l\tPlatformScript_{:X}+${:X}\n".format(addr0, xvel-addr0))
            break
        addr += 10
ftemp.close()


print("DONE!")