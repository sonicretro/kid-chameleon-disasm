import math
import os

MapHeader_Index = 0x40342
MapHeader_Offset = 0x4033A
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


def length_enemy(x):
    '''
    (header)
    32-bit address pointing to 'H1'
    12 unknown bytes

    H1 - unknown (byte)
    H2 - Number of objects in level (byte)

    H2 entries of 8 bytes each: 
    AA - Object
    BB - Flags (00 to respawn DRAGON after death, FF to make DRAGON kill permanent)
    CCDD - Hit points + 1 (0000 - 7FFE)
    EEFF - X position
    GGHH - Y position
    '''
    data_start = btoi(x,4)
    if data_start != x+16:
        print("Gap between enemy header and data: {:x}!".format(x))
    num_objects = btoi(data_start+1, 1)
    return num_objects*8 + 2 + 16


def length_tile(x):
    '''
    Data consists of two parts: a bitstream of control (key) bits,
    and a byte stream of input bytes. The control bits determine
    how to read and interpret the bytes.

    2 bytes are the offset to the input bytes, followed by 
    block of control bits and
    block of input bytes

    Control bits 0100011 with input 00 00 terminates compression.
    '''
    off_input = btoi(x,2)
    input_start = x + off_input + 2
    addr_input = input_start
    bitpos = 8*(x+2)

    def dprint(x, end):
        pass
        # if bitpos >= 8*(input_start-2):
        #     print(x, end=end)

    while bitpos < 8*input_start:
        b0 = get_bit(bitpos)
        bitpos += 1
        dprint(b0, end=' ')
        if b0 == 0:
            b1 = get_bit(bitpos)
            bitpos += 1
            dprint(b1, end=' ')
            if b1 == 0:
                # one bit of extra info
                bitpos += 1
                # 00 reads one input byte
                dprint("{:02x}".format(btoi(addr_input,1)), end='\n')
                addr_input += 1
            else:
                # 01
                b234 = get_bits(bitpos,3)
                bitpos += 3
                b56 = get_bits(bitpos,2)
                bitpos += 2
                if b56 == 3:
                    # reads two input bytes if 01:xxx:11
                    dprint("{:04x}".format(btoi(addr_input,2)), end='\n')
                    addr_input += 2
                    if btoi(addr_input-2,2) == 0 and b234 == 0:
                        # bits are 0100011 and input is 2 bytes of 0 --> stop
                        break
                else:
                    # reads one input byte if 01:xxx:xx
                    dprint("{:02x}".format(btoi(addr_input,1)), end='\n')
                    addr_input += 1
        else:
            # 1 reads one input byte
            dprint("{:02x}".format(btoi(addr_input,1)), end='\n')
            addr_input += 1

    return addr_input - x


def length_block(x):
    bitpos = 8*x + 8 # we're skipping the first byte because it's $40
    xbits = get_bits(bitpos, 4)
    bitpos += 4
    ybits = get_bits(bitpos, 4)
    bitpos += 4

    bitpos += 1 # hidden bit, we don't need this
    block_type = get_bits(bitpos, 5)
    bitpos += 5
    #print(block_type)

    while block_type != 0x1F:
        x_pos = get_bits(bitpos, xbits)
        bitpos += xbits
        while x_pos != (1<<xbits) - 1:
            #y_pos = get_bits(bitpos, ybits)
            bitpos += ybits # we don't need the y position
            #print(x_pos, y_pos)
            if block_type == 1: # Prize
                numblocks = get_bits(bitpos, 4)
                bitpos += 4 + 1 + (numblocks+1) * 5
            elif block_type == 3: # Ghost
                bitpos += 31
            elif block_type == 4: # Telepad
                bitpos += 25
            elif block_type == 10 or block_type == 12: # Drill
                numblocks = get_bits(bitpos, 4)
                bitpos += 4 + 1 + (numblocks+1) * 4
            elif block_type == 11: # Lift (R)
                pass
            elif block_type == 16: # Collision Mod
                numblocks = get_bits(bitpos, 4)
                bitpos += 4 + 1 + (numblocks+1) * 3
            else:
                bitpos += 5

            x_pos = get_bits(bitpos, xbits)
            bitpos += xbits

        bitpos += 1 # hidden bit, we don't need this
        block_type = get_bits(bitpos, 5)
        bitpos += 5
        #print(block_type)

    return math.ceil(bitpos/8) - x


