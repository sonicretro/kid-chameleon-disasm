unk_3276A:	; depends on whether 0, 1 or 2 hitpoints (or is the palette?)
	dc.w $40	; range in front of hand in which it will detect the kid
	dc.w   1
	dc.l -$3000	; walking velocity

	dc.w $50
	dc.w   2
	dc.l -$4800

	dc.w $64
	dc.w   3
	dc.l -$6000

;loc_32782:
Enemy17_Hand_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	move.w	2(a0),d7	; number of hitpoints
	asl.w	#3,d7
	lea	unk_3276A(pc,d7.w),a4
	move.w	(a4)+,$44(a5)	; 40, 50, 64
	move.w	(a4)+,$46(a5)	; 1, 2, 3
	move.l	(a4),$48(a5)	; -3000, -4800, -6000

loc_327B6:
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	sf	$19(a3)
	st	has_level_collision(a3)
	move.b	#0,priority(a3)
	move.w	#$17,d0
	move.w	d0,object_meta(a3)
	bsr.w	loc_32146
	bsr.w	loc_32AEA
	move.l	(Addr_GfxObject_Kid).w,a2

loc_327E4:
	move.l	$48(a5),d7
	tst.b	x_direction(a3)
	beq.w	loc_327F2
	neg.l	d7

loc_327F2:
	move.l	d7,x_vel(a3)
	move.l	#stru_32B6A,d7
	jsr	(j_Init_Animation).w
	sf	has_kid_collision(a3)

loc_32804:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3299C
	bsr.w	loc_3284C	; check if kid is in range?
	bne.w	loc_328A6	; if yes, check for attack
	bsr.w	loc_32AFE
	beq.w	loc_32AA2
	move.l	x_vel(a3),d5
	bmi.w	loc_32836
	tst.w	d7
	bne.s	loc_32804
	tst.w	d6
	beq.w	loc_328A6

loc_32832:
	bra.w	loc_32840
; ---------------------------------------------------------------------------

loc_32836:
	tst.w	d6
	bne.s	loc_32804
	tst.w	d7
	beq.w	loc_328A6

loc_32840:
	neg.l	d5
	move.l	d5,x_vel(a3)
	not.b	x_direction(a3)
	bra.s	loc_32804
; ---------------------------------------------------------------------------

loc_3284C:
	move.w	$1E(a2),d7
	subi.w	#$10,d7
	sub.w	y_pos(a3),d7
	bpl.w	loc_328A2	; kid is more than 16 px below hand.
	move.w	$1A(a2),d6
	sub.w	x_pos(a3),d6
	tst.b	x_direction(a3)	; horiz direction
	beq.w	loc_32886
	tst.w	d6
	bmi.w	loc_328A2	; kid is behind hand
	cmp.w	$44(a5),d6
	bgt.w	loc_328A2	; kid is too far in front of hand
	neg.w	d7
	cmp.w	d6,d7
	bgt.w	loc_328A2	; y difference is bigger than x difference
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_32886:
	tst.w	d6	; kid is behind hand
	bpl.w	loc_328A2
	move.w	$44(a5),d4
	neg.w	d4
	cmp.w	d4,d6
	blt.w	loc_328A2	; kid is too far in front of hand
	cmp.w	d6,d7
	blt.w	loc_328A2	; y difference is bigger than x difference
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_328A2:
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_328A6:
	move.w	$46(a5),d5	; 1, 2, or 3 depending on hitpoints (HP)

loc_328AA:
	jsr	(j_Get_RandomNumber_byte).w	; --> d7
	move.w	$1E(a2),d6	; kid's y position
	eor.b	d6,d7
	andi.l	#3,d7
	add.w	d5,d7	; value between HP and HP+3
	neg.w	d7
	swap	d7
	move.l	d7,y_vel(a3) ; hand's y velocity
	jsr	(j_Get_RandomNumber_byte).w
	move.w	$1A(a2),d6	; kid's x position
	eor.b	d6,d7
	andi.l	#3,d7
	add.w	d5,d7	; value between HP and HP+3
	tst.b	x_direction(a3)	; x direction
	bne.w	loc_328E0
	neg.w	d7

loc_328E0:
	swap	d7
	move.l	d7,x_vel(a3)	; hand's x velocity
	move.l	#stru_32B56,d7
	jsr	(j_Init_Animation).w

loc_328F0:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_329F8	; collision
	addi.l	#$4000,y_vel(a3)	; add gravity
	bra.s	loc_328F0
; ---------------------------------------------------------------------------

loc_32906:
	sf	has_level_collision(a3)
	sf	is_moved(a3)
	move.w	#$201,$A(a3)
	jsr	(j_sub_FF6).w
	move.l	#stru_32B50,d7
	jsr	(j_Init_Animation).w
	moveq	#$A,d3
	sf	d2
	st	has_kid_collision(a3)
	st	(KidGrabbedByHand).w

