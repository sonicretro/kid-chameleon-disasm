dword_35B38:
	dc.l $FFFFD000
	dc.l $FFFFB000
	dc.l $FFFF9000

;loc_35B44:
Enemy0E_Cloud_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	clr.l	y_vel(a3)
	move.w	2(a0),d7
	asl.w	#2,d7
	move.l	dword_35B38(pc,d7.w),x_vel(a3)
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#$E,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	has_level_collision(a3)
	sf	$19(a3)
	moveq	#1,d3
	moveq	#5,d2
	moveq	#0,d1
	st	$44(a5)
	sf	$45(a5)
	move.l	#stru_35EA0,d7
	jsr	(j_Init_Animation).w

loc_35BAC:
	lea	(unk_35BC4).l,a0

loc_35BB2:
	lea	off_35BCE(pc),a1
	move.w	(a0)+,d0
	bmi.s	loc_35BAC
	clr.l	d7
	move.b	d0,d7
	move.l	(a1,d7.w),a1
	jmp	(a1)
; ---------------------------------------------------------------------------
unk_35BC4:	dc.b $78 ; x
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b $FF
	dc.b $FF
off_35BCE:	dc.l loc_35C54
	dc.l loc_35C72
	dc.l loc_35C7A
	dc.l loc_35C82
; ---------------------------------------------------------------------------

loc_35BDE:
	move.w	collision_type(a3),d6
	beq.s	return_35C0C
	bmi.w	loc_35C0E
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d6
	beq.w	loc_35C0E
	cmpi.w	#$1C,d6
	beq.w	loc_35C0E
	bge.w	return_35C0C
	move.w	#$3C,d3
	neg.l	x_vel(a3)
	not.b	x_direction(a3)

return_35C0C:
	rts
; ---------------------------------------------------------------------------

loc_35C0E:
	addq.w	#4,sp
	clr.l	x_vel(a3)
	move.l	#stru_35EBA,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_35C42
	btst	#6,d0
	beq.s	loc_35C50
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_35C50
; ---------------------------------------------------------------------------

loc_35C42:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_35C50:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_35C54:
	lsr.w	#8,d0

loc_35C56:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_35BDE
	bsr.w	loc_35CA2
	bsr.w	loc_35CD8
	dbf	d0,loc_35C56
	bra.w	loc_35BB2
; ---------------------------------------------------------------------------

loc_35C72:
	st	$44(a5)
	bra.w	loc_35BB2
; ---------------------------------------------------------------------------

loc_35C7A:
	sf	$44(a5)
	bra.w	loc_35BB2
; ---------------------------------------------------------------------------

loc_35C82:
	move.l	#stru_35EC8,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_35BAC
; ---------------------------------------------------------------------------
off_35C94:
	dc.w LnkTo_unk_C787E-Data_Index
	dc.w LnkTo_unk_C7886-Data_Index
	dc.w LnkTo_unk_C788E-Data_Index
	dc.w LnkTo_unk_C7896-Data_Index
	dc.w LnkTo_unk_C788E-Data_Index
	dc.w LnkTo_unk_C7886-Data_Index
	dc.w $FFFF
; ---------------------------------------------------------------------------

loc_35CA2:
	tst.b	$44(a5)
	beq.s	return_35CD6
	tst.b	$45(a5)
	bne.w	return_35CD6
	subq.w	#1,d2
	bne.s	return_35CD6
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$2F,d7
	cmpi.w	#$A,d7
	bgt.s	loc_35CD2
	bclr	#0,d7
	lea	off_35C94(pc),a4
	move.w	(a4,d7.w),d7
	move.w	d7,addroffset_sprite(a3)

loc_35CD2:
	move.w	#5,d2

return_35CD6:
	rts
; ---------------------------------------------------------------------------