def length_mapeni(x):
    # see: https://segaretro.org/Enigma_compression
    inline_copy_value = btoi(x, 1)
    render_flags_bits = 0
    # only count how many bits of the second byte are set.
    for i in range(5):
        if get_bit(8*x+8+3+i):
            render_flags_bits += 1

    bitpos = 8*(x+6)
    while True:
        b = get_bit(bitpos)
        if b == 0:
            # two type bits and 4 repeat bits
            bitpos += 2 + 4
        else:
            # reading the first bit again to get the full type
            type_bits = get_bits(bitpos, 3)
            bitpos += 3
            repeat_bits = get_bits(bitpos, 4)
            bitpos += 4
            if type_bits == 7:
                if repeat_bits == 0x0F:
                    break # type is 11 and repeat bits 1111 -> DONE!
                else:
                    bitpos += (repeat_bits + 1) * (render_flags_bits + inline_copy_value)
            else:
                bitpos += render_flags_bits + inline_copy_value

    return math.ceil(bitpos/8) - x


def length_platform(x):
    pos = x
    x_pos = btoi(pos, 2)
    while x_pos != 0xFFFF:
        pos += 12
        x_pos = btoi(pos, 2)
    return pos+2 - x


def length_bgscroll(x):
    pos = x
    layer = btoi(pos, 1)
    # The data at 0xA0903 is not terminated with $FF and thus
    # we have to hardcode its end as the next entry is at 0xA0934
    while layer != 0xFF and pos != 0xA0933:
        pos += 1
        layer = btoi(pos, 1)
    return pos+1 - x


def length_bglayout(x):
    pos = x
    tile_id = btoi(pos, 2)
    while tile_id != 0xFFFF:
        pos += 6
        tile_id = btoi(pos, 2)
    return pos+2 - x


# write platform data starting at given address addr
# to file specified by fname
def write_platform_asm(addr, fname):
    with open(fname, "w") as out:
        x = btoi(addr, 2)
        while x != 0xFFFF:
            x = btoi(addr, 2)
            y = btoi(addr+2, 2)
            BL = btoi(addr+4, 1)
            BR = btoi(addr+5, 1)
            BT = btoi(addr+6, 1)
            BB = btoi(addr+7, 1)
            TS = btoi(addr+8, 1)
            HV = btoi(addr+9, 1)
            PPP = btoi(addr+10, 2)

            H = HV >> 4
            V = HV & 0x0F
            t = TS >> 7
            s = (TS & 6) >> 1
            if TS & 0x79:
                print("bad platform!")
            if t == 0:
                if PPP+0x3602 == 0x10000 or PPP==0xFFFF:
                    out.write("\tptfm\t{},{},{},{},{},{},{},{},{},{},${:X}\n".format(x, y, BL, BR, BT, BB, t, s, H, V, PPP))
                else:
                    out.write("\tptfm\t{},{},{},{},{},{},{},{},{},{},unk_{:X}-unk_3602\n".format(x, y, BL, BR, BT, BB, t, s, H, V, PPP+0x3602))
            else:
                out.write("\tptfm\t{},{},{},{},{},{},{},{},{},{},{}\n".format(x, y, BL, BR, BT, BB, t, s, H, V, PPP))    
            addr += 12
            x = btoi(addr, 2)
        out.write("\tdc.w\t$FFFF\n")


os.makedirs("level/block", exist_ok=True)
os.makedirs("level/enemy", exist_ok=True)
os.makedirs("level/platform", exist_ok=True)
os.makedirs("level/foreground", exist_ok=True)
os.makedirs("level/background", exist_ok=True)
os.makedirs("level/bgscroll", exist_ok=True)
os.makedirs("level/header", exist_ok=True)
os.makedirs("theme/mappings", exist_ok=True)
os.makedirs("theme/collision", exist_ok=True)
os.makedirs("theme/artcomp_fg", exist_ok=True)
os.makedirs("theme/artcomp_bg", exist_ok=True)
os.makedirs("theme/palette_fg", exist_ok=True)
os.makedirs("theme/palette_bg", exist_ok=True)
os.makedirs("theme/bg_chunks", exist_ok=True)
os.makedirs("theme/titlecard/artcomp", exist_ok=True)
os.makedirs("theme/titlecard/palette", exist_ok=True)
os.makedirs("theme/titlecard/mapeni", exist_ok=True)
os.makedirs("scenes/artcomp", exist_ok=True)
os.makedirs("scenes/artunc", exist_ok=True)
os.makedirs("scenes/palette", exist_ok=True)
os.makedirs("scenes/mapeni", exist_ok=True)
os.makedirs("ingame/artcomp", exist_ok=True)
os.makedirs("ingame/artunc", exist_ok=True)
os.makedirs("ingame/artunc_kid", exist_ok=True)
os.makedirs("ingame/palette", exist_ok=True)
os.makedirs("ingame/palette_kid", exist_ok=True)
os.makedirs("ingame/palette_enemy", exist_ok=True)
os.makedirs("sound", exist_ok=True)


