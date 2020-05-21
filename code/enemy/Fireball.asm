unk_32BA6:	; hit point specific value pairs.
		; first value: gravity
		; second value: maximum upwards speed.
	dc.l $1000
	dc.l -$30000
	dc.l $2000
	dc.l -$40000
	dc.l $3000
	dc.l -$50000

;loc_32BBE:
Enemy19_Fireball_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	#0,priority(a3)
	move.w	#$19,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.w	#(LnkTo_unk_C7906-Data_Index),addroffset_sprite(a3)
	move.w	2(a0),d7	; hitpoints
	asl.w	#3,d7
	lea	unk_32BA6(pc,d7.w),a4
	move.l	(a4)+,d0
	move.l	(a4),d1
	move.l	d1,d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#5,d3
	moveq	#0,d2

loc_32C1A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	add.l	d0,y_vel(a3)
	bsr.w	loc_32C60
	bsr.w	loc_32F3E
	bsr.w	loc_3304A
	bra.s	loc_32C1A
; ---------------------------------------------------------------------------
;off_32C34
Enemy19_Fireball_CollisionBehaviors:
	dc.l Enemy19_Fireball_BounceWall	; bounce on wall
	dc.l Enemy19_Fireball_BounceWall	; bounce on wall
	dc.l Enemy19_Fireball_BounceFloorCeiling	; bounce on floor
	dc.l Enemy19_Fireball_BounceFloorCeiling	; bounce on ceiling
	dc.l Enemy19_Fireball_SlopeUp	; bounce on slope?
	dc.l Enemy19_Fireball_SlopeDown	; bounce on slope?
	dc.l Enemy19_Fireball_Kill	; destroy fireball
	dc.l Enemy19_Fireball_DoNothing	; do nothing
	dc.l Enemy19_Fireball_DoNothing	; do nothing
	dc.l Enemy19_Fireball_DoNothing	; do nothing
	dc.l Enemy19_Fireball_Kill	; destroy fireball
; ---------------------------------------------------------------------------

loc_32C60:
	move.w	collision_type(a3),d7
	beq.w	Enemy19_Fireball_DoNothing
	bmi.w	Enemy19_Fireball_Kill
	subq.w	#4,d7
	clr.w	collision_type(a3)
	tst.b	$19(a3)
	bne.w	loc_32C86
	move.l	d0,-(sp)
	moveq	#sfx_Fireball_bouncing,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_32C86:
	move.l	Enemy19_Fireball_CollisionBehaviors(pc,d7.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------

Enemy19_Fireball_DoNothing:
	rts
; ---------------------------------------------------------------------------

Enemy19_Fireball_BounceWall:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	rts
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	(Addr_GfxObject_Kid).w,a0
	add.l	$26(a0),d7
	move.l	d7,x_vel(a3)
	rts
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	(Addr_GfxObject_Kid).w,a0
	add.l	$26(a0),d7
	move.l	d7,x_vel(a3)
	rts
; ---------------------------------------------------------------------------

Enemy19_Fireball_BounceFloorCeiling:
	jsr	(j_Get_RandomNumber_byte).w
	move.b	(Camera_X_pos).w,d6
	eor.b	d6,d7
	ext.w	d7	; random number between -$80 (-128) and $7F (+127)
	asl.w	#7,d7	; random number between -$4000 and $3FFF
	ext.l	d7	; meaning -1/4 and +1/4 px per frame
	add.l	y_vel(a3),d7	; adjust y velocity with this value
	neg.l	d7
	bpl.w	loc_32CE4
	cmp.l	d1,d7	; upwards y speed is capped.
	bgt.w	loc_32CE4
	move.l	d1,d7

loc_32CE4:
	move.l	d7,y_vel(a3)
	cmpi.w	#5,(Number_of_Fire_Trails).w
	bge.w	return_32D06
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_33128,4(a0)
	addq.w	#1,(Number_of_Fire_Trails).w

return_32D06:
	rts
; ---------------------------------------------------------------------------
	move.l	y_vel(a3),d7
	asr.l	#1,d7
	neg.l	d7
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

Enemy19_Fireball_SlopeUp:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),d6
	neg.l	d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	add.l	d7,x_pos(a3)
	add.l	d6,y_pos(a3)
	cmpi.w	#5,(Number_of_Fire_Trails).w
	bge.s	return_32D06
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_330D0,4(a0)
	addq.w	#1,(Number_of_Fire_Trails).w
	st	$44(a0)
	move.w	addroffset_sprite(a3),d7
	asr.w	#1,d7
	lea	(CollisionSize_Index).l,a4
	add.w	(a4,d7.w),a4
	move.w	x_pos(a3),d7
	sub.w	x_vel(a3),d7
	tst.b	x_direction(a3)
	beq.w	loc_32D7E
	sub.w	(a4),d7
	bra.w	loc_32D7E
