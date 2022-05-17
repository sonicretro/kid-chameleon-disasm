;stru_3AF62: 
	include "ingame/anim/enemy/Crab.asm"

;loc_3AF96:
Enemy09_Crab_Init: 
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a4
	move.w	2(a4),enemy_level(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3AFD0
	st	x_direction(a3)

loc_3AFD0:
	st	$13(a3)
	st	is_animated(a3)
	move.w	#9,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	enemy_level(a3),d7
	addq.w	#2,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	blt.s	loc_3B00A
	move.l	#$10000,$50(a5)
	move.l	#$10000,$5E(a5)

loc_3B00A:
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)
	move.w	#$1E,$4A(a5)
	move.w	#$C,$48(a5)
	move.l	#stru_3AF62,d7
	jsr	(j_Init_Animation).w
	addi.w	#1,(Number_of_Enemy).w
	move.l	#loc_3B048,a0
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3B048:
	move.w	collision_type(a3),d4
	beq.s	loc_3B0BE
	bmi.s	loc_3B094
	cmpi.w	#colid_kidright,d4
	beq.w	loc_3B180
	cmpi.w	#colid_kidleft,d4
	beq.w	loc_3B180
	cmpi.w	#colid_hurt,d4
	bne.s	loc_3B0BE
	cmpi.w	#(LnkTo_unk_C7C4E-Data_Index),addroffset_sprite(a3)
	beq.s	loc_3B0BE
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	tst.w	d7
	bmi.s	loc_3B086
	tst.b	x_direction(a3)
	beq.s	loc_3B08C
	bra.s	loc_3B0BE
; ---------------------------------------------------------------------------

loc_3B086:
	tst.b	x_direction(a3)
	beq.s	loc_3B0BE

loc_3B08C:
	subi.w	#1,$44(a3)
	bne.s	loc_3B0A6

loc_3B094:
	move.l	#stru_3AF82,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3B0A6:
	move.l	#stru_3AF7C,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	move.l	#stru_3AF62,d7
	jsr	(j_Init_Animation).w

loc_3B0BE:
	clr.w	collision_type(a3)
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	tst.b	$6E(a5)
	bne.w	loc_3B142
	tst.w	d7
	bmi.s	loc_3B0E0
	sf	x_direction(a3)
	bra.s	loc_3B0E4
; ---------------------------------------------------------------------------

loc_3B0E0:
	st	x_direction(a3)

loc_3B0E4:
	cmpi.w	#$40,d7
	bgt.s	loc_3B11E
	cmpi.w	#$FFC0,d7
	blt.s	loc_3B11E
	tst.b	$16(a4)
	beq.s	loc_3B0FE
	tst.b	x_direction(a3)
	beq.s	loc_3B11E
	bra.s	loc_3B104
; ---------------------------------------------------------------------------

loc_3B0FE:
	tst.b	x_direction(a3)
	bne.s	loc_3B11E

loc_3B104:
	sf	is_animated(a3)
	bset	#7,object_meta(a3)
	move.w	#(LnkTo_unk_C7C4E-Data_Index),addroffset_sprite(a3)
	move.l	#0,$50(a5)
	bra.s	loc_3B174
; ---------------------------------------------------------------------------

loc_3B11E:
	cmpi.w	#(LnkTo_unk_C7C4E-Data_Index),addroffset_sprite(a3)
	bne.s	loc_3B174
	st	is_animated(a3)
	move.l	$5E(a5),$50(a5)
	move.l	#stru_3AF62,d7
	jsr	(j_Init_Animation).w
	bclr	#7,object_meta(a3)
	bra.s	loc_3B174
; ---------------------------------------------------------------------------

loc_3B142:
	cmpi.w	#$E0,d7
	bgt.s	loc_3B170
	cmpi.w	#$FF20,d7
	blt.s	loc_3B170
	cmpi.w	#$40,d7
	bgt.s	loc_3B174
	cmpi.w	#$FFC0,d7
	blt.s	loc_3B174
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	$26(a4),d6
	tst.w	d7
	bmi.s	loc_3B16C
	tst.l	d6
	ble.s	loc_3B174
	bra.s	loc_3B170
; ---------------------------------------------------------------------------

loc_3B16C:
	tst.l	d6
	bge.s	loc_3B174

loc_3B170:
	sf	$6E(a5)

loc_3B174:
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3B180:
	tst.b	(Berzerker_charging).w
	beq.w	loc_3B0BE
	st	has_level_collision(a3)
	st	is_moved(a3)
	clr.w	collision_type(a3)
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	$26(a4),d4
	add.l	d4,d4
	move.l	d4,x_vel(a3)
	clr.l	y_vel(a3)

loc_3B1A6:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	tst.l	x_vel(a3)
	bmi.s	loc_3B1BE
	subi.l	#$4000,x_vel(a3)
	bra.s	loc_3B1C6
; ---------------------------------------------------------------------------

loc_3B1BE:
	addi.l	#$4000,x_vel(a3)

loc_3B1C6:
	cmpi.l	#$8000,x_vel(a3)
	bgt.s	loc_3B1DA
	cmpi.l	#$FFFF8000,x_vel(a3)
	bgt.s	loc_3B254

loc_3B1DA:
	move.w	collision_type(a3),d4
	beq.s	loc_3B218
	cmpi.w	#colid_rightwall,d4
	beq.s	loc_3B24C
	cmpi.w	#colid_leftwall,d4
	beq.s	loc_3B24C
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3B1F8
	cmpi.w	#colid_slopedown,d4
	bne.s	loc_3B1A6

loc_3B1F8:
	tst.l	x_vel(a3)
	bmi.s	loc_3B212
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3B24C

loc_3B204:
	move.l	y_vel(a3),d7
	lsr.l	#1,d7
	neg.l	d7
	move.l	d7,y_vel(a3)
	bra.s	loc_3B1A6
; ---------------------------------------------------------------------------

loc_3B212:
	cmpi.w	#$18,d4
	bne.s	loc_3B204

loc_3B218:
	tst.l	y_vel(a3)
	bne.s	loc_3B226
	move.l	#$10000,y_vel(a3)

loc_3B226:
	addi.l	#$4000,y_vel(a3)
	tst.l	x_vel(a3)
	bmi.s	loc_3B240
	addi.l	#$4000,x_vel(a3)
	bra.w	loc_3B1A6
; ---------------------------------------------------------------------------

loc_3B240:
	subi.l	#$4000,x_vel(a3)
	bra.w	loc_3B1A6
; ---------------------------------------------------------------------------

loc_3B24C:
	neg.l	x_vel(a3)
	bra.w	loc_3B1A6
; ---------------------------------------------------------------------------

loc_3B254:
	sf	is_moved(a3)
	sf	has_level_collision(a3)
	move.l	#0,x_vel(a3)
	move.l	#0,y_vel(a3)
	bra.w	loc_3B0BE