mapheader_addrs = dict()
platform_addrs = dict()
enemy_addrs = dict()
foreground_addrs = dict()
background_addrs = dict()
backgroundlayered_addrs = dict()
block_addrs = dict()
bgscroll_addrs = dict()

linfo = open("level/level_files.txt", "w")
# dump platform, bgscroll, header, enemy, foreground and block
# layout for each level to files.
for lev in range(Number_Levels):
    linfo.write("\n")
    addr = btoi(MapHeader_Index+2*lev, 2) + MapHeader_Offset
    platform = btoi(Platform_Index+2*lev, 2) + Platform_Offset
    bgscroll = btoi(Bgscroll_Index+4*lev, 4)
    # need this because of load of duplicates
    if platform not in platform_addrs:
        l = length_platform(platform)
        platform_addrs[platform] = lev
        with open("level/platform/{:02X}.bin".format(lev), "wb") as out:
            out.write(b[platform:platform+l])
        write_platform_asm(platform, "level/platform/{:02X}.asm".format(lev))

    if bgscroll not in bgscroll_addrs:
        l = length_bgscroll(bgscroll)
        bgscroll_addrs[bgscroll] = lev
        with open("level/bgscroll/{:02X}.bin".format(lev), "wb") as out:
            out.write(b[bgscroll:bgscroll+l])

    linfo.write("{:02X}\t".format(lev))
    linfo.write("platform/{:02X}.bin ".format(platform_addrs[platform]))
    linfo.write("bgscroll/{:02X}.bin ".format(bgscroll_addrs[bgscroll]))

    if addr == 0x40FF6:
        # for some entries, the pointer points to invalid data
        # specifically, to the address after the last valid map header
        continue


    # don't process duplicate entries. They give us false overlap alarms.
    if addr in mapheader_addrs:
        linfo.write("header/{:02X}.bin ".format(mapheader_addrs[addr]))
        continue

    mapheader_addrs[addr] = lev
    linfo.write("header/{:02X}.bin ".format(mapheader_addrs[addr]))

    '''
    map header format:
        dc.b    xsize, ysize, fgstyle, bgstyle
        dc.w    playerx, playery, flagx, flagy
        dc.l    foreground, block, background, enemy
    '''
    with open("level/header/{:02X}.bin".format(lev), "wb") as out:
        out.write(b[addr:addr+12])

    bgtheme = btoi(addr+3, 1) & 0x0F
    foreground = btoi(addr+12, 4)
    block = btoi(addr+16, 4)
    background = btoi(addr+20, 4)
    enemy = btoi(addr+24, 4)

    if enemy not in enemy_addrs:
        enemy_addrs[enemy] = lev
        l = length_enemy(enemy)
        with open("level/enemy/{:02X}.bin".format(lev), "wb") as out:
            out.write(b[enemy+4:enemy+l])

    if foreground not in foreground_addrs:
        foreground_addrs[foreground] = lev
        l = length_tile(foreground)
        with open("level/foreground/{:02X}.bin".format(lev), "wb") as out:
            out.write(b[foreground:foreground+l])

    if block not in block_addrs:
        block_addrs[block] = lev
        l = length_block(block)
        with open("level/block/{:02X}.bin".format(lev), "wb") as out:
            out.write(b[block:block+l])
    linfo.write("enemy/{:02X}.bin ".format(enemy_addrs[enemy]))
    linfo.write("foreground/{:02X}.bin ".format(foreground_addrs[foreground]))
    linfo.write("block/{:02X}.bin ".format(block_addrs[block]))

    if bgtheme in [3,5,7,9]: # layered
        if background not in backgroundlayered_addrs:
            backgroundlayered_addrs[background] = lev
        linfo.write("background/{:02X}_layered.bin ".format(backgroundlayered_addrs[background]))
    else:
        if background not in background_addrs:
            btype = btoi(background, 1)
            if btype == 0x80:
                w1 = btoi(background, 2)
                l2 = btoi(background+2, 4)
                ref_addr = btoi(background+6, 4)
                background_addrs[background] = (w1, l2, ref_addr)
                if ref_addr in background_addrs:
                    ref = background_addrs[ref_addr][0]
                    linfo.write("background/{:02X}.bin ".format(ref))
                else: # this is a bit dirty, need to find the level whose background is shared somehow
                    for l in range(Number_Levels):
                        a = btoi(MapHeader_Index+2*lev, 2) + MapHeader_Offset
                        bg = btoi(a+20, 4)
                        if bg == ref_addr:
                            linfo.write("background/{:02X}.bin ".format(l))
                            break;
            else:
                l = length_bglayout(background)
                background_addrs[background] = (lev,)
                with open("level/background/{:02X}.bin".format(lev), "wb") as out:
                    out.write(b[background:background+l])
                linfo.write("background/{:02X}.bin ".format(lev))