; ---------------------------------------------------------------------------
	add.w	(a4),d7
	add.w	2(a4),d7

loc_32D7E:
	move.w	y_pos(a3),d6
	sub.w	y_vel(a3),d6
	add.w	4(a4),d6
	add.w	6(a4),d6
	lea	($FFFF4A04).l,a4
	move.w	d6,d5
	asr.w	#4,d5
	add.w	d5,d5
	move.w	(a4,d5.w),a4
	move.w	d7,d5
	asr.w	#4,d5
	add.w	d5,d5
	add.w	d5,a4
	move.w	(a4),d5
	andi.w	#$7000,d5
	cmpi.w	#$4000,d5
	bne.w	return_32D06
	move.w	d7,d5
	andi.w	#$F,d5
	andi.w	#$FFF0,d6
	addi.w	#$F,d6
	sub.w	d5,d6
	addq.w	#2,d7
	subq.w	#2,d6
	move.w	d7,$46(a0)
	move.w	d6,$48(a0)
	rts
; ---------------------------------------------------------------------------

Enemy19_Fireball_SlopeDown:
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	neg.l	d7
	neg.l	d6
	add.l	d7,x_pos(a3)
	add.l	d6,y_pos(a3)
	cmpi.w	#5,(Number_of_Fire_Trails).w
	bge.w	return_32D06
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_330D0,4(a0)
	addq.w	#1,(Number_of_Fire_Trails).w
	sf	$44(a0)
	move.w	addroffset_sprite(a3),d7
	asr.w	#1,d7
	lea	(CollisionSize_Index).l,a4
	add.w	(a4,d7.w),a4
	move.w	x_pos(a3),d7
	sub.w	x_vel(a3),d7
	tst.b	x_direction(a3)
	beq.w	loc_32E3C
	add.w	(a4),d7
	bra.w	loc_32E3C
; ---------------------------------------------------------------------------
	sub.w	(a4),d7
	sub.w	2(a4),d7

loc_32E3C:
	move.w	y_pos(a3),d6
	sub.w	y_vel(a3),d6
	add.w	4(a4),d6
	add.w	6(a4),d6
	lea	($FFFF4A04).l,a4
	move.w	d6,d5
	asr.w	#4,d5
	add.w	d5,d5
	move.w	(a4,d5.w),a4
	move.w	d7,d5
	asr.w	#4,d5
	add.w	d5,d5
	add.w	d5,a4
	move.w	(a4),d5
	andi.w	#$7000,d5
	cmpi.w	#$5000,d5
	bne.w	return_32D06
	move.w	d7,d5
	andi.w	#$F,d5
	andi.w	#$FFF0,d6
	add.w	d5,d6
	subq.w	#2,d7
	subq.w	#2,d6
	move.w	d7,$46(a0)
	move.w	d6,$48(a0)
	rts
; ---------------------------------------------------------------------------

Enemy19_Fireball_Kill:
	sf	is_moved(a3)
	st	has_kid_collision(a3)
	clr.w	vram_tile(a3)
	sf	palette_line(a3)
	move.l	#stru_345E4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_32ECA
	btst	#6,d0
	beq.s	loc_32ED8
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_32ED8
; ---------------------------------------------------------------------------

loc_32ECA:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_32ED8:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
unk_32EDC:	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
; ---------------------------------------------------------------------------

loc_32F3E:
	move.l	y_vel(a3),d7
	move.l	x_vel(a3),d6
	asr.l	#8,d7
	asr.l	#8,d6
	andi.l	#$FFFF,d7
	andi.l	#$FFFF,d6
	move.w	d7,d4
	lea	unk_32EDC(pc),a4
	tst.w	d6
	beq.w	loc_3300A
	bmi.w	loc_32F78
	moveq	#3,d5
	tst.w	d7
	bpl.w	loc_32FE8
	neg.w	d7
	move.w	#0,d5
	bra.w	loc_32FAC
; ---------------------------------------------------------------------------

loc_32F78:
	neg.w	d6
	moveq	#2,d5
	tst.w	d7
	bpl.w	loc_32FC8
	neg.w	d7
	moveq	#1,d5
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	move.w	#6,d6
	cmpi.w	#$3F,d7
	bge.w	loc_33018
	move.b	(a4,d7.w),d6
	ext.w	d6
	neg.w	d6
	addi.w	#9,d6
	bra.w	loc_33006
; ---------------------------------------------------------------------------

loc_32FAC:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	cmpi.w	#$3F,d7
	bge.w	loc_33018
	move.b	(a4,d7.w),d6
	ext.w	d6
	bra.w	loc_33006
; ---------------------------------------------------------------------------

