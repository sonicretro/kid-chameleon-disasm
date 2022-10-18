;loc_364A0:
Enemy1D_BigHoppingSkull_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	($FFFFF93C).w,$3E(a3)
	move.w	(EnemyHeader7D).w,$40(a3)
	addi.w	#$40,$3E(a3)
	subi.w	#$40,$40(a3)
	st	has_level_collision(a3)
	st	$13(a3)
	st	x_direction(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#objid_BigHoppingSkull,d0 ; loaded sprite id
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	(Addr_GfxObject_Kid).w,a2
	move.w	#(LnkTo_unk_C7FC0-Data_Index),addroffset_sprite(a3)
	move.w	2(a0),d0 ; load enemy hitpoints
	cmpi.w	#0,d0
	bne.s	loc_3650E ; give enemy 1 hitpoint
	move.w	#2,d2 ; give enemy 2 hitpoints
	bra.s	loc_3651E
; ---------------------------------------------------------------------------

loc_3650E:
	cmpi.w	#1,d0
	bne.s	loc_3651A ; give enemy 4 hitpoints
	move.w	#3,d2 ; give enemy 3 hitpoints
	bra.s	loc_3651E
; ---------------------------------------------------------------------------

loc_3651A:
	move.w	#4,d2

loc_3651E:
	clr.w	y_vel(a3)
	move.w	#$FFFE,y_vel(a3)
	move.w	#1,x_vel(a3)

loc_3652E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	move.l	#stru_367BE,d7
	jsr	(j_Init_Animation).w

loc_36540:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3656C
	addi.l	#$FA0,y_vel(a3)
	bsr.w	loc_3674E
	tst.b	$18(a3)
	beq.s	loc_36540
	addi.l	#$FA0,y_vel(a3)
	bsr.w	loc_3656C
	bra.s	loc_3652E
; ---------------------------------------------------------------------------

loc_3656C:
	move.w	y_pos(a3),d4
	cmp.w	(Level_height_blocks).w,d4
	blt.w	return_3657C
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

return_3657C:
	rts
; ---------------------------------------------------------------------------
	rts
; ---------------------------------------------------------------------------

loc_36580:
	addq.w	#4,sp
	move.w	#8,d7
	bsr.w	loc_33286
	cmpi.w	#$6000,d6
	bne.w	loc_366D0
	sf	has_level_collision(a3)
	move.l	x_vel(a3),d0
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	move.l	#stru_367AE,d7
	jsr	(j_Init_Animation).w

loc_365AC:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	move.w	#8,d7
	bsr.w	loc_33286
	tst.w	d6
	beq.w	loc_366D0
	move.w	collision_type(a3),d7
	beq.w	loc_366B6
	cmpi.w	#colid_hurt,d7
	beq.s	loc_365D8
	cmpi.w	#colid_kidabove,d7
	bne.w	loc_366B6

loc_365D8:
	st	has_kid_collision(a3)
	move.w	#$FFFD,$2A(a2)	; this causes the bug where the kid bounces up when killing the skull
	subq.w	#1,d2
	beq.w	loc_3664E
	move.l	#stru_367CC,d7
	jsr	(j_Init_Animation).w

loc_365F2:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	cmpi.w	#(LnkTo_unk_C7FB0-Data_Index),addroffset_sprite(a3)
	bne.s	loc_36616
	cmpi.w	#6,animation_timer(a3)
	bne.s	loc_36616
	move.l	d0,-(sp)
	moveq	#sfx_Big_Hopping_Skull_groan,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_36616:
	cmpi.w	#(LnkTo_unk_C7FE0-Data_Index),addroffset_sprite(a3)
	bne.s	loc_36632
	cmpi.w	#$C,animation_timer(a3)
	bne.s	loc_36632
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_36632:
	move.w	#8,d7
	bsr.w	loc_33286
	tst.w	d6
	beq.w	loc_366D0
	tst.b	$18(a3)
	beq.s	loc_365F2
	sf	has_kid_collision(a3)
	bra.w	loc_366B6
; ---------------------------------------------------------------------------

loc_3664E:
	move.l	d0,-(sp)
	moveq	#sfx_Big_Hopping_Skull_dies,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_367FA,d7
	jsr	(j_Init_Animation).w

loc_36664:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	move.w	#8,d7
	bsr.w	loc_33286
	tst.w	d6
	bne.s	loc_3667E
	move.w	#2,y_vel(a3)

loc_3667E:
	tst.b	$18(a3)
	beq.s	loc_36664
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_366A4
	btst	#6,d0
	beq.s	loc_366B2
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_366B2
; ---------------------------------------------------------------------------

loc_366A4:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_366B2:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_366B6:
	bsr.w	loc_3656C
	tst.b	$18(a3)
	beq.w	loc_365AC
	move.l	#stru_367B4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w	; hibernate the object until $18(a3) is non-zero

loc_366D0:
	move.w	#-2,y_vel(a3)
	move.l	d0,x_vel(a3)
	st	has_level_collision(a3)
	bsr.w	loc_36770
	bra.w	loc_3652E
; ---------------------------------------------------------------------------

loc_366E6:
	neg.l	y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_366EC:
	move.l	x_vel(a3),d7
	sub.l	d7,x_pos(a3)
	sub.l	d7,x_pos(a3)
	clr.l	y_vel(a3)
	neg.l	x_vel(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------

loc_36706:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),d6
	neg.l	d6
	move.l	d7,y_vel(a3)
	move.l	d6,x_vel(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------

loc_36720:
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	move.l	d7,y_vel(a3)
	move.l	d6,x_vel(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------
off_36736: ; jumping directions
	dc.l loc_366EC	; colid_rightwall
	dc.l loc_366EC	; colid_leftwall
	dc.l loc_36580	; colid_floor
	dc.l loc_366E6	; colid_ceiling
	dc.l loc_36706	; colid_slopeup
	dc.l loc_36720	; colid_slopedown
; ---------------------------------------------------------------------------

loc_3674E:
	move.w	collision_type(a3),d7
	beq.w	return_3676E
	clr.w	collision_type(a3)
	cmpi.w	#colid_hurt,d7
	bge.w	return_3676E
	subq.w	#4,d7
	lea	off_36736(pc),a4
	move.l	(a4,d7.w),a4
	jsr	(a4)

return_3676E:
	rts
; ---------------------------------------------------------------------------

loc_36770:
	move.w	x_pos(a3),d4
	cmp.w	$3E(a3),d4
	ble.s	loc_36782
	cmp.w	$40(a3),d4
	bge.s	loc_36798
	rts
; ---------------------------------------------------------------------------

loc_36782:
	clr.w	y_vel(a3)
	move.w	#$FFFE,y_vel(a3)
	move.w	#1,x_vel(a3)
	st	x_direction(a3)
	rts
; ---------------------------------------------------------------------------

loc_36798:
	clr.w	y_vel(a3)
	move.w	#$FFFE,y_vel(a3)
	move.w	#$FFFF,x_vel(a3)
	sf	x_direction(a3)
	rts

;stru_367AE: 
	include "ingame/anim/enemy/Big_Hopping_Skull.asm"
