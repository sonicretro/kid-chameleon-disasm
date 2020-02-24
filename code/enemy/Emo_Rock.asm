word_361A2:	dc.w $50
word_361A4:	dc.w $2000
	dc.b   0
	dc.b $3C
	dc.b $30
	dc.b   0
	dc.b   0
	dc.b $28
	dc.b $40
	dc.b   0

;loc_361AE:
Enemy1B_EmoRock_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a0
	move.w	2(a0),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	word_361A2(pc,d7.w),d1
	moveq	#0,d2
	move.w	word_361A4(pc,d7.w),d2
	add.l	d2,d2
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#$1B,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	(Addr_GfxObject_Kid).w,a2

loc_361F4:
	move.w	#$3C,d0
	jsr	(j_Get_RandomNumber_byte).w
	move.w	$1A(a2),d6
	eor.b	d6,d7
	bclr	#7,d7
	ext.w	d7
	add.w	d7,d0
	st	has_kid_collision(a3)
	sf	has_level_collision(a3)

loc_36212:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.s	loc_36212

loc_3621A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	$1E(a2),d7
	sub.w	d1,d7
	move.w	d7,y_pos(a3)
	move.w	$1A(a2),x_pos(a3)
	move.w	#$1C,d6
	move.w	#$E,d7
	bsr.w	loc_3639E
	bne.s	loc_3621A
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_3647E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	st	has_level_collision(a3)
	sf	has_kid_collision(a3)

loc_3625E:
	move.l	y_vel(a3),d7
	add.l	d2,d7
	cmpi.l	#$60000,d7
	ble.w	loc_36274
	move.l	#$40000,d7

loc_36274:
	move.l	d7,y_vel(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	beq.s	loc_3625E
	bmi.w	loc_36346
	clr.w	collision_type(a3)
	cmpi.w	#$1C,d7
	bge.s	loc_3625E
	sf	x_direction(a3)
	move.w	$1A(a2),d7
	cmp.w	x_pos(a3),d7
	blt.w	loc_362A4
	st	x_direction(a3)

loc_362A4:
	clr.l	y_vel(a3)
	sf	has_level_collision(a3)
	move.l	#stru_363FE,d7
	jsr	(j_Init_Animation).w

loc_362B6:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$18(a3)
	bne.w	loc_36320
	move.w	collision_type(a3),d7
	beq.s	loc_362B6
	bmi.w	loc_36346
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d7
	beq.w	loc_36346
	cmpi.w	#$1C,d7
	beq.w	loc_36346
	cmpi.w	#$20,d7
	beq.w	loc_362EE
	cmpi.w	#$24,d7
	bne.s	loc_362B6

loc_362EE:
	tst.b	(Berzerker_charging).w
	beq.s	loc_362B6
	st	has_kid_collision(a3)
	sf	has_level_collision(a3)
	move.l	$26(a2),x_vel(a3)
	move.l	#$FFFD0000,y_vel(a3)

loc_3630A:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_36346
	addi.l	#$6000,y_vel(a3)
	bra.s	loc_3630A
; ---------------------------------------------------------------------------

loc_36320:
	st	has_kid_collision(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Emo_Rock_disappears,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_36456,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	clr.w	addroffset_sprite(a3)
	bra.w	loc_361F4
; ---------------------------------------------------------------------------

loc_36346:
	st	has_kid_collision(a3)
	sf	is_moved(a3)
	move.l	#stru_36468,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	d0,-(sp)
	moveq	#sfx_Prize_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_3638C
	btst	#6,d0
	beq.s	loc_3639A
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3639A
; ---------------------------------------------------------------------------

loc_3638C:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_3639A:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3639E:
	move.w	y_pos(a3),d4
	move.w	d4,d5
	sub.w	d6,d4
	bmi.w	loc_363FA
	asr.w	#4,d4
	asr.w	#4,d5
	sub.w	d4,d5
	add.w	d4,d4
	lea	($FFFF4A04).l,a0
	move.w	(a0,d4.w),a0
	move.w	x_pos(a3),d4
	move.w	d4,d6
	sub.w	d7,d4
	bmi.w	loc_363FA
	add.w	d7,d6
	cmp.w	(Level_width_pixels).w,d6
	bge.w	loc_363FA
	asr.w	#4,d4
	asr.w	#4,d6
	sub.w	d4,d6
	add.w	d4,d4
	add.w	d4,a0

loc_363DC:
	move.w	d6,d7
	move.w	a0,a1

loc_363E0:
	move.w	(a1)+,d4
	andi.w	#$4000,d4
	bne.w	loc_363FA
	dbf	d7,loc_363E0
	add.w	(Level_width_tiles).w,a0
	dbf	d5,loc_363DC
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_363FA:
	moveq	#1,d7
	rts