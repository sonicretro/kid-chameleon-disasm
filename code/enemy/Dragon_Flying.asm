;loc_34664:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	move.w	6(a0),$44(a5)
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#$C,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	st	has_level_collision(a3)
	move.w	2(a0),d7
	move.w	d7,$46(a5)
	add.w	d7,d7
	add.w	d7,d7
	lea	off_346EE(pc),a4
	add.w	d7,a4
	move.l	(a4),$48(a5)

loc_346C0:
	move.l	$48(a5),a0

loc_346C4:
	move.l	#stru_34600,d7
	jsr	(j_Init_Animation).w
	clr.w	collision_type(a3)
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)

loc_346DA:
	moveq	#0,d1
	lea	off_3471E(pc),a1
	move.w	(a0)+,d0
	bmi.s	loc_346C0
	moveq	#0,d7
	move.b	d0,d7
	move.l	(a1,d7.w),a1
	jmp	(a1)
; ---------------------------------------------------------------------------
off_346EE:	dc.l unk_34710
	dc.l unk_34706
	dc.l unk_346FA
unk_346FA:	dc.b $70 ; p
	dc.b $14
	dc.b $70 ; p
	dc.b $14
	dc.b   0
	dc.b  $C
	dc.b $50 ; P
	dc.b $14
	dc.b   0
	dc.b $18
	dc.b $FF
	dc.b $FF