loc_35CD8:
	tst.b	$45(a5)
	bne.w	loc_35DAE
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	y_pos(a4),d7
	sub.w	y_pos(a3),d7
	bmi.w	loc_35D40
	tst.b	x_direction(a3)
	bne.s	loc_35D1E
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	bpl.s	loc_35D40
	neg.w	d6
	cmp.w	d6,d7
	bgt.s	loc_35D40
	subi.w	#$10,d6
	cmp.w	d6,d7
	blt.s	loc_35D40
	move.w	#3,d1
	neg.w	d1
	swap	d1
	move.w	#3,d1
	bra.w	loc_35D9E
; ---------------------------------------------------------------------------

loc_35D1E:
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	bmi.s	loc_35D40
	cmp.w	d6,d7
	bgt.s	loc_35D40
	subi.w	#$10,d6
	cmp.w	d6,d7
	blt.s	loc_35D40
	move.w	#3,d1
	swap	d1
	move.w	#3,d1
	bra.s	loc_35D9E
; ---------------------------------------------------------------------------

loc_35D40:
	tst.w	d7
	bmi.w	loc_35D62
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	cmpi.w	#$10,d6
	bgt.s	loc_35D62
	cmpi.w	#$FFF0,d6
	ble.s	loc_35D62
	moveq	#0,d1
	move.w	#6,d1
	bra.s	loc_35D9E
; ---------------------------------------------------------------------------

loc_35D62:
	cmpi.w	#$FFE8,d7
	blt.w	return_35DAC
	cmpi.w	#$18,d7
	bgt.w	return_35DAC
	tst.b	x_direction(a3)
	bne.s	loc_35D8C
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	bpl.s	return_35DAC
	moveq	#0,d1
	move.w	#$FFFA,d1
	swap	d1
	bra.s	loc_35D9E
; ---------------------------------------------------------------------------

loc_35D8C:
	move.w	x_pos(a4),d6
	sub.w	x_pos(a3),d6
	bmi.s	return_35DAC
	moveq	#0,d1
	move.w	#6,d1
	swap	d1

loc_35D9E:
	move.l	#stru_35EC8,d7
	jsr	(j_Init_Animation).w
	st	$45(a5)

return_35DAC:
	rts
; ---------------------------------------------------------------------------

loc_35DAE:
	tst.b	$18(a3)
	bne.w	loc_35DB8
	rts
; ---------------------------------------------------------------------------

loc_35DB8:
	move.l	a0,-(sp)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_35DF0,4(a0)
	move.w	d1,$46(a0)
	swap	d1
	move.w	d1,$44(a0)
	move.b	x_direction(a3),d7
	not.b	d7
	move.b	d7,$48(a0)
	move.l	(sp)+,a0
	move.l	#stru_35EA0,d7
	jsr	(j_Init_Animation).w
	sf	$45(a5)
	rts
; ---------------------------------------------------------------------------

loc_35DF0:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	subi.w	#$B,y_pos(a3)
	move.b	$48(a5),x_direction(a3)
	move.w	$46(a5),y_vel(a3)
	move.w	$44(a5),x_vel(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	#2,palette_line(a3)
	move.b	#0,priority(a3)
	move.w	#$409,vram_tile(a3)
	move.b	#0,priority(a3)
	move.w	#$E,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	move.w	#(LnkTo_unk_C786E-Data_Index),addroffset_sprite(a3)
	tst.w	x_vel(a3)
	beq.s	loc_35E8A
	move.w	#(LnkTo_unk_C7866-Data_Index),addroffset_sprite(a3)
	tst.w	y_vel(a3)
	beq.s	loc_35E8A
	move.w	#(LnkTo_unk_C7876-Data_Index),addroffset_sprite(a3)
	addi.w	#4,x_pos(a3)
	tst.b	x_direction(a3)
	beq.s	loc_35E8A
	subi.w	#8,x_pos(a3)

loc_35E8A:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	bne.s	loc_35E9C
	tst.b	$19(a3)
	bne.s	loc_35E9C
	bra.s	loc_35E8A
; ---------------------------------------------------------------------------

loc_35E9C:
	jmp	(j_Delete_CurrentObject).w