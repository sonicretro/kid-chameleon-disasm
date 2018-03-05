Sprite_Table = 		$FFFF0000 	; $280 bytes, 8 bytes per sprite ($50 sprites)
Object_RAM = 		$FFFF0DA0 	; $16A8 bytes, $74 bytes per object ($32 slots)
GfxObject_RAM = 	$FFFF2448	; $16DC bytes, $4C bytes per object ($4D objects)
Palette_Buffer = 	$FFFF4E58	; $80 bytes
Block_Mappings = 	$FFFF503A	; $288 bytes
Level_terrain_layout = 	$FFFF52C2	; $20D0 bytes. 1 byte per entry (30 screens of $118 entries each)
Horiz_Scroll_Data = 	$FFFF7392	; $A0 bytes. deformation related data
Horiz_Scroll_Buffer = 	$FFFF7432 	; $380 bytes. 
Decompression_Buffer =	$FFFF77B2	; $1000 bytes
Level_Layout = 		$FFFFA652	; $41A0 bytes. 2 bytes per entry: block,skin (30 screens of $118 entries each)
EnemyStatus_Table = 	$FFFFF8FE	; ? bytes. 2 bytes per entry

Diamond_power_timer = 	$FFFFF5BE	; word
V_Int_counter = 	$FFFFF806	; word: number of frames since start of game
V_Int_Done = 		$FFFFF80A	; byte: Indicator that V-Int has occurred
Ctrl_1 = 		$FFFFF80C	; byte. Bitmask for controller buttons: SACBRLDU
Ctrl_1_Held = 		$FFFFF80D	; byte: buttons currently held down
Ctrl_1_Pressed = 	$FFFFF80E	; byte: buttons newly pressed this frame
Ctrl_2 = 		$FFFFF80F	; byte
Ctrl_2_Held = 		$FFFFF810	; byte
Ctrl_2_Pressed = 	$FFFFF811	; byte
Ctrl_Held = 		$FFFFF812	; byte. depending on input mode (i.e. currently active player?)
Ctrl_Pressed = 		$FFFFF813	; byte. depending on input mode (i.e. currently active player?)
Ctrl_A_Held = 		$FFFFF814	; byte: flag
Ctrl_C_Held = 		$FFFFF815	; byte: flag
Ctrl_B_Held = 		$FFFFF816	; byte: flag
Ctrl_Right_Held = 	$FFFFF817	; byte: flag
Ctrl_Left_Held = 	$FFFFF818	; byte: flag
Ctrl_Down_Held = 	$FFFFF819	; byte: flag
Ctrl_Up_Held = 		$FFFFF81A	; byte: flag
Camera_X_pos = 		$FFFFF81C	; long (16.16 fixed point)
Camera_Y_pos = 		$FFFFF820	; long (16.16 fixed point)
Camera_BG_X_pos = 	$FFFFF824	; long (16.16 fixed point)
Camera_BG_Y_pos = 	$FFFFF828	; long (16.16 fixed point)
Addr_NextSpriteSlot =	$FFFFF832	; long
Number_Sprites =	$FFFFF836	; byte
Addr_NextFreeObjectSlot = $FFFFF83E	; long
Addr_FirstObjectSlot =	$FFFFF842	; long
Addr_CurrentObject =	$FFFFF846	; long
Number_Objects =	$FFFFF84A	; word
Addr_NextFreeGfxObjectSlot = $FFFFF854	; long
Addr_FirstGfxObjectSlot = $FFFFF858	; long
Number_GfxObjects =	$FFFFF85C	; word
PaletteToDMA_Flag = 	$FFFFF890	; byte
Level_width_blocks = 	$FFFFF89E	; word
Level_width_tiles = 	$FFFFF89C	; word
Level_width_pixels = 	$FFFFF89A	; word
Level_height_blocks = 	$FFFFF8A0	; word
Level_height_tiles = 	$FFFFF8A2	; word
Level_height_pixels = 	$FFFFF8A4	; word
Background_width = 	$FFFFF8A6	; word
Background_height = 	$FFFFF8A8	; word
Foreground_theme = 	$FFFFF8AA	; word: also determines music
Background_theme = 	$FFFFF8AC	; word
Addr_ThemeMappings = 	$FFFFF8AE	; long:	Address of theme mappings
Camera_max_X_pos = 	$FFFFF8BA	; word: level width in pixels - $140
Camera_max_Y_pos = 	$FFFFF8BC	; word: level height in pixels - $E0
Currently_Transforming = $FFFFFA6D	; byte
Telepad_timer = 	$FFFFFA70	; word
MurderWall_flag = 	$FFFFFAC1	; byte:   -1 = Murder wall, 0 = None
MurderWall_flag2 = 	$FFFFFAC2	; byte: set if both bits of the 3rd entry of maphdr are set
MurderWall_speed = 	$FFFFFAC8	; long
MurderWall_max_speed = 	$FFFFFACC	; long
Pause_Option = 		$FFFFFAD1	; byte: selected option in Pause menu: 0=continue, 1=restart/give up
Level_Special_Effects = $FFFFFB40	; word: 0 = None, 1 = Lava Geyser, 2 = Storm, 3 = Storm+Hail, >=4 = Invalid    
Background_format = 	$FFFFFB48	; byte (flag): 0 = pieces, -1 = enigma. (only depends on bg theme)
Addr_Current_Demo_Keypress = $FFFFFBC4	; word: Pointer to current Keypress in Demo
Demo_Mode_flag = 	$FFFFFBC9	; byte (for input)
Game_Mode = 		$FFFFFBCA	; word
	;00 - SegaScreen
	;04 - IntroSequence1
	;08 - TitleCard
	;0C - InGame        ; also Results screen
	;10 - DemoPlay
	;14 - OptionMenu
	;18 - IntroSequence2
	;1C - IntroSequence3
	;20 - IntroSequence4
	;24 - IntroSequence5
	;28 - IntroSequence6 ; is also TitleScreen if intro played completely
	;2C - TitleScreen
	;30 - EndSequence
Addr_MapHeader = 	$FFFFFBD4	; long
Number_Lives_prev = 	$FFFFFC18	; word
Number_Diamonds_prev = 	$FFFFFC1A	; word
Time_SubSeconds = 	$FFFFFC1C	; word: Frames until next second countdown
Time_Seconds_low_digit = $FFFFFC1E	; word
Time_Seconds_high_digit = $FFFFFC20	; word
Time_Minutes = 		$FFFFFC22	; word
PlayerStart_X_pos = 	$FFFFFC2A	; word
PlayerStart_Y_pos = 	$FFFFFC2C	; word
Flag_X_pos = 		$FFFFFC2E	; word
Flag_Y_pos = 		$FFFFFC30	; word
Two_player_flag = 	$FFFFFC38	; word
NoHit_Bonus_Flag = 	$FFFFFC3B	; byte: 0 = retained, -1 = lost
NoPrize_Bonus_Flag = 	$FFFFFC3C	; byte: 0 = retained, -1 = lost
Level_completion_time = $FFFFFC3D	; byte: in seconds
Number_Lives = 		$FFFFFC3E	; word
Number_Hitpoints = 	$FFFFFC40	; word
Number_Diamonds = 	$FFFFFC42	; word
Current_LevelID = 	$FFFFFC44	; word
Current_Helmet = 	$FFFFFC46	; The ID of the worn helmet
	;00 - None
	;01 - Skycutter
	;02 - Cyclone
	;03 - Red Stealth
	;04 - Eyeclops
	;05 - Juggernaut
	;06 - Iron Knight
	;07 - Berzerker
	;08 - Maniaxe
	;09 - Micromax
Number_Continues = 	$FFFFFC48	; word
Extra_hitpoint_slots = 	$FFFFFC4A	; word
Score = 		$FFFFFC4C	; long
Player_1_Lives = 	$FFFFFC54	; word
Player_1_Hitpoints = 	$FFFFFC56	; word
Player_1_Diamonds = 	$FFFFFC58	; word
Player_1_LevelID = 	$FFFFFC5A	; word
Player_1_Helmet = 	$FFFFFC5C	; word
Player_1_Continues = 	$FFFFFC5E	; word
Player_1_Extra_hitpoint_slots = $FFFFFC60	; word
Player_1_Score = 	$FFFFFC62	; long
Player_2_Lives = 	$FFFFFC6A	; word
Player_2_Hitpoints = 	$FFFFFC6C	; word
Player_2_Diamonds = 	$FFFFFC6E	; word
Player_2_LevelID = 	$FFFFFC70	; word
Player_2_Helmet = 	$FFFFFC72	; word
Player_2_Continues = 	$FFFFFC74	; word
Player_2_Extra_hitpoint_slots = $FFFFFC76	; word
Player_2_Score = 	$FFFFFC78	; long
LevelSelect_ActNumber = $FFFFFDC6	; byte: number in e.g. "Elsewhere 15" or "BLW 1/2", also costume counter
LevelSelect_Flag = 	$FFFFFDC7	; byte: indicator whether to load level select as options menu
Options_Suboption_2PController = $FFFFFDC8	; byte: selected sub-option 1 in options menu (flag). 2 Players: One controller = 0, Two = -1
Options_Suboption_Speed = $FFFFFDC9	; byte: selected sub-option 3 in options menu (flag). Speed: Normal = 0, Fast = -1    
Options_Suboption_Controls = $FFFFFDCA	; word: selected sub-option 2 in options menu: Controls (0-5) 
Options_Selected_Option = $FFFFFDCC	; word: currently selected option in options menu, also in level select
Clocks_collected = 	$FFFFFDCE	; word



