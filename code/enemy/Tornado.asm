unk_3588C: ; also part of tornado
	dc.b   0
	dc.b $3C ; <
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $28 ; (
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $1E
	dc.b $FF
	dc.b $FF

;loc_35898:
Enemy18_Tornado_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	move.b	#0,priority(a3)
	move.w	#$18,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.w	2(a0),d7
	add.w	d7,d7
	add.w	d7,d7
	lea	unk_3588C(pc,d7.w),a4
	move.w	(a4)+,$48(a5)
	move.b	(a4)+,$46(a5)
	move.b	(a4)+,$47(a5)
	move.l	#stru_35B10,d7
	jsr	(j_Init_Animation).w
	lea	unk_35A0C(pc),a0
	bsr.w	loc_35326
	bsr.w	loc_3592E
	move.w	$48(a5),$44(a5)

loc_35908:
	bsr.w	Enemy_HandleAcceleration ; this code is defined in "code/enemy/UFO.asm"
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_35948
	subq.w	#1,$44(a5)
	bne.s	loc_35908
	bsr.w	loc_359F2
	bsr.w	loc_3592E
	move.w	$48(a5),$44(a5)
	bra.s	loc_35908
; ---------------------------------------------------------------------------

loc_3592E:
	tst.b	$46(a5)
	beq.w	loc_3593A
	add.l	d0,d0
	add.l	d2,d2

loc_3593A:
	tst.b	$47(a5)
	beq.w	return_35946
	add.l	d1,d1
	add.l	d3,d3

return_35946:
	rts
; ---------------------------------------------------------------------------

loc_35948:
	lea	off_35950(pc),a4
	bra.w	loc_35056
; ---------------------------------------------------------------------------
off_35950:
	dc.l Enemy0F_UFO_BounceWall
	dc.l Enemy0F_UFO_BounceWall
	dc.l Enemy0F_UFO_BounceFloorCeil
	dc.l Enemy0F_UFO_BounceFloorCeil
	dc.l Enemy0F_UFO_BounceUpSlope
	dc.l Enemy0F_UFO_BounceDownSlope
	dc.l loc_359B2
	dc.l loc_3597E
	dc.l loc_35984
	dc.l return_3597C
	dc.l loc_359B2
; ---------------------------------------------------------------------------

return_3597C:

	rts
; ---------------------------------------------------------------------------

loc_3597E:
	moveq	#2,d7
	bra.w	loc_35986
; ---------------------------------------------------------------------------

loc_35984:
	moveq	#-2,d7

loc_35986:
	tst.b	(Cyclone_flying).w
	beq.s	return_3597C
	move.l	(Addr_GfxObject_Kid).w,a4
	swap	d7
	move.l	d7,$26(a4)
	neg.l	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	move.w	y_pos(a4),d7
	cmp.w	y_pos(a3),d7
	blt.w	loc_359B2
	move.w	#$28,$38(a4)
	rts
; ---------------------------------------------------------------------------

loc_359B2:

	move.l	#stru_35B1E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_359E0
	btst	#6,d0
	beq.s	loc_359EE
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_359EE
; ---------------------------------------------------------------------------

loc_359E0:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_359EE:
	jsr	(j_Delete_CurrentObject).w

loc_359F2:
	move.l	(a0),d7
	cmpi.l	#1,d7
	bne.w	loc_35A02
	lea	unk_35A0C(pc),a0

loc_35A02:
	move.l	a0,a4
	addi.w	#$10,a0
	bra.w	loc_35444

; ---------------------------------------------------------------------------
unk_35A0C:	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
; ---------------------------------------------------------------------------
;stru_35B10: 
	include "ingame/anim/enemy/Tornado.asm"