unk_34706:	dc.b $28 ; (
	dc.b $14
	dc.b $1E
	dc.b $14
	dc.b $32 ; 2
	dc.b $14
	dc.b   0
	dc.b $18
	dc.b $FF
	dc.b $FF
unk_34710:	dc.b $70 ; p
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b $50 ; P
	dc.b   4
	dc.b $32 ; 2
	dc.b   0
	dc.b $78 ; x
	dc.b   4
	dc.b   0
	dc.b $18
	dc.b $FF
	dc.b $FF
off_3471E:	dc.l loc_34804
	dc.l loc_34776
	dc.l loc_34768
	dc.l loc_3473A
	dc.l loc_3487E
	dc.l loc_34774
	dc.l loc_34B44
; ---------------------------------------------------------------------------

loc_3473A:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d7
	cmp.w	x_pos(a4),d7
	blt.w	loc_34758
	sf	x_direction(a3)
	move.l	#$FFFF8000,x_vel(a3)
	bra.s	loc_346DA
; ---------------------------------------------------------------------------

loc_34758:
	st	x_direction(a3)
	move.l	#$8000,x_vel(a3)
	bra.w	loc_346DA
; ---------------------------------------------------------------------------

loc_34768:
	not.b	x_direction(a3)
	neg.l	x_vel(a3)
	bra.w	loc_346DA
; ---------------------------------------------------------------------------

loc_34774:
	moveq	#1,d1

loc_34776:
	lsr.w	#8,d0
	move.l	#$800,x_vel(a3)
	tst.b	x_direction(a3)
	bne.w	loc_3478C
	neg.l	x_vel(a3)

loc_3478C:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	x_vel(a3),d7
	bmi.w	loc_347B2
	addi.l	#$200,d7
	cmpi.l	#$18000,d7
	blt.w	loc_347C8
	move.l	#$18000,d7
	bra.w	loc_347C8
; ---------------------------------------------------------------------------

loc_347B2:
	subi.l	#$200,d7
	cmpi.l	#$FFFE8000,d7
	bgt.w	loc_347C8
	move.l	#$FFFE8000,d7

loc_347C8:
	move.l	d7,x_vel(a3)
	tst.w	d1
	beq.w	loc_347D6
	bsr.w	loc_34836

loc_347D6:
	move.w	collision_type(a3),d6
	beq.s	loc_347FC
	bmi.w	loc_3492C
	cmpi.w	#$2C,d6
	beq.w	loc_3492C
	cmpi.w	#$1C,d6
	beq.w	loc_3492C
	clr.w	collision_type(a3)
	not.b	x_direction(a3)
	neg.l	x_vel(a3)

loc_347FC:
	dbf	d0,loc_3478C
	bra.w	loc_346DA
; ---------------------------------------------------------------------------

loc_34804:
	lsr.w	#8,d0
	clr.l	x_vel(a3)

loc_3480A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	beq.w	loc_3482E
	bmi.w	loc_3492C
	cmpi.w	#$2C,d7
	beq.w	loc_3492C
	cmpi.w	#$1C,d7
	beq.w	loc_3492C
	clr.w	collision_type(a3)

loc_3482E:
	dbf	d0,loc_3480A
	bra.w	loc_346DA
; ---------------------------------------------------------------------------

loc_34836:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	y_pos(a4),d7
	cmp.w	y_pos(a3),d7
	blt.w	return_3487C
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	move.w	d7,d6
	add.w	d7,d7
	add.w	d6,d7
	tst.b	x_direction(a3)
	beq.w	loc_34860
	sub.w	d6,d7
	neg.w	d7

loc_34860:
	add.w	y_pos(a3),d7
	move.w	y_pos(a4),d6
	cmp.w	d7,d6
	bgt.w	return_3487C
	subq.w	#8,d7
	cmp.w	d7,d6
	blt.w	return_3487C
	addq.w	#4,sp
	bra.w	loc_3487E
; ---------------------------------------------------------------------------

return_3487C:
	rts
; ---------------------------------------------------------------------------

loc_3487E:

	lea	unk_34554(pc),a2
	sf	is_animated(a3)
	move.l	y_pos(a3),d0

loc_3488A:
	move.w	(a2)+,d3
	cmpi.w	#$D8F1,d3
	beq.w	loc_346C4
	cmpi.w	#$DD48,d3
	bne.s	loc_348A0
	not.b	x_direction(a3)
	bra.s	loc_3488A
; ---------------------------------------------------------------------------

loc_348A0:
	cmpi.w	#$E19F,d3
	bne.s	loc_348CE
	exg	a0,a1
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_34BAC,4(a0)
	move.w	x_vel(a3),$44(a0)
	move.w	#3,$46(a0)
	move.b	x_direction(a3),$48(a0)
	exg	a0,a1
	bra.s	loc_3488A
; ---------------------------------------------------------------------------

loc_348CE:
	move.b	d3,d2
	ext.w	d2
	move.w	d2,y_vel(a3)
	move.w	d3,d2
	lsr.w	#8,d2
	ext.w	d2
	tst.b	x_direction(a3)
	beq.s	loc_348E4
	neg.w	d2

loc_348E4:
	move.w	d2,x_vel(a3)
	move.w	(a2)+,d3
	clr.l	d2
	move.b	d3,d2
	lsr.w	#8,d3
	lea	off_345F6(pc),a1
	move.w	(a1,d3.w),addroffset_sprite(a3)
	subq.w	#1,d2

loc_348FC:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	beq.w	loc_34924
	bmi.w	loc_3492C
	cmpi.w	#$1C,d7
	beq.w	loc_3492C
	cmpi.w	#$2C,d7
	beq.w	loc_3492C
	move.w	collision_type(a3),d7
	bra.w	loc_349DE
; ---------------------------------------------------------------------------

loc_34924:
	dbf	d2,loc_348FC
	bra.w	loc_3488A
; ---------------------------------------------------------------------------

loc_3492C:
	move.l	#stru_345E4,d7
	jsr	(j_Init_Animation).w
	sf	is_moved(a3)
	clr.w	vram_tile(a3)
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3CD16,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),d7
	addi.w	#$10,d7
	move.w	d7,$46(a0)
	move.b	x_direction(a3),$48(a0)
	move.w	$46(a5),$4A(a0)
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_34998
	btst	#6,d0
	beq.s	loc_349A6
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_349A6
; ---------------------------------------------------------------------------

loc_34998:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_349A6:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
	move.w	y_pos(a3),d7
	cmp.w	$44(a5),d7
	ble.w	loc_349C0
	move.l	#$FFFFC000,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_349C0:
	clr.l	y_vel(a3)
	rts
; ---------------------------------------------------------------------------
off_349C6:	dc.l loc_34A24
	dc.l loc_34A00
	dc.l loc_34A48
	dc.l loc_34A68
	dc.l loc_34A88
	dc.l loc_34ADC
; ---------------------------------------------------------------------------

loc_349DE:
	bmi.w	loc_3492C
	clr.w	collision_type(a3)
	cmpi.w	#$1C,d7
	bge.w	loc_3488A
	subq.w	#4,d7
	move.l	off_349C6(pc,d7.w),a4
	move.l	#stru_34652,d7
	jsr	(j_Init_Animation).w
	jmp	(a4)
; ---------------------------------------------------------------------------

loc_34A00:
	clr.l	y_vel(a3)
	move.w	#2,x_vel(a3)

loc_34A0A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	subi.l	#$1000,x_vel(a3)
	ble.w	loc_34B44
	bra.s	loc_34A0A
; ---------------------------------------------------------------------------