linfo.close()

# for layered background we can't determine the size, so we just split
# until the next address.
# Note: we assume that layered and non-layered are not interleaved, i.e.
# all layered backgrounds are consecutive in the ROM
max_bglay_addr = max(backgroundlayered_addrs.keys())
backgroundlayered_addrs = sorted(backgroundlayered_addrs.items())
all_addrs = block_addrs.keys() | enemy_addrs.keys() | foreground_addrs.keys() | background_addrs.keys()
min_next_addr = min(addr for addr in all_addrs if addr > max_bglay_addr)
backgroundlayered_addrs.append((min_next_addr, None))
for i in range(len(backgroundlayered_addrs)-1):
    addr = backgroundlayered_addrs[i][0]
    lev = backgroundlayered_addrs[i][1]
    next_addr = backgroundlayered_addrs[i+1][0]
    with open("level/background/{:02X}_layered.bin".format(lev), "wb") as out:
        out.write(b[addr:next_addr])

# create an .asm file with the speed and path bonuses
PathBonus = 0xD8E8
SpeedBonus = 0xD934
fpath = open("level/pathbonus.asm", "w")
fspeed = open("level/speedbonus.asm", "w")
for lev in range(76):
    fpath.write("\tdc.b\t{:2d}\t; {:2X}\n".format(btoi(PathBonus+lev, 1), lev))
    fspeed.write("\tdc.b\t{:3d}\t; {:2X}\n".format(btoi(SpeedBonus+lev, 1), lev))
fpath.close()
fspeed.close()

# create an asm file with the mapping of LevelIDs to MapIDs
LnkTo_MapOrder_Index = 0x4033E
MapOrder_Index = btoi(LnkTo_MapOrder_Index, 4)
forder = open("level/maporder.asm", "w")
for lev in range(108):
    forder.write("\tdc.b\t${:02X}\t; {:2X}\n".format(btoi(MapOrder_Index+lev, 1), lev))
forder.close()

# make an asm file with all the level names, and level name index
AddrTbl_LevelNames = 0x1A842
name_addrs = set()
name_addrs2 = set()
name_addrs2.add(0x1A842)
fnames = open("level/levelnames.asm", "w")
for lev in range(74):
    addr = btoi(AddrTbl_LevelNames+10*lev, 4)
    addr2 = btoi(AddrTbl_LevelNames+10*lev+4, 4)
    name_addrs.add(addr)
    name_addrs2.add(addr2)
fnames.write(
'''; \\0   = linebreak
; \\x7C = "The"
; \\x7D = "the"
; \\x7E = "of"
; \\x7F = "to"
; \\x83 = "'"
; \\x84 = " "
''')
for addr in sorted(name_addrs):
    fnames.write("unk_{:X}:\n".format(addr))
    addr_end = addr
    while btoi(addr_end, 1) != 0xFF:
        addr_end += 1
    name = str("{}".format(b[addr:addr_end]))
    name = name[2:-1]
    name = str("\tdc.b\t\"{}\"\n".format(name))
    name = name.replace("\\x00", "\\0")
    name = name.replace("\\x7f", "\\x7F")
    name = name.replace("~", "\\x7E")
    name = name.replace("}", "\\x7D")
    name = name.replace("|", "\\x7C")
    fnames.write(name)
    fnames.write("\tdc.b\t$FF\n")
fnames.write("\n\talign\t2\n\n")
name_addrs2 = sorted(name_addrs2)
for i in range(len(name_addrs2)-1):
    addr = name_addrs2[i]
    fnames.write("unk_{:X}:\n".format(addr))
    while addr < name_addrs2[i+1]:
        fnames.write("\tdc.w\t${:02X}\n".format(btoi(addr, 2)))
        addr += 2
fnames.write("\nAddrTbl_LevelNames:   ;1A842\n")
for lev in range(74):
    addr = btoi(AddrTbl_LevelNames+10*lev, 4)
    addr2 = btoi(AddrTbl_LevelNames+10*lev+4, 4)
    number = btoi(AddrTbl_LevelNames+10*lev+8, 2)
    fnames.write("\tlevnamhdr\tunk_{:X}, unk_{:X}, {:d}\t; {:2X}\n".format(addr, addr2, number, lev))


# split off a lot of binary files with fixed start and end addresses
to_split = open("tools/to_split.txt")
for line in to_split:
    if line[0] == "#":
        # hash symbol to remark a comment line
        continue
    entries = line.split()
    start = int(entries[0], 16)
    end = int(entries[1], 16)
    fname = entries[2]
    with open(fname, "wb") as out:
        out.write(b[start:end])

print("DONE: All files split off!")