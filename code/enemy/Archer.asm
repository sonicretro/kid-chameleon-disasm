;loc_33FDA:
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
	move.w	2(a0),d7	; hitpoints
	add.w	d7,d7
	move.w	word_33FD4(pc,d7.w),d7
	move.w	d7,$4A(a5)
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	move.b	#0,priority(a3)
	move.w	#7,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	sf	has_level_collision(a3)
	move.w	#(LnkTo_unk_C8188-Data_Index),addroffset_sprite(a3)
	move.w	#$C8,d3
	st	$13(a1)
	move.b	#0,$10(a1)
	exg	a1,a3
	move.w	#7,d0
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
	move.w	d7,-(sp)
	jsr	(j_Hibernate_Object).w

loc_3408C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_34128
	sf	x_direction(a3)
	lea	unk_34102(pc),a2
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
	lea	unk_340DC(pc),a2
	cmpi.w	#$14,d6
	ble.w	loc_3419A
	st	x_direction(a3)
	bra.w	loc_3419A
; ---------------------------------------------------------------------------
unk_340DC:	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $64 ; d
	dc.b  $C
	dc.b $90 ; 
	dc.b $FF
	dc.b $F2 ; ò
	dc.b $FF
	dc.b $EF ; ï
	dc.b   0
	dc.b   6
	dc.b  $C
	dc.b $94 ; ”
	dc.b $FF
	dc.b $F5 ; õ
	dc.b $FF
	dc.b $EF ; ï
	dc.b   0
	dc.b  $C
	dc.b  $C
	dc.b $98 ; ˜
	dc.b $FF
	dc.b $F8 ; ø
	dc.b $FF
	dc.b $EF ; ï
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b $9C ; œ
	dc.b $FF
	dc.b $F2 ; ò
	dc.b $FF
	dc.b $EF ; ï
	dc.b $FF
	dc.b $FF
unk_34102:	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b $64 ; d
	dc.b  $C
	dc.b $80 ; €
	dc.b $FF
	dc.b $F2 ; ò
	dc.b $FF
	dc.b $E2 ; â
	dc.b   0
	dc.b   6
	dc.b  $C
	dc.b $84 ; „
	dc.b $FF
	dc.b $F5 ; õ
	dc.b $FF
	dc.b $E5 ; å
	dc.b   0
	dc.b  $C
	dc.b  $C
	dc.b $88 ; ˆ
	dc.b $FF
	dc.b $F8 ; ø
	dc.b $FF
	dc.b $E8 ; è
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b $8C ; Œ
	dc.b $FF
	dc.b $F2 ; ò
	dc.b $FF
	dc.b $E2 ; â
	dc.b $FF
	dc.b $FF
; ---------------------------------------------------------------------------

loc_34128:
	move.w	collision_type(a3),d7
	beq.w	return_34148
	bmi.w	loc_3414A
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d7
	beq.w	loc_3414A
	cmpi.w	#$1C,d7
	beq.w	loc_3414A

return_34148:
	rts
; ---------------------------------------------------------------------------

loc_3414A:
	st	has_kid_collision(a3)
	move.l	#stru_33FC2,d7
	jsr	(j_Init_Animation).w
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	#$FFFC0000,$2A(a4)
	jsr	(j_sub_105E).w
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
	bsr.w	loc_3433E
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
	addq.w	#1,($FFFFFB46).w
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_34266,4(a0)
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
	bsr.w	loc_34128
	dbf	d3,loc_34248
	cmpi.w	#2,($FFFFFB46).w
	bge.w	loc_3408C
	bra.w	loc_341BE
; ---------------------------------------------------------------------------

loc_34266:
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
	move.w	#7,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	st	has_level_collision(a3)
	move.w	#(LnkTo_unk_C81F8-Data_Index),addroffset_sprite(a3)
	move.w	$4A(a5),d3
	move.w	$48(a5),d6
	move.w	d6,d2
	bsr.w	loc_3433E

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
	bsr.w	loc_3433E
	bra.s	loc_342D6
; ---------------------------------------------------------------------------

loc_34336:
	subq.w	#1,($FFFFFB46).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3433E:
	asl.w	#2,d6
	move.b	byte_3437A(pc,d6.w),d7
	move.b	d7,x_direction(a3)
	moveq	#0,d7
	move.b	byte_3437C(pc,d6.w),d7
	ext.w	d7
	swap	d7
	asr.l	#4,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.b	byte_3437D(pc,d6.w),d7
	ext.w	d7
	swap	d7
	asr.l	#4,d7
	move.l	d7,y_vel(a3)
	move.b	byte_3437B(pc,d6.w),d6
	ext.w	d6
	add.w	d6,d6
	move.w	off_343EA(pc,d6.w),d6
	move.w	d6,addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------
byte_3437A:	dc.b 0
byte_3437B:	dc.b 0
byte_3437C:	dc.b $20
byte_3437D:	dc.b 0
	dc.b   0
	dc.b   1
	dc.b $20
	dc.b $F8 ; ø
	dc.b   0
	dc.b   2
	dc.b $1C
	dc.b $F0 ; ð
	dc.b   0
	dc.b   3
	dc.b $18
	dc.b $E8 ; è
	dc.b   0
	dc.b   4
	dc.b $10
	dc.b $E4 ; ä
	dc.b   0
	dc.b   5
	dc.b   8
	dc.b $E0 ; à
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b $E0 ; à
	dc.b $FF
	dc.b   6
	dc.b   0
	dc.b $E0 ; à
	dc.b $FF
	dc.b   5
	dc.b $F8 ; ø
	dc.b $E0 ; à
	dc.b $FF
	dc.b   4
	dc.b $F0 ; ð
	dc.b $E4 ; ä
	dc.b $FF
	dc.b   3
	dc.b $E8 ; è
	dc.b $E8 ; è
	dc.b $FF
	dc.b   2
	dc.b $E4 ; ä
	dc.b $F0 ; ð
	dc.b $FF
	dc.b   1
	dc.b $E0 ; à
	dc.b $F8 ; ø
	dc.b $FF
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $FF
	dc.b   7
	dc.b $E0 ; à
	dc.b   8
	dc.b $FF
	dc.b   8
	dc.b $E4 ; ä
	dc.b $10
	dc.b $FF
	dc.b   9
	dc.b $E8 ; è
	dc.b $18
	dc.b $FF
	dc.b  $A
	dc.b $F0 ; ð
	dc.b $1C
	dc.b $FF
	dc.b  $B
	dc.b $F8 ; ø
	dc.b $20
	dc.b $FF
	dc.b  $C
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b  $B
	dc.b   8
	dc.b $20
	dc.b   0
	dc.b  $A
	dc.b $10
	dc.b $1C
	dc.b   0
	dc.b   9
	dc.b $18
	dc.b $18
	dc.b   0
	dc.b   8
	dc.b $1C
	dc.b $10
	dc.b   0
	dc.b   7
	dc.b $20
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
off_343EA:	dc.w LnkTo_unk_C81F8-Data_Index
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
unk_34404:	dc.b   0
	dc.b   1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
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