loc_34A24:
	clr.l	y_vel(a3)
	move.w	#$FFFE,x_vel(a3)

loc_34A2E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	addi.l	#$1000,x_vel(a3)
	bge.w	loc_34B44
	bra.s	loc_34A2E
; ---------------------------------------------------------------------------

loc_34A48:
	move.w	#$FFFD,y_vel(a3)

loc_34A4E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	addi.l	#$5000,y_vel(a3)
	bge.w	loc_34B44
	bra.s	loc_34A4E
; ---------------------------------------------------------------------------

loc_34A68:
	move.w	#3,y_vel(a3)

loc_34A6E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	subi.l	#$2000,y_vel(a3)
	ble.w	loc_34B44
	bra.s	loc_34A6E
; ---------------------------------------------------------------------------

loc_34A88:
	bsr.w	loc_34B96
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	has_level_collision(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	d0,x_pos(a3)
	move.l	d1,y_pos(a3)
	st	has_level_collision(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	#stru_34652,d7
	jsr	(j_Init_Animation).w
	move.w	#$FFFE,x_vel(a3)
	move.w	#$FFFE,y_vel(a3)

loc_34AC2:
	addi.l	#$2000,y_vel(a3)
	beq.w	loc_34B44
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	bra.s	loc_34AC2
; ---------------------------------------------------------------------------

loc_34ADC:
	bsr.w	loc_34B96
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	has_level_collision(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	d0,x_pos(a3)
	move.l	d1,y_pos(a3)
	st	has_level_collision(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	#stru_34652,d7
	jsr	(j_Init_Animation).w
	move.w	#2,x_vel(a3)
	move.w	#$FFFE,y_vel(a3)

loc_34B16:
	addi.l	#$2000,y_vel(a3)
	beq.w	loc_34B44
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_34B30
	bra.s	loc_34B16
; ---------------------------------------------------------------------------

loc_34B30:
	cmpi.w	#$2C,d7
	beq.w	loc_3492C
	cmpi.w	#$1C,d7
	beq.w	loc_3492C
	bra.w	loc_346C4
; ---------------------------------------------------------------------------

loc_34B44:
	clr.l	x_vel(a3)
	move.l	$44(a5),d0

loc_34B4C:
	move.l	y_pos(a3),d7
	cmp.l	d0,d7
	ble.w	loc_346C4
	move.l	y_vel(a3),d7
	subi.l	#$400,d7
	cmpi.l	#$FFFF1000,d7
	bge.w	loc_34B70
	move.l	#$FFFF8000,d7

loc_34B70:
	move.l	d7,y_vel(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	beq.s	loc_34B4C
	bmi.w	loc_3492C
	cmpi.w	#$2C,d7
	beq.w	loc_3492C
	cmpi.w	#$1C,d7
	beq.w	loc_3492C
	bra.w	loc_346C4
; ---------------------------------------------------------------------------

loc_34B96:
	move.l	x_vel(a3),d0
	neg.l	d0
	move.l	y_vel(a3),d1
	neg.l	d1
	add.l	x_pos(a3),d0
	add.l	y_pos(a3),d1
	rts
; ---------------------------------------------------------------------------

loc_34BAC:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	addi.w	#$A,y_pos(a3)
	move.w	#$FFF6,d0
	moveq	#-1,d1
	move.b	$48(a5),x_direction(a3)
	tst.b	x_direction(a3)
	beq.s	loc_34BE6
	neg.w	d0
	neg.w	d1

loc_34BE6:
	add.w	d0,x_pos(a3)
	move.w	d1,x_vel(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	#0,priority(a3)
	move.w	#$C,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	move.w	$46(a5),y_vel(a3)
	move.w	$44(a5),x_vel(a3)
	move.w	#(LnkTo_unk_C75CE-Data_Index),addroffset_sprite(a3)
	move.w	#6,d0

loc_34C26:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	bne.s	loc_34C4A
	dbf	d0,loc_34C26
	move.w	#(LnkTo_unk_C75D6-Data_Index),addroffset_sprite(a3)

loc_34C3A:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	bne.s	loc_34C4A
	tst.b	$19(a3)
	beq.s	loc_34C3A

loc_34C4A:
	sf	has_level_collision(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	move.w	#(LnkTo_unk_C75DE-Data_Index),addroffset_sprite(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#(LnkTo_unk_C75E6-Data_Index),addroffset_sprite(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(j_Hibernate_Object_1Frame).w
	jmp	(j_Delete_CurrentObject).w