loc_3292E:
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_32970
	move.w	$1A(a2),d7
	addq.w	#2,d7
	tst.b	x_direction(a3)
	beq.w	loc_3294C
	subq.w	#4,d7

loc_3294C:
	move.w	d7,x_pos(a3)
	clr.w	$1C(a3)
	move.w	$1E(a2),d7
	subq.w	#4,d7
	move.w	d7,y_pos(a3)
	clr.w	$20(a3)
	move.b	$16(a2),d7
	cmp.b	d7,d2
	beq.s	loc_3292E
	move.b	d7,d2
	subq.w	#1,d3
	bne.s	loc_3292E

loc_32970:
	move.w	#$100,$A(a3)
	jsr	(j_sub_FF6).w
	sf	(KidGrabbedByHand).w
	move.w	#9,d6
	move.w	#$E,d7
	bsr.w	loc_3639E
	bne.w	loc_32AA2
	st	has_level_collision(a3)
	st	is_moved(a3)
	moveq	#2,d5
	bra.w	loc_328AA
; ---------------------------------------------------------------------------

loc_3299C:
	move.w	collision_type(a3),d7
	bmi.w	loc_32AA2
	beq.w	return_329B4
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	off_329B6(pc,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

return_329B4:
	rts
; ---------------------------------------------------------------------------
off_329B6:	; Collision specific behaviour, while the hand is on ground
	dc.l loc_329E2
	dc.l loc_329E2
	dc.l loc_32AA2
	dc.l loc_32AA2
	dc.l loc_329E2
	dc.l loc_329E2
	dc.l loc_32AA2
	dc.l loc_329EC
	dc.l loc_329EC
	dc.l loc_329EC
	dc.l loc_32AA2
; ---------------------------------------------------------------------------

loc_329E2:
	neg.l	x_vel(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------

loc_329EC:
	move.w	#$28,$38(a2)
	clr.w	$3A(a2)
	rts
; ---------------------------------------------------------------------------

loc_329F8:
	move.w	collision_type(a3),d7
	beq.w	return_32A10
	bmi.w	loc_32AA2
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	off_32A12(pc,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

return_32A10:
	rts
; ---------------------------------------------------------------------------
off_32A12:	; Collision specific behaviour, while the hand is jumping?
	dc.l loc_32A44
	dc.l loc_32A44
	dc.l loc_32A4A
	dc.l loc_32A3E
	dc.l loc_32A5A
	dc.l loc_32A70
	dc.l return_32A10
	dc.l loc_32A86
	dc.l loc_32A86
	dc.l loc_32A86
	dc.l return_32A10
; ---------------------------------------------------------------------------

loc_32A3E:
	clr.l	y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_32A44:
	clr.l	x_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_32A4A:
	moveq	#0,d7
	move.l	d7,y_vel(a3)
	move.l	d7,x_vel(a3)
	addq.w	#4,sp
	bra.w	loc_327E4
; ---------------------------------------------------------------------------

loc_32A5A:
	bsr.w	loc_350F2
	move.l	#$FFFE8000,x_vel(a3)
	move.l	#$FFFE8000,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_32A70:
	bsr.w	loc_350F2
	move.l	#$18000,x_vel(a3)
	move.l	#$FFFE8000,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_32A86:
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	beq.s	return_32A10
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	return_32A10
	tst.b	(KidGrabbedByHand).w
	beq.w	loc_32906
	rts
; ---------------------------------------------------------------------------

loc_32AA2:
	st	has_kid_collision(a3)
	sf	is_moved(a3)
	move.l	#stru_32B78,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_32AD8
	btst	#6,d0
	beq.s	loc_32AE6
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_32AE6
; ---------------------------------------------------------------------------

loc_32AD8:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_32AE6:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_32AEA:
	move.w	y_pos(a3),d7
	subq.w	#8,d7
	andi.w	#$FFF0,d7
	addi.w	#$F,d7
	move.w	d7,y_pos(a3)
	rts
; ---------------------------------------------------------------------------

loc_32AFE:
	move.w	y_pos(a3),d7
	addq.w	#1,d7
	asr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	x_pos(a3),d7
	move.w	d7,d6
	subi.w	#$E,d6
	addi.w	#$E,d7
	asr.w	#4,d6
	asr.w	#4,d7
	sub.w	d6,d7
	add.w	d6,d6
	add.w	d6,a4
	move.w	(a4),d5
	andi.w	#$4000,d5
	moveq	#0,d4

loc_32B32:
	move.w	(a4)+,d6
	andi.w	#$4000,d6
	beq.w	loc_32B3E
	moveq	#1,d4

loc_32B3E:
	dbf	d7,loc_32B32
	move.w	d5,d6
	move.w	-2(a4),d7
	andi.w	#$4000,d7
	tst.w	d4
	rts

;stru_32B50: 
	include "ingame/anim/enemy/Hand.asm"