loc_32FC8:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	cmpi.w	#$3F,d7
	bge.w	loc_33018
	move.b	(a4,d7.w),d6
	ext.w	d6
	addi.w	#$A,d6
	bra.w	loc_33006
; ---------------------------------------------------------------------------

loc_32FE8:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	cmpi.w	#$3F,d7
	bge.w	loc_33018
	move.b	(a4,d7.w),d6
	ext.w	d6
	neg.w	d6
	addi.w	#$13,d6

loc_33006:
	move.w	d5,d7

return_33008:
	rts
; ---------------------------------------------------------------------------

loc_3300A:
	move.w	#4,d6
	tst.w	d7
	bmi.s	return_33008
	move.w	#$F,d6
	rts
; ---------------------------------------------------------------------------

loc_33018:
	move.w	#4,d6
	tst.w	d4
	bmi.s	loc_33006
	move.w	#$F,d6
	bra.s	loc_33006
; ---------------------------------------------------------------------------
off_33026:	dc.w LnkTo_unk_C78D6-Data_Index
	dc.w LnkTo_unk_C78DE-Data_Index
	dc.w LnkTo_unk_C78E6-Data_Index
	dc.w LnkTo_unk_C78EE-Data_Index
	dc.w LnkTo_unk_C78F6-Data_Index
	dc.w LnkTo_unk_C78FE-Data_Index
	dc.w LnkTo_unk_C7906-Data_Index
	dc.w LnkTo_unk_C790E-Data_Index
	dc.w LnkTo_unk_C7916-Data_Index
	dc.w LnkTo_unk_C791E-Data_Index
	dc.w LnkTo_unk_C7926-Data_Index
	dc.w LnkTo_unk_C792E-Data_Index
	dc.w LnkTo_unk_C7936-Data_Index
	dc.w LnkTo_unk_C793E-Data_Index
	dc.w LnkTo_unk_C7946-Data_Index
	dc.w LnkTo_unk_C794E-Data_Index
	dc.w LnkTo_unk_C7956-Data_Index
	dc.w LnkTo_unk_C795E-Data_Index
; ---------------------------------------------------------------------------

loc_3304A:
	add.w	d6,d6
	move.b	byte_33080(pc,d6.w),d7
	move.b	d7,x_direction(a3)
	move.b	byte_33081(pc,d6.w),d6
	add.w	d2,d6
	subq.w	#1,d3
	bne.w	loc_33072
	move.w	#5,d3
	tst.w	d2
	beq.w	loc_33070
	moveq	#0,d2
	bra.w	loc_33072
; ---------------------------------------------------------------------------

loc_33070:
	moveq	#1,d2

loc_33072:
	ext.w	d6
	add.w	d6,d6
	move.w	off_33026(pc,d6.w),d6
	move.w	d6,addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------
byte_33080:	dc.b 0
byte_33081:	dc.b 8
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b $FF
	dc.b   2
	dc.b $FF
	dc.b   4
	dc.b $FF
	dc.b   6
	dc.b $FF
	dc.b   8
	dc.b $FF
	dc.b   8
	dc.b $FF
	dc.b  $A
	dc.b $FF
	dc.b  $C
	dc.b $FF
	dc.b  $E
	dc.b $FF
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b  $E
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b   8
;stru_330A8: 
	include "ingame/anim/enemy/Fireball.asm"
; ---------------------------------------------------------------------------

loc_330D0:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#0,priority(a3)
	move.w	#$19,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.w	#$96,d3
	move.b	$44(a5),x_direction(a3)
	move.w	$46(a5),x_pos(a3)
	move.w	$48(a5),y_pos(a3)
	move.l	#stru_330C2,d7
	jsr	(j_Init_Animation).w

loc_33110:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_33120
	subq.w	#1,d3
	bne.s	loc_33110

loc_33120:
	subq.w	#1,(Number_of_Fire_Trails).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_33128:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),d7
	add.w	$26(a0),d7
	add.w	$26(a0),d7
	move.w	d7,x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	addi.w	#$F,y_pos(a3)
	andi.w	#$FFF0,y_pos(a3)
	move.l	#stru_330A8,d7
	jsr	(j_Init_Animation).w
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#$19,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.w	#$96,d3
	moveq	#8,d7
	move.w	#$3E7,d6
	bsr.w	loc_33286
	bclr	#$F,d6
	bne.w	loc_331CA
	andi.w	#$7000,d6
	cmpi.w	#$6000,d6
	bne.w	loc_331CA
	andi.w	#$7000,d5
	cmpi.w	#$6000,d5
	bne.w	loc_331CA
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bne.w	loc_331CA

loc_331BA:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_331CA
	subq.w	#1,d3
	bne.s	loc_331BA

loc_331CA:
	subq.w	#1,(Number_of_Fire_Trails).w
	jmp	(j_Delete_CurrentObject).w