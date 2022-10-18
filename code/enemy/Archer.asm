stru_33FC2:
	anim_frame	  1,   5, LnkTo_unk_C81B8-Data_Index
	anim_frame	  1,   5, LnkTo_unk_C81F0-Data_Index
	anim_frame	  1,   5, LnkTo_unk_C81C8-Data_Index
	anim_frame	  1, $23, LnkTo_unk_C81D0-Data_Index
	dc.b   0
	dc.b   0

arrow_accuracy:
	dc.w $1E	; 1 HP
	dc.w $14	; 2 HP
	dc.w  $A	; 3 HP

;loc_33FDA:
Enemy07_Archer_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	jsr	loc_32188(pc)
	exg	a1,a3
	move.l	a3,$36(a5)
	move.l	a1,$3A(a5)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	move.w	2(a0),d7	; select number of hitpoints
	add.w	d7,d7	; create offset for table arrow_accuracy
	move.w	arrow_accuracy(pc,d7.w),d7 ; this table is inside "kid.asm"
	move.w	d7,$4A(a5)
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	move.b	#0,priority(a3)
	move.w	#objid_Archer,d0 ; loaded sprite id
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	sf	has_level_collision(a3)
	move.w	#(LnkTo_unk_C8188-Data_Index),addroffset_sprite(a3)
	move.w	#$C8,d3
	st	$13(a1)
	move.b	#0,$10(a1)
	exg	a1,a3
	move.w	#objid_Archer,d0 ; loaded sprite id (enemy holding arrow)
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	exg	a1,a3
	move.w	#2,8(a3)
	move.w	#$100,$A(a3)
	move.l	($FFFFF86A).w,4(a3)
	move.l	a3,($FFFFF86A).w
	st	$3D(a1)
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$FF,d7
	move.b	(Camera_X_pos).w,d6
	eor.b	d6,d7
	move.w	d7,-(sp)	; initial time to hibernate
	jsr	(j_Hibernate_Object).w	; this causes the bug where the archer has delayed death.

loc_3408C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	Enemy07_Archer_CheckKilled
	sf	x_direction(a3)
	lea	Shooting_Vertical(pc),a2
	subi.w	#$1E,y_pos(a3)
	bsr.w	loc_34458
	addi.w	#$1E,y_pos(a3)
	cmpi.w	#6,d6
	bge.w	loc_340C0
	st	x_direction(a3)
	bra.w	loc_3419A
; ---------------------------------------------------------------------------

loc_340C0:
	cmpi.w	#$D,d6
	ble.w	loc_3419A
	lea	Shooting_Horizontal(pc),a2
	cmpi.w	#$14,d6
	ble.w	loc_3419A
	st	x_direction(a3)
	bra.w	loc_3419A
; ---------------------------------------------------------------------------
Shooting_Horizontal:
	dc.w    $D ; shooting angle left facing
	dc.w     0 ; shooting angle right facing

	dc.w   $64 ; idle time (see d3 at loc_34248)
	dc.w  LnkTo_unk_C81A8-Data_Index ; standing normal enemy sprite
	dc.w $FFF2 ; arrow x position spawn offset
	dc.w $FFEF ; arrow y position spawn offset
	dc.w     6
	dc.w  LnkTo_unk_C81B0-Data_Index
	dc.w $FFF5
	dc.w $FFEF
	dc.w    $C
	dc.w  LnkTo_unk_C81B8-Data_Index
	dc.w $FFF8
	dc.w $FFEF
	dc.w     0
	dc.w  LnkTo_unk_C81C0-Data_Index
	dc.w $FFF2
	dc.w $FFEF
	dc.w $FFFF

Shooting_Vertical:
	dc.w    $A ; shooting angle left facing
	dc.w     3 ; shooting angle right facing

	dc.w   $64 ; idle time (see d3 at loc_34248)
	dc.w  LnkTo_unk_C8188-Data_Index ; standing normal enemy sprite
	dc.w $FFF2 ; arrow x position spawn offset
	dc.w $FFE2 ; arrow y position spawn offset
	dc.w     6
	dc.w  LnkTo_unk_C8190-Data_Index
	dc.w $FFF5
	dc.w $FFE5
	dc.w    $C
	dc.w  LnkTo_unk_C8198-Data_Index
	dc.w $FFF8
	dc.w $FFE8
	dc.w     0
	dc.w  LnkTo_unk_C81A0-Data_Index
	dc.w $FFF2
	dc.w $FFE2
	dc.w $FFFF
; ---------------------------------------------------------------------------
;loc_34128:
Enemy07_Archer_CheckKilled:
	move.w	collision_type(a3),d7
	beq.w	return_34148
	bmi.w	loc_3414A
	clr.w	collision_type(a3)
	cmpi.w	#colid_kidabove,d7
	beq.w	loc_3414A
	cmpi.w	#colid_hurt,d7
	beq.w	loc_3414A

return_34148:
	rts
; ---------------------------------------------------------------------------

loc_3414A:
	st	has_kid_collision(a3)
	move.l	#stru_33FC2,d7
	jsr	(j_Init_Animation).w
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	#$FFFC0000,$2A(a4)	; this causes the bug where the kid bounces up when killing the archer
	jsr	(j_Hibernate_UntilAnimFinished).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_34188
	btst	#6,d0
	beq.s	loc_34196
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_34196
; ---------------------------------------------------------------------------

loc_34188:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_34196:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3419A:
	move.l	a2,$44(a5)
	move.w	(a2)+,d6
	tst.b	x_direction(a3)
	beq.w	loc_341AA
	move.w	(a2),d6

loc_341AA:
	addq.w	#2,a2
	exg	a1,a3
	bsr.w	Enemy07_ArcherArrow_AngleToSpeedAndAnim
	exg	a1,a3
	move.b	x_direction(a3),$16(a1)
	not.b	$16(a1)

loc_341BE:
	move.w	(a2)+,d3
	bmi.w	loc_3408C
	bne.w	loc_34222
	move.w	(a2)+,addroffset_sprite(a3)
	move.w	#$14,d3
	move.w	#0,$22(a1)
	move.w	#3,d7
	addq.w	#1,(Number_of_Arrows).w
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Enemy07_ArcherArrow_Init,4(a0)
	move.w	$4A(a5),$4A(a0)
	move.w	(a2)+,$44(a0)
	move.w	(a2)+,$46(a0)
	move.l	$44(a5),a4
	move.w	(a4)+,$48(a0)
	tst.b	x_direction(a3)
	beq.w	loc_34216
	neg.w	d7
	neg.w	$44(a0)
	move.w	(a4)+,$48(a0)

loc_34216:
	add.w	d7,$1A(a1)
	add.w	d7,$1E(a1)
	bra.w	loc_34248
; ---------------------------------------------------------------------------

loc_34222:
	move.w	(a2)+,addroffset_sprite(a3)
	move.w	(a2)+,d6
	move.w	(a2)+,d7
	tst.b	x_direction(a3)
	beq.w	loc_34234
	neg.w	d6

loc_34234:
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	add.w	d6,$1A(a1)
	add.w	d7,$1E(a1)

loc_34248:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	Enemy07_Archer_CheckKilled
	dbf	d3,loc_34248
	cmpi.w	#2,(Number_of_Arrows).w
	bge.w	loc_3408C
	bra.w	loc_341BE
; ---------------------------------------------------------------------------
;loc_34266:
Enemy07_ArcherArrow_Init:
	move.l	d0,-(sp)
	moveq	#sfx_Archer_shoots,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	move.w	$44(a5),d6
	move.w	$46(a5),d7
	add.w	d6,x_pos(a3)
	add.w	d7,y_pos(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#objid_Archer,d0 ; loaded sprite id (arrow)
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	st	has_level_collision(a3)
	move.w	#(LnkTo_unk_C81F8-Data_Index),addroffset_sprite(a3)
	move.w	$4A(a5),d3
	move.w	$48(a5),d6
	move.w	d6,d2
	bsr.w	Enemy07_ArcherArrow_AngleToSpeedAndAnim

loc_342D6:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_34336
	tst.w	collision_type(a3)
	bne.w	loc_34336
	subq.w	#1,d3
	bne.s	loc_342D6
	move.w	$4A(a5),d3
	bsr.w	loc_34458
	move.w	#-$E,d5
	cmp.w	d2,d6
	beq.w	loc_3432E
	ble.w	loc_34308
	move.w	#$E,d5

loc_34308:
	sub.w	d2,d6
	cmp.w	d5,d6
	bge.w	loc_34320
	addq.w	#1,d2
	cmpi.w	#$1B,d2
	ble.w	loc_3432E
	moveq	#0,d2
	bra.w	loc_3432E
; ---------------------------------------------------------------------------

loc_34320:
	subq.w	#1,d2
	bpl.w	loc_3432E
	beq.w	loc_3432E
	move.w	#$1B,d2

loc_3432E:
	move.w	d2,d6
	bsr.w	Enemy07_ArcherArrow_AngleToSpeedAndAnim
	bra.s	loc_342D6
; ---------------------------------------------------------------------------

loc_34336:
	subq.w	#1,(Number_of_Arrows).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
;loc_3433E:
Enemy07_ArcherArrow_AngleToSpeedAndAnim:
	asl.w	#2,d6	; angle of the arrow
	move.b	byte_3437A(pc,d6.w),d7
	move.b	d7,x_direction(a3)
	moveq	#0,d7
	move.b	byte_3437A+2(pc,d6.w),d7
	ext.w	d7
	swap	d7
	asr.l	#4,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.b	byte_3437A+3(pc,d6.w),d7
	ext.w	d7
	swap	d7
	asr.l	#4,d7
	move.l	d7,y_vel(a3)
	move.b	byte_3437A+1(pc,d6.w),d6
	ext.w	d6
	add.w	d6,d6
	move.w	off_343EA(pc,d6.w),d6
	move.w	d6,addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------
byte_3437A: ; x direction, sprite ID, x velocity, y velocity
	dc.b   0,   0, $20,   0
	dc.b   0,   1, $20, $F8
	dc.b   0,   2, $1C, $F0
	dc.b   0,   3, $18, $E8
	dc.b   0,   4, $10, $E4
	dc.b   0,   5,   8, $E0
	dc.b   0,   6,   0, $E0
	dc.b $FF,   6,   0, $E0
	dc.b $FF,   5, $F8, $E0
	dc.b $FF,   4, $F0, $E4
	dc.b $FF,   3, $E8, $E8
	dc.b $FF,   2, $E4, $F0
	dc.b $FF,   1, $E0, $F8
	dc.b $FF,   0, $E0,   0
	dc.b $FF,   0, $E0,   0
	dc.b $FF,   7, $E0,   8
	dc.b $FF,   8, $E4, $10
	dc.b $FF,   9, $E8, $18
	dc.b $FF,  $A, $F0, $1C
	dc.b $FF,  $B, $F8, $20
	dc.b $FF,  $C,   0, $20
	dc.b   0,  $C,   0, $20
	dc.b   0,  $B,   8, $20
	dc.b   0,  $A, $10, $1C
	dc.b   0,   9, $18, $18
	dc.b   0,   8, $1C, $10
	dc.b   0,   7, $20,   8
	dc.b   0,   0, $20,   0
off_343EA:	; sprite IDs depending on angle.
	dc.w LnkTo_unk_C81F8-Data_Index
	dc.w LnkTo_unk_C8200-Data_Index
	dc.w LnkTo_unk_C8208-Data_Index
	dc.w LnkTo_unk_C8210-Data_Index
	dc.w LnkTo_unk_C8218-Data_Index
	dc.w LnkTo_unk_C8220-Data_Index
	dc.w LnkTo_unk_C8228-Data_Index
	dc.w LnkTo_unk_C8230-Data_Index
	dc.w LnkTo_unk_C8238-Data_Index
	dc.w LnkTo_unk_C8240-Data_Index
	dc.w LnkTo_unk_C8248-Data_Index
	dc.w LnkTo_unk_C8250-Data_Index
	dc.w LnkTo_unk_C8258-Data_Index
unk_34404:
	dc.b   0,  1,  1,  2,  2,  2,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4
	dc.b   4,  4,  4,  4,  4,  4,  4,  4,  5,  5,  5,  5,  5,  5,  5,  5
	dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
	dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
	dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
	dc.b   5,  5,  5,  5
; ---------------------------------------------------------------------------

loc_34458:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	move.w	y_pos(a4),d7
	subi.w	#$10,d7
	sub.w	y_pos(a3),d7
	move.w	d7,d4
	lea	unk_34404(pc),a4
	tst.w	d6
	beq.w	loc_34530
	bmi.w	loc_34492
	moveq	#3,d5
	tst.w	d7
	bpl.w	loc_3450A
	neg.w	d7
	move.w	#0,d5
	bra.w	loc_344C6
; ---------------------------------------------------------------------------

loc_34492:
	neg.w	d6
	moveq	#2,d5
	tst.w	d7
	bpl.w	loc_344E6
	neg.w	d7
	moveq	#1,d5
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	move.w	#6,d6
	cmpi.w	#$3F,d7
	bge.w	loc_34546
	move.b	(a4,d7.w),d6
	ext.w	d6
	neg.w	d6
	addi.w	#$D,d6
	bra.w	loc_3452C
; ---------------------------------------------------------------------------

loc_344C6:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	move.w	#6,d6
	cmpi.w	#$3F,d7
	bge.w	loc_34546
	move.b	(a4,d7.w),d6
	ext.w	d6
	bra.w	loc_3452C
; ---------------------------------------------------------------------------

loc_344E6:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	move.w	#6,d6
	cmpi.w	#$3F,d7
	bge.w	loc_34546
	move.b	(a4,d7.w),d6
	ext.w	d6
	addi.w	#$E,d6
	bra.w	loc_3452C
; ---------------------------------------------------------------------------

loc_3450A:
	asl.w	#3,d7
	andi.l	#$FFFF,d7
	divs.w	d6,d7
	move.w	#6,d6
	cmpi.w	#$3F,d7
	bge.w	loc_34546
	move.b	(a4,d7.w),d6
	ext.w	d6
	neg.w	d6
	addi.w	#$1B,d6

loc_3452C:
	move.w	d5,d7

return_3452E:
	rts
; ---------------------------------------------------------------------------

loc_34530:
	move.w	#6,d6
	move.w	#0,d7
	tst.w	d7
	bmi.s	return_3452E
	move.w	#$15,d6
	move.w	#3,d7
	rts
; ---------------------------------------------------------------------------

loc_34546:
	move.w	#6,d6
	tst.w	d4
	bmi.s	loc_3452C
	move.w	#$15,d6
	bra.s	loc_3452C