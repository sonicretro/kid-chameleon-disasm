;loc_3ACDA:
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a4
	move.w	2(a4),enemy_hp(a3)	; hitpoints
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3AD16
	st	x_direction(a3)

loc_3AD16:
	st	$13(a3)
	move.w	#1,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	bset	#6,object_meta(a3)
	move.b	#0,priority(a3)
	move.w	enemy_hp(a3),d7 ; enemy hitpoints
	addq.w	#2,d7	; have at least 2 HP
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7	; how many hitpoints?
	bgt.s	loc_3AD7C	; more than 3
	blt.s	loc_3AD4C	; 2 --> speed =$10000
	move.l	#$8000,$50(a5)	; 3 --> speed =$18000

loc_3AD4C:
	addi.l	#$10000,$50(a5)
	move.w	#$20,$4A(a5)
	move.w	#$A,$48(a5)
	move.l	#stru_3ACA8,d7
	jsr	(j_Init_Animation).w
	move.l	#loc_3AEC4,a0
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------
; code for diamond with > 3 HP. Falls off ledges
loc_3AD7C:
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.l	#stru_3ACA8,d7
	jsr	(j_Init_Animation).w
	move.l	#$18000,x_vel(a3)
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	bmi.s	loc_3ADA4
	neg.l	x_vel(a3)

loc_3ADA4:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	move.w	collision_type(a3),d4
	beq.w	loc_3AE78
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3ADFA
	cmpi.w	#colid_floor,d4
	beq.s	loc_3ADA4
	cmpi.w	#colid_rightwall,d4
	beq.w	loc_3AE3E
	cmpi.w	#colid_leftwall,d4
	beq.w	loc_3AE3E
	cmpi.w	#colid_ceiling,d4
	beq.s	loc_3AE3E
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3AE4A
	cmpi.w	#colid_slopedown,d4
	beq.w	loc_3AE68
	cmpi.w	#colid_kidright,d4
	beq.w	loc_3AE84
	cmpi.w	#colid_kidleft,d4
	beq.w	loc_3AE84
	bra.s	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3ADFA:	; lose a hit point
	subq.w	#1,$44(a3)
	beq.s	loc_3AE28
	sf	is_moved(a3)
	move.l	#stru_3ACBE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	st	is_moved(a3)
	clr.w	collision_type(a3)
	move.l	#stru_3ACA8,d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE28:
	sf	is_moved(a3)
	move.l	#stru_3ACC4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3AE3E:
	neg.l	x_vel(a3)
	neg.l	y_vel(a3)
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE4A:
	tst.l	x_vel(a3)
	bmi.s	loc_3AE5C

loc_3AE50:
	move.l	#-$18000,y_vel(a3)
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE5C:
	move.l	#$18000,y_vel(a3)
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE68:
	tst.l	x_vel(a3)
	bmi.s	loc_3AE50
	bra.s	loc_3AE5C
; ---------------------------------------------------------------------------
	clr.l	y_vel(a3)
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE78:
	move.l	#$1C000,y_vel(a3)
	bra.w	loc_3ADA4
; ---------------------------------------------------------------------------

loc_3AE84:
	tst.b	(Berzerker_charging).w
	beq.w	loc_3ADA4
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C8160-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#-$48000,y_vel(a3)

loc_3AEB2:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3AEB2
; ---------------------------------------------------------------------------
; code for diamond with <= 3 HP. Doesn't fall off ledges.
loc_3AEC4:
	move.w	collision_type(a3),d4
	beq.s	loc_3AF14
	bmi.s	loc_3AEE6
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3AF24
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3AF24
	cmpi.w	#colid_hurt,d4
	bne.s	loc_3AF14
	; lose a hit point
	subq.w	#1,$44(a3)
	bne.w	loc_3AEF8

loc_3AEE6:
	move.l	#stru_3ACC4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E	; delete enemy
; ---------------------------------------------------------------------------

loc_3AEF8:
	move.l	#stru_3ACBE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	clr.w	collision_type(a3)
	move.l	#stru_3ACA8,d7
	jsr	(j_Init_Animation).w

loc_3AF14:
	clr.w	collision_type(a3)
	; Use direction specific routine that takes care of movement and in
	; particular turns the enemy around when close to a ledge.
	; At the end, this routine jumps back to (a0).
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3AF24:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3AF14
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C8160-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#-$48000,y_vel(a3)

loc_3AF50:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3AF50