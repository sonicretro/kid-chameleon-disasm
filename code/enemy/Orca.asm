;stru_3D0A2: 
	include "ingame/anim/enemy/Orca.asm"

;loc_3D158:
Enemy08_Orca_Init: 
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a4
	move.w	2(a4),enemy_hp(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3D194
	st	x_direction(a3)

loc_3D194:
	st	$13(a3)
	move.w	#8,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.l	#$8000,$50(a5)
	move.l	#$8000,$5E(a5)
	move.w	#$1B,$4A(a5)
	move.w	#$E,$48(a5)
	move.w	#$12C,$6E(a5)
	move.w	#$32,$54(a5)
	move.l	#loc_3D2DE,$6A(a5)
	move.l	#stru_3D0A2,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3D0A2,$62(a5)
	move.l	#stru_3D0D4,$66(a5)
	move.w	#$5CC,$4A(a3)
	move.w	#4,current_hp(a3)
	move.w	#$12C,$54(a5)
	move.w	#3,$4C(a5)
	move.l	#loc_3D21E,a0
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3D21E:
	move.w	collision_type(a3),d4
	bmi.s	loc_3D268
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3D23E
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3D27E
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3D27E
	cmpi.w	#colid_kidabove,d4
	bne.w	loc_3D2BC

loc_3D23E:
	subq.w	#1,$44(a3)
	beq.s	loc_3D268
	move.l	#stru_3D118,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3D2BC
; ---------------------------------------------------------------------------

loc_3D268:
	st	has_kid_collision(a3)
	move.l	#stru_3D11E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3D27E:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3D2BC
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7656-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3D2AA:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3D2AA
; ---------------------------------------------------------------------------

loc_3D2BC:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3D2D2
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3D2D2:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3D2DE:
	tst.w	$42(a3)
	bgt.w	loc_3D2F4
	subq.w	#1,$54(a5)
	bne.w	loc_3D466
	move.w	$6E(a5),$54(a5)

loc_3D2F4:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d0
	sub.w	x_pos(a4),d0
	cmpi.w	#$FFD0,d0
	blt.w	loc_3D466
	cmpi.w	#$30,d0
	bgt.w	loc_3D466
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7656-Data_Index),addroffset_sprite(a3)
	moveq	#5,d1

loc_3D320:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	bne.w	loc_3D21E
	dbf	d1,loc_3D320
	tst.b	x_direction(a3)
	bne.s	loc_3D340
	move.l	#$FFFD0000,x_vel(a3)
	bra.s	loc_3D348
; ---------------------------------------------------------------------------

loc_3D340:
	move.l	#$30000,x_vel(a3)

loc_3D348:
	move.l	#$FFFD8000,y_vel(a3)
	addi.w	#4,addroffset_sprite(a3)
	st	has_level_collision(a3)

loc_3D35A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	move.w	collision_type(a3),d4
	beq.s	loc_3D3B4
	cmpi.w	#colid_floor,d4
	beq.w	loc_3D420
	cmpi.w	#colid_rightwall,d4
	beq.w	loc_3D40C
	cmpi.w	#colid_leftwall,d4
	beq.w	loc_3D40C
	cmpi.w	#colid_ceiling,d4
	beq.w	loc_3D47A
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3D3DE
	cmpi.w	#colid_slopedown,d4
	beq.s	loc_3D3DE
	cmpi.w	#colid_hurt,d4
	beq.w	loc_3D472
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3D472
	cmpi.w	#colid_kidright,d4
	beq.w	loc_3D4DE
	cmpi.w	#colid_kidleft,d4
	beq.w	loc_3D4DE

loc_3D3B4:
	addi.l	#$1800,y_vel(a3)
	tst.b	$5C(a5)
	bne.s	loc_3D35A
	tst.w	x_direction(a3)
	bne.s	loc_3D3D2
	addi.l	#-$200,x_vel(a3)
	bra.s	loc_3D35A
; ---------------------------------------------------------------------------

loc_3D3D2:
	addi.l	#$200,x_vel(a3)
	bra.w	loc_3D35A
; ---------------------------------------------------------------------------

loc_3D3DE:
	clr.w	collision_type(a3)
	eori.b	#$FF,x_direction(a3)
	move.w	#(LnkTo_unk_C7656-Data_Index),addroffset_sprite(a3)
	moveq	#5,d1
	sf	has_level_collision(a3)
	sf	$5C(a5)
	move.l	#0,x_vel(a3)
	move.l	#0,y_vel(a3)
	bra.w	loc_3D320
; ---------------------------------------------------------------------------

loc_3D40C:
	clr.w	collision_type(a3)
	move.l	#0,x_vel(a3)
	st	$5C(a5)
	bra.w	loc_3D35A
; ---------------------------------------------------------------------------

loc_3D420:
	clr.w	collision_type(a3)
	move.l	#0,x_vel(a3)
	move.l	#0,y_vel(a3)
	sf	$5C(a5)
	sf	has_level_collision(a3)
	sf	is_moved(a3)
	addi.w	#4,addroffset_sprite(a3)
	move.w	#5,d1

loc_3D44A:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_3D44A
	st	is_animated(a3)
	move.l	#stru_3D0A2,d7
	jsr	(j_Init_Animation).w
	move.l	#loc_3D21E,a0

loc_3D466:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3D472:
	subi.w	#1,$44(a3)
	beq.s	loc_3D48A

loc_3D47A:
	clr.w	collision_type(a3)
	move.l	#$18000,y_vel(a3)
	bra.w	loc_3D35A
; ---------------------------------------------------------------------------

loc_3D48A:
	move.l	#$18000,y_vel(a3)
	st	has_kid_collision(a3)

loc_3D496:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1800,y_vel(a3)
	move.w	collision_type(a3),d4
	cmpi.w	#colid_floor,d4
	beq.s	loc_3D4BC
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3D4BC
	cmpi.w	#colid_slopedown,d4
	bne.s	loc_3D496

loc_3D4BC:
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	sf	is_moved(a3)
	sf	has_level_collision(a3)
	move.l	#stru_3D11E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3D4DE:
	tst.b	(Berzerker_charging).w
	beq.w	loc_3D3B4
	bra.w	loc_3D21E