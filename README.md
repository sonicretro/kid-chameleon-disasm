Kid Chameleon Disassembly
============

DISCLAIMER:
Any and all content presented in this repository is presented for informational and educational purposes only.
Commercial usage is expressly prohibited. Sonic Retro claims no ownership of any code in these repositories.
You assume any and all responsibility for using this content responsibly. Sonic Retro claims no responsibiliy or warranty.


**Build Instructions**

1. Place a ROM of Kid Chameleon in the main folder, called kid.bin.
2. Run the python3 script ``split.py`` to split off game data into separate files.
    - Remark: needs Python >= 3.2. Remove the ``exist_ok`` parameters in the code for older versions of python.
3. Run ``build.bat`` (Windows) or ``build.sh`` (Linux) to build the ROM.


**Credits**

Saxman727 for the K-E level editor and first hacking notes (``docs/Kid Chameleon hacking.txt``).
Community from the Kid Chameleon Wikia (``http://kidchameleon.wikia.com/wiki/Main_Page``)  for compiling plenty of information about Kid Chameleon.
Sonic Retro community, in particular for the Sonic 2 disassembly and plenty of hacking resources for the Sega Genesis.


**Details**

The split.py script takes most of the data from the ROM and splits it
into separate binary files. Thus the code file kid.asm contains almost
exclusively assembly code, with data included via ``include`` or
``binclude`` directives. This disassembly is made for the AS assembler
which is included in the ``build/`` folder, and building should work on
both Linux and Windows. 

The beginning of kid.asm defines some options that can be turned on
and off. ``zeroOffsetOptimization`` is set to 0 for the sole purpose of
building a bit-perfect ROM, and not required otherwise.
``platforms_asm``, when set to 1, includes platform data for each level 
as .asm file rather than .bin. This is necessary if you want to change
length of any platform presets (``level/platform_presets.asm``).
``insertLevelSelect``, when enabled, inserts a level select into the ROM.

Following these options are constants for various level IDs, as well as
for the default options, provided for convenience to make modifications 
to these easier.

The ``doc/`` folder contains various useful information, including
Saxman's original hacking notes, some information on the layout of
the ROM and M68k RAM in the game, and data formats.


**Data**

Most data from the game has been split into separate files. 
Theme data, such as foreground/background art and mappings,
collision, palettes, and titlecard data (art, mappings, palettes) are in
the ``theme/`` folder. Level specific data, such as foreground and background
layout, block layout, enemy layout as well as background scrolling data,
platform definitions and level headers are in the ``level/`` folder.
This folder also includes .asm files containing the level order, speed
bonuses, path bonuses, level names, as well as platform presets (data
defining along which paths certain platforms move).
Assets from intro, menu, and intermission scenes/screens are in the
``scenes/`` folder, specifically compressed and uncompressed art, palettes
and plane mappings.

Any modifications to these files will be incorporated into the built
ROM. *Warning:* When re-running split.py, all modifications to these
files will be overwritten with the original content from kid.bin.

The folder ``planeed_prj/`` contains PlaneEd projects for various plane mappings
used in the game, such as title cards, some backgrounds, and menu etc
screens. See ``planeed_prj/readme.txt`` for more details.

Kid Chameleon uses the GEMS sound driver. All sound assets and the sound
driver itself are contained in the ``sound/`` subfolder.


**ROMs modified with K-E or K-C**

ROMs that have been modified with the level editors K-E or K-C can also
be split to be used with this disassembly. These editors create extra space
at the end of the ROM, and move the offset table for level headers and
all level data there. Thus, in order to split the data, in the split.py
script, ``MapHeader_Index`` has to be changed to ``0x100008`` and 
``MapHeader_Offset`` to ``0x100000`` before running the script. Furthermore, 
a few pieces of assembly code have to be replaced. 
For this, place the modified kid.bin in the folder ``tools/`` and run 
``includes_hack.py`` which will create a ``hack/`` subfolder. This
subfolder will contain a few files with assembly codes and instructions where
to put these code pieces.
