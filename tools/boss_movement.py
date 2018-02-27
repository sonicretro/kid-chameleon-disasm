# This is the list of addresses where the boss movement data is stored
# in the original ROM. This script prints it out nicely formatted so it
# can be included in the disassembly.
addr_boss = [0x39C2E, 0x39AB2, 0x39A1A, 0x39988, 0x398F0, 0x39872, 0x39D80]

f = open("kid.bin", "rb")
b = f.read()

# read /length/ bytes starting at /addr/ as integer 
btoi = lambda addr,length: int.from_bytes(b[addr:addr+length], byteorder='big')

for addr in addr_boss:
    print("unk_{:X}:".format(addr))
    dur = btoi(addr, 2)
    while dur != 0xFFFF:
        xvel = btoi(addr+2, 2)
        if xvel >= 0x8000:
            xvel = xvel - 0x10000
        yvel = btoi(addr+4, 2)
        if yvel >= 0x8000:
            yvel = yvel - 0x10000
        line = "\tdc.w\t${:X}, {:d}, {:d}".format(dur, xvel, yvel)
        line = line.replace("$-", "-$")
        print(line)
        addr += 6
        dur = btoi(addr, 2)
    print("\tdc.w\t$FFFF")
    print()