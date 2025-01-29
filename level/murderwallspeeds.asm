mwall	macro	speed, accel, screendist, revflag, revspeed
		dc.l	speed, accel
		dc.w	screendist, revflag
		dc.l	revspeed
		endm
; We have 5 entries per row:
; maximum speed
; acceleration
; how far the wall can fall behind screen edge (in pixels). Minimum: $31
; whether to reverse direction at level edge? (0=False, 1=True);
; initial speed after reversing direction 
	mwall	$2C000, $400,  $31, 0,     0	;  0 Blue Lake Woods 1
	mwall	$20000, $100,  $80, 1,     0	;  1 Blue Lake Woods 2
	mwall	$18000, $100,  $80, 1, $8000	;  2 Highwater Pass 1
	mwall	$20000, $100,  $80, 1,     0	;  3 Highwater Pass 2
	mwall	$20000, $100,  $80, 1,     0	;  4 Under Skull Mountain 1
	mwall	$20000, $100,  $80, 1,     0	;  5 Under Skull Mountain 2
	mwall	$20000, $100,  $80, 1,     0	;  6 Under Skull Mountain 3
	mwall	$20000, $100,  $80, 1,     0	;  7 Isle of the Lion Lord
	mwall	$18000, $100, $100, 1, $C000	;  8 Hills of the Warrior 1
	mwall	$20000, $100,  $80, 1,     0	;  9 Hills of the Warrior 2
	mwall	$20000, $100,  $80, 1,     0	;  A Windy City
	mwall	$20000, $100,  $80, 1,     0	;  B Sinister Sewers
	mwall	$20000,  $C0,  $80, 1,     0	;  C The Crystal Crags 1
	mwall	$20000, $100,  $80, 1,     0	;  D The Crystal Crags 2
	mwall	$20000, $100,  $80, 1,     0	;  E Dragonspike
	mwall	$20000, $100,  $80, 1,     0	;  F Stormwalk Mountain
	mwall	$20000, $100,  $80, 1,     0	; 10 Shishkaboss
	mwall	$20000, $100,  $80, 1,     0	; 11 The Whispering Woods 1
	mwall	$20000, $100,  $80, 1,     0	; 12 The Whispering Woods 2
	mwall	$20000, $100,  $80, 1,     0	; 13 Devil's Marsh 1
	mwall	$20000, $100,  $80, 1,     0	; 14 Devil's Marsh 2
	mwall	$20000, $100,  $80, 1,     0	; 15 Knight's Isle
	mwall	$20000, $100,  $80, 1,     0	; 16 Whale Grotto
	mwall	$20000, $100,  $80, 1,     0	; 17 Hoverboard Beach
	mwall	$20000, $100,  $80, 1,     0	; 18 Pyramids of Peril
	mwall	$20000, $100,  $80, 1,     0	; 19 Madmaze Mountain
	mwall	$20000, $100,  $80, 1,     0	; 1A The Deadly Skyscrapers
	mwall	$20000, $100,  $80, 1,     0	; 1B Skydragon Castle 1
	mwall	$20000, $100,  $80, 1,     0	; 1C Skydragon Castle 2
	mwall	$20000, $100,  $80, 1,     0	; 1D Coral Blade Grotto
	mwall	$20000, $100,  $80, 1,     0	; 1E Boomerang Bosses
	mwall	$20000, $100,  $80, 1,     0	; 1F Woods of Despair 1
	mwall	$20000, $100,  $80, 1,     0	; 20 Woods of Despair 2
	mwall	$20000, $100,  $80, 1,     0	; 21 Forced Entry
	mwall	$20000, $100,  $80, 1,     0	; 22 The Cliffs of Illusion
	mwall	$20000, $100,  $80, 1,     0	; 23 Lion's Den
	mwall	$20000, $100,  $80, 1,     0	; 24 Wind Castles 1
	mwall	$20000, $100,  $80, 1,     0	; 25 Wind Castles 2
	mwall	$20000, $100,  $80, 1,     0	; 26 Blizzard Mountain
	mwall	$20000, $100,  $80, 1,     0	; 27 Caves of Ice
	mwall	$20000, $100,  $80, 1,     0	; 28 The Nightmare Peaks 1
	mwall	$20000, $100,  $80, 1,     0	; 29 The Nightmare Peaks 2
	mwall	$20000, $100,  $80, 1,     0	; 2A Bagel Brothers
	mwall	$20000, $100,  $80, 1,     0	; 2B Diamond Edge
	mwall	$20000, $100,  $80, 1,     0	; 2C The Hills Have Eyes
	mwall	$20000, $100,  $80, 1,     0	; 2D Secrets in the Rocks
	mwall	$20000, $100,  $80, 1,     0	; 2E Ice God's Vengeance
	mwall	$20000, $100,  $80, 1,     0	; 2F Beneath the Twisted Hills
	mwall	$20000, $100,  $80, 1,     0	; 30 Alien Isle
	mwall	$20000, $100,  $80, 1,     0	; 31 The Land Below
	mwall	$20000, $100,  $80, 1,     0	; 32 The Final Marathon
	mwall	$20000, $100,  $80, 1,     0	; 33 Plethora
	mwall	$20000, $100,  $80, 1,     0	; 34 The Pinnacle
	mwall	$20000, $100,  $80, 1,     0	; 35 Hidden Canyon
	mwall	$20000, $100,  $80, 1,     0	; 36 The Caged Beasts
	mwall	$20000, $100,  $80, 1,     0	; 37 Crab Cove
	mwall	$20000, $100,  $80, 1,     0	; 38 The Crypt (leftover)
	mwall	$20000, $100,  $80, 1,     0	; 39 The Forbidden Tombs
	mwall	$20000, $100,  $80, 1,     0	; 3A Stairway to Oblivion
	mwall	$20000, $100,  $80, 1,     0	; 3B The Valley of Life
	mwall	$20000, $100,  $80, 1,     0	; 3C The Black Pit
	mwall	$20000, $100,  $80, 1,     0	; 3D Frosty Doom
	mwall	$20000, $100,  $80, 1,     0	; 3E Bloody Swamp
	mwall	$20000, $100,  $80, 1,     0	; 3F Scorpion Isle
	mwall	$20000, $100,  $80, 1,     0	; 40 Towers of Blood
	mwall	$20000, $100,  $80, 1,     0	; 41 The Crypt (playable version)
	mwall	$20000, $100,  $80, 1,     0	; 42 Alien Twilight
	mwall	$20000, $100,  $80, 1,     0	; 43 Tunnels Beneath the Woods
	mwall	$20000, $100,  $80, 1,     0	; 44 Hills of Forever
	mwall	$20000, $100,  $80, 1,     0	; 45 Monster Island
	mwall	$20000, $100,  $80, 1,     0	; 46 The Shimmering Caves
	mwall	$20000, $100,  $80, 1,     0	; 47 The Crypt (leftover)
	mwall	$20000, $100,  $80, 1,     0	; 48 Sky Fortress
	mwall	$20000, $100,  $80, 1,     0	; 49 Elsewhere 1
	mwall	$20000, $100,  $80, 1,     0	; 4A Elsewhere 2
	mwall	$20000, $100,  $80, 1,     0	; 4B Elsewhere 3
	mwall	$20000, $100,  $80, 1,     0	; 4C Elsewhere 4
	mwall	$20000, $100,  $80, 1,     0	; 4D Elsewhere 5
	mwall	$20000, $100,  $80, 1,     0	; 4E Elsewhere 6
	mwall	$20000, $100,  $80, 1,     0	; 4F Elsewhere 7
	mwall	$20000, $100,  $80, 1,     0	; 50 Elsewhere 8
	mwall	$20000, $100,  $80, 1,     0	; 51 Elsewhere 10
	mwall	$20000, $100,  $80, 1,     0	; 52 Elsewhere 9
	mwall	$20000, $100,  $80, 1,     0	; 53 Elsewhere 11
	mwall	$20000, $100,  $80, 1,     0	; 54 Elsewhere 12
	mwall	$20000, $100,  $80, 1,     0	; 55 Elsewhere 13
	mwall	$20000, $100,  $80, 1,     0	; 56 Elsewhere 14
	mwall	$20000, $100,  $80, 1,     0	; 57 Elsewhere 32
	mwall	$20000, $100,  $80, 1,     0	; 58 Elsewhere 16
	mwall	$20000, $100,  $80, 1,     0	; 59 Elsewhere 15
	mwall	$20000, $100,  $80, 1,     0	; 5A Elsewhere 17
	mwall	 $7000,  $80,  $80, 1,     0	; 5B Elsewhere 19
	mwall	$20000, $100,  $80, 1,     0	; 5C Elsewhere 18
	mwall	$20000, $100,  $80, 1,     0	; 5D Elsewhere 22
	mwall	$20000, $100,  $80, 1,     0	; 5E Elsewhere 20
	mwall	$20000, $100,  $80, 1,     0	; 5F Elsewhere 21
	mwall	$20000, $100,  $80, 1,     0	; 60 Elsewhere 23
	mwall	$20000, $100,  $80, 1,     0	; 61 Elsewhere 24
	mwall	$20000, $100,  $80, 1,     0	; 62 Elsewhere 25
	mwall	$20000, $100,  $80, 1,     0	; 63 Elsewhere 26
	mwall	$20000, $100,  $80, 1,     0	; 64 Elsewhere 27
	mwall	$20000, $100,  $80, 1,     0	; 65 Elsewhere 28
	mwall	$20000, $100,  $80, 1,     0	; 66 Elsewhere 29
	mwall	$20000, $100,  $80, 1,     0	; 67 Elsewhere 30
	mwall	$20000, $100,  $80, 1,     0	; 68 Elsewhere 31
	mwall	$20000, $100,  $80, 1,     0	; 69 The Crypt (leftover)
	mwall	$20000, $100,  $80, 1,     0	; 6A The Crypt (leftover)
	mwall	$20000, $100,  $80, 1,     0	; 6B The Crypt (leftover)
