;stru_3DEDA: 
	include "ingame/anim/enemy/Lion.asm"

;loc_3DF56:
Enemy12_Lion_Init: 
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a4
	move.w	2(a4),enemy_hp(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3DF92
	st	x_direction(a3)

loc_3DF92:
	st	$13(a3)
	move.w	#$12,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#2,palette_line(a3)
	bset	#7,object_meta(a3)
	move.w	enemy_hp(a3),d7
	addq.w	#6,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#8,d7
	bne.s	loc_3DFD8
	move.l	#$28000,$50(a5)
	move.l	#$28000,$5E(a5)
	move.l	#stru_3DEF4,$62(a5)
	bra.s	loc_3DFF0
; ---------------------------------------------------------------------------

loc_3DFD8:
	move.l	#$18000,$50(a5)
	move.l	#$18000,$5E(a5)
	move.l	#stru_3DEDA,$62(a5)

loc_3DFF0:
	move.w	#$2F,$4A(a5)
	move.w	#$14,$48(a5)
	move.l	#loc_3E03C,$6A(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	move.w	#$A,$42(a3)
	move.l	#$3C,$54(a5)
	move.l	#loc_3E318,a0
	jsr	(j_Get_RandomNumber_byte).w
	move.b	d7,$71(a5)
	bne.s	loc_3E030
	addi.b	#$4B,$71(a5)

loc_3E030:
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3E03C:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d4
	sub.w	x_pos(a4),d4
	cmpi.w	#$40,d4
	bgt.s	loc_3E054
	cmpi.w	#$FFC0,d4
	bgt.s	loc_3E078

loc_3E054:
	tst.b	$4E(a5)
	beq.s	loc_3E06A
	cmpi.w	#$A0,d4
	bge.s	loc_3E066
	cmpi.w	#$FF60,d4
	bgt.s	loc_3E078

loc_3E066:
	sf	$4E(a5)

loc_3E06A:
	tst.w	d4
	bmi.s	loc_3E074
	sf	x_direction(a3)
	bra.s	loc_3E078
; ---------------------------------------------------------------------------

loc_3E074:
	st	x_direction(a3)

loc_3E078:
	subi.l	#1,$54(a5)
	bne.w	loc_3E11E
	move.l	#$B4,$54(a5)
	tst.b	$5B(a5)
	bgt.w	loc_3E11E
	move.l	#stru_3DF0E,d7
	jsr	(j_Init_Animation).w

loc_3E09E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d4
	cmpi.w	#colid_hurt,d4
	beq.w	loc_3E318
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3E318
	clr.w	collision_type(a3)
	cmpi.w	#(LnkTo_unk_C7E78-Data_Index),addroffset_sprite(a3)
	bne.s	loc_3E09E
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d7
	cmp.w	x_pos(a3),d7
	bgt.s	loc_3E0D6
	sf	x_direction(a3)
	bra.s	loc_3E0DA
; ---------------------------------------------------------------------------

loc_3E0D6:
	st	x_direction(a3)

loc_3E0DA:
	exg	a0,a1
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3E12A,4(a0)
	exg	a0,a1
	addi.b	#1,$5B(a5)

loc_3E0F4:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d4
	cmpi.w	#colid_hurt,d4
	beq.w	loc_3E318
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3E318
	clr.w	collision_type(a3)
	tst.b	$18(a3)
	beq.s	loc_3E0F4
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w

loc_3E11E:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3E12A:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.b	$71(a0),$71(a5)
	move.l	$36(a0),a0
	move.b	#2,palette_line(a3)
	move.w	#$2FB,vram_tile(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	subi.w	#$18,y_pos(a3)
	move.w	#$A,d7
	move.l	#$60000,d6
	tst.b	$16(a0)
	bne.s	loc_3E180
	neg.w	d7
	neg.l	d6

loc_3E180:
	add.w	d7,x_pos(a3)
	move.l	d6,x_vel(a3)
	move.l	#stru_3DF34,d7
	jsr	(j_Init_Animation).w

loc_3E192:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E2CE
	move.w	collision_type(a3),d4
	beq.s	loc_3E1C2
	cmpi.w	#colid_slopedown,d4
	ble.w	loc_3E260
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3E1B4
	cmpi.w	#colid_hurt,d4
	bne.s	loc_3E1C2

loc_3E1B4:
	move.l	$A(a5),a0
	subi.b	#1,$5B(a0)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3E1C2:
	clr.w	collision_type(a3)
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	bmi.s	loc_3E1F4
	beq.w	loc_3E20E
	subi.l	#$2000,x_vel(a3)
	cmpi.l	#$FFFA0000,x_vel(a3)
	bge.s	loc_3E20E
	move.l	#$FFFA0000,x_vel(a3)
	bra.s	loc_3E20E
; ---------------------------------------------------------------------------

loc_3E1F4:
	addi.l	#$2000,x_vel(a3)
	cmpi.l	#$60000,x_vel(a3)
	ble.s	loc_3E20E
	move.l	#$60000,x_vel(a3)

loc_3E20E:
	move.w	y_pos(a3),d7
	sub.w	y_pos(a4),d7
	subi.w	#$10,d7
	bmi.s	loc_3E240
	beq.w	loc_3E192
	subi.l	#$2000,y_vel(a3)
	cmpi.l	#$FFFA0000,y_vel(a3)
	bge.w	loc_3E192
	move.l	#$FFFA0000,y_vel(a3)
	bra.w	loc_3E192
; ---------------------------------------------------------------------------

loc_3E240:
	addi.l	#$2000,y_vel(a3)
	cmpi.l	#$60000,y_vel(a3)
	ble.w	loc_3E192
	move.l	#$60000,y_vel(a3)
	bra.w	loc_3E192
; ---------------------------------------------------------------------------

loc_3E260:
	clr.w	collision_type(a3)
	moveq	#$F,d0

loc_3E266:
	cmpi.w	#4,d4
	beq.s	loc_3E2A4
	cmpi.w	#8,d4
	beq.s	loc_3E2A4
	cmpi.w	#$C,d4
	beq.w	loc_3E2C8
	cmpi.w	#$10,d4
	beq.w	loc_3E2C8
	move.l	x_vel(a3),d5
	sub.l	d5,x_pos(a3)
	move.l	y_vel(a3),d6
	sub.l	d6,y_pos(a3)
	move.l	d5,y_vel(a3)
	cmpi.w	#$14,d4
	bne.s	loc_3E29E
	neg.l	d6

loc_3E29E:
	move.l	d6,x_vel(a3)
	bra.s	loc_3E2A8
; ---------------------------------------------------------------------------

loc_3E2A4:
	neg.l	x_vel(a3)

loc_3E2A8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E2CE
	move.w	collision_type(a3),d4
	beq.s	loc_3E2C0
	clr.w	collision_type(a3)
	cmpi.w	#colid_slopedown,d4
	ble.s	loc_3E266

loc_3E2C0:
	dbf	d0,loc_3E2A8
	bra.w	loc_3E192
; ---------------------------------------------------------------------------

loc_3E2C8:
	neg.l	y_vel(a3)
	bra.s	loc_3E2A8

; =============== S U B	R O U T	I N E =======================================


sub_3E2CE:
	move.b	$71(a5),d6
	move.l	$A(a5),a0
	cmp.b	$71(a0),d6
	bne.s	loc_3E314
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7
	cmpi.w	#$FFC0,d7
	blt.w	loc_3E30E
	cmpi.w	#$180,d7
	bgt.w	loc_3E30E
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#$FFC0,d7
	blt.w	loc_3E30E
	cmpi.w	#$120,d7
	bgt.w	loc_3E30E
	rts
; ---------------------------------------------------------------------------

loc_3E30E:
	subi.b	#1,$5B(a0)

loc_3E314:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3E2CE

; ---------------------------------------------------------------------------

loc_3E318:
	move.w	collision_type(a3),d4
	bmi.s	loc_3E378
	beq.s	loc_3E356
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3E32C
	cmpi.w	#colid_hurt,d4
	bne.s	loc_3E356

loc_3E32C:
	subi.w	#1,$44(a3)
	beq.s	loc_3E378
	bset	#7,object_meta(a3)
	move.l	#stru_3DF42,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bclr	#7,object_meta(a3)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w

loc_3E356:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3E36C
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3E36C:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3E378:
	st	has_kid_collision(a3)
	move.l	#stru_3DF48,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	clr.b	$71(a5)
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3E392:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	st	x_direction(a3)
	sf	$5C(a5)

loc_3E3A2:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	jmp	(a0)
; ---------------------------------------------------------------------------

loc_3E3AC:
	move.l	$6A(a5),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

loc_3E3B2:
	bsr.w	sub_36972
	btst	#2,d7
	bne.w	loc_3E94E
	tst.w	d6
	bmi.w	loc_3E682
	move.l	x_pos(a3),d0
	move.l	d0,d1
	add.l	$50(a5),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	move.w	d0,d3
	add.w	$48(a5),d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E434
	btst	#1,d7
	beq.s	loc_3E406
	tst.w	d5
	bne.s	loc_3E406
	lsl.w	#3,d4
	cmp.w	$48(a5),d4
	bcs.s	loc_3E406
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	bra.w	loc_3E682
; ---------------------------------------------------------------------------

loc_3E406:
	btst	#0,d7
	beq.s	loc_3E434
	move.w	object_meta(a3),d7
	andi.w	#$FF,d7
	cmpi.w	#$10,d7
	bne.w	loc_3E48E
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E3A2
; ---------------------------------------------------------------------------

loc_3E434:
	cmpi.w	#$A,$42(a3)
	beq.w	loc_3E4C6
	tst.w	$42(a3)
	bgt.s	loc_3E476
	beq.s	loc_3E450
	addi.w	#1,$42(a3)
	bra.w	loc_3E4C6
; ---------------------------------------------------------------------------

loc_3E450:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#$60,d4
	bgt.w	loc_3E4C6
	cmpi.w	#$FFA0,d4
	blt.w	loc_3E4C6
	tst.w	d4
	bgt.w	loc_3E4CE
	bra.w	loc_3E50A
; ---------------------------------------------------------------------------

loc_3E476:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#$70,d4
	bgt.s	loc_3E48E
	cmpi.w	#$FF90,d4
	bgt.s	loc_3E4C6

loc_3E48E:
	bclr	#7,object_meta(a3)
	addq.b	#1,$5A(a5)
	st	$4E(a5)
	cmpi.w	#$A,$42(a3)
	beq.w	loc_3E546
	tst.w	$42(a3)
	ble.w	loc_3E546
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E546
; ---------------------------------------------------------------------------

loc_3E4C6:
	move.l	d2,x_pos(a3)
	bra.w	loc_3E3A2
; ---------------------------------------------------------------------------

loc_3E4CE:
	cmpi.w	#1,$42(a3)
	beq.w	loc_3E3A2
	cmpi.w	#2,$42(a3)
	beq.w	loc_3E556
	st	x_direction(a3)
	move.w	#1,$42(a3)
	bset	#7,object_meta(a3)
	move.l	$50(a5),$5E(a5)
	move.w	$4C(a5),$50(a5)
	move.l	$66(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3E50A:
	cmpi.w	#1,$42(a3)
	beq.w	loc_3E3A2
	cmpi.w	#2,$42(a3)
	beq.w	loc_3E556
	sf	x_direction(a3)
	move.w	#2,$42(a3)
	bset	#7,object_meta(a3)
	move.l	$50(a5),$5E(a5)
	move.w	$4C(a5),$50(a5)
	move.l	$66(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	*+4

loc_3E546:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	x_direction(a3)
	sf	$5C(a5)

loc_3E556:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	jmp	(a0)
; ---------------------------------------------------------------------------

loc_3E560:
	move.l	$6A(a5),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

loc_3E566:
	bsr.w	sub_36A58
	btst	#2,d7
	bne.w	loc_3E94E
	tst.w	d6
	bmi.w	loc_3E79E
	move.l	x_pos(a3),d0
	move.l	d0,d1
	sub.l	$50(a5),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	neg.w	d1
	move.w	d0,d3
	sub.w	$48(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E5E8
	btst	#1,d7
	beq.s	loc_3E5BA
	tst.w	d5
	bne.s	loc_3E5BA
	lsl.w	#3,d4
	cmp.w	$48(a5),d4
	bcs.s	loc_3E5BA
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	bra.w	loc_3E79E
; ---------------------------------------------------------------------------

loc_3E5BA:
	btst	#0,d7
	beq.s	loc_3E5E8
	move.w	object_meta(a3),d7
	andi.w	#$FF,d7
	cmpi.w	#$10,d7
	bne.w	loc_3E642
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E556
; ---------------------------------------------------------------------------

loc_3E5E8:
	cmpi.w	#$A,$42(a3)
	beq.w	loc_3E67A
	tst.w	$42(a3)
	bgt.s	loc_3E62A
	beq.s	loc_3E604
	addi.w	#1,$42(a3)
	bra.w	loc_3E67A
; ---------------------------------------------------------------------------

loc_3E604:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#$60,d4
	bgt.w	loc_3E67A
	cmpi.w	#$FFA0,d4
	blt.w	loc_3E67A
	tst.w	d4
	bgt.w	loc_3E4CE
	bra.w	loc_3E50A
; ---------------------------------------------------------------------------

loc_3E62A:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#$70,d4
	bgt.s	loc_3E642
	cmpi.w	#$FF90,d4
	bgt.s	loc_3E67A

loc_3E642:
	bclr	#7,object_meta(a3)
	addq.b	#1,$5A(a5)
	st	$4E(a5)
	cmpi.w	#$A,$42(a3)
	beq.w	loc_3E392
	tst.w	$42(a3)
	ble.w	loc_3E392
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3E67A:
	move.l	d2,x_pos(a3)
	bra.w	loc_3E556
; ---------------------------------------------------------------------------

loc_3E682:
	st	$5C(a5)
	move.w	$4A(a3),d0
	beq.s	loc_3E694
	move.w	d0,addroffset_sprite(a3)
	sf	is_animated(a3)

loc_3E694:
	clr.l	y_vel(a3)
	move.l	$50(a5),x_vel(a3)
	addq.w	#1,y_pos(a3)
	bra.s	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3E6A4:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	jmp	(a0)
; ---------------------------------------------------------------------------

loc_3E6AE:
	bsr.w	sub_36B3C
	tst.w	d5
	bne.w	loc_3E94E
	move.l	x_pos(a3),d0
	move.l	d0,d1
	add.l	x_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	move.w	d0,d3
	add.w	$48(a5),d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E6F0
	tst.w	d6
	beq.w	loc_3E6F0
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	clr.l	x_vel(a3)
	bra.s	loc_3E6F6
; ---------------------------------------------------------------------------

loc_3E6F0:
	move.l	d2,x_pos(a3)
	move.l	d2,d0

loc_3E6F6:
	move.l	y_pos(a3),d0
	move.l	d0,d1
	add.l	y_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	bge.s	loc_3E732
	neg.w	d1
	move.w	d0,d3
	sub.w	$4A(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E77A
	bsr.w	sub_36CB8
	beq.w	loc_3E77A
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	clr.l	y_vel(a3)
	bra.s	loc_3E77E
; ---------------------------------------------------------------------------

loc_3E732:
	move.w	d0,d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E77A
	bsr.w	sub_36C6A
	beq.w	loc_3E77A
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	sf	$5C(a5)
	bclr	#7,object_meta(a3)
	move.l	$5E(a5),$50(a5)
	cmpi.w	#$A,$42(a3)
	beq.s	loc_3E76E
	move.w	#$FF88,$42(a3)

loc_3E76E:
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3E77A:
	move.l	d2,y_pos(a3)

loc_3E77E:
	move.l	y_vel(a3),d0
	addi.l	#$4000,d0
	cmpi.l	#$180000,d0
	blt.s	loc_3E796
	move.l	#$180000,d0

loc_3E796:
	move.l	d0,y_vel(a3)
	bra.w	loc_3E6A4
; ---------------------------------------------------------------------------

loc_3E79E:
	st	$5C(a5)
	move.w	$4A(a3),d0
	beq.s	loc_3E7B0
	move.w	d0,addroffset_sprite(a3)
	sf	is_animated(a3)

loc_3E7B0:
	clr.l	y_vel(a3)
	move.l	$50(a5),x_vel(a3)
	addq.w	#1,y_pos(a3)
	bra.s	loc_3E7CA
; ---------------------------------------------------------------------------

loc_3E7C0:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	jmp	(a0)


loc_3E7CA:
	bsr.w	sub_36BD6
	tst.w	d5
	bne.w	loc_3E94E
	move.l	x_pos(a3),d0
	move.l	d0,d1
	sub.l	x_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	neg.w	d1
	move.w	d0,d3
	sub.w	$48(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E80C
	tst.w	d6
	beq.w	loc_3E80C
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	clr.l	x_vel(a3)
	bra.s	loc_3E812
; ---------------------------------------------------------------------------

loc_3E80C:
	move.l	d2,x_pos(a3)
	move.l	d2,d0

loc_3E812:
	move.l	y_pos(a3),d0
	move.l	d0,d1
	add.l	y_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	bge.s	loc_3E84E
	neg.w	d1
	move.w	d0,d3
	sub.w	$4A(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E896
	bsr.w	sub_36CB8
	beq.w	loc_3E896
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	clr.l	y_vel(a3)
	bra.s	loc_3E89A
; ---------------------------------------------------------------------------

loc_3E84E:
	move.w	d0,d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3E896
	bsr.w	sub_36C6A
	beq.w	loc_3E896
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	sf	$5C(a5)
	bclr	#7,object_meta(a3)
	move.l	$5E(a5),$50(a5)
	cmpi.w	#$A,$42(a3)
	beq.s	loc_3E88A
	move.w	#$FF88,$42(a3)

loc_3E88A:
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3E546
; ---------------------------------------------------------------------------

loc_3E896:
	move.l	d2,y_pos(a3)

loc_3E89A:
	move.l	y_vel(a3),d0
	addi.l	#$4000,d0
	cmpi.l	#$180000,d0
	blt.s	loc_3E8B2
	move.l	#$180000,d0

loc_3E8B2:
	move.l	d0,y_vel(a3)
	bra.w	loc_3E7C0

; =============== S U B	R O U T	I N E =======================================


sub_3E8BA:
	cmpi.w	#$FFE0,x_pos(a3)
	ble.s	loc_3E920
	cmpi.w	#$FFE0,y_pos(a3)
	ble.s	loc_3E920
	move.w	(Level_width_pixels).w,d7
	addi.w	#$20,d7
	cmp.w	x_pos(a3),d7
	blt.s	loc_3E920
	move.w	(Level_height_blocks).w,d7
	addi.w	#$20,d7
	cmp.w	y_pos(a3),d7
	blt.s	loc_3E920
	cmpi.w	#$A,(Number_Objects).w
	ble.s	return_3E91E
	cmpi.w	#$14,(Number_Objects).w
	ble.s	loc_3E924
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FEFC,d0
	blt.s	loc_3E920
	cmpi.w	#$244,d0
	bgt.s	loc_3E920
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FEFC,d0
	blt.s	loc_3E920
	cmpi.w	#$1E4,d0
	bgt.s	loc_3E920

return_3E91E:
	rts
; ---------------------------------------------------------------------------

loc_3E920:
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3E924:
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3E920
	cmpi.w	#$2E4,d0
	bgt.s	loc_3E920
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3E920
	cmpi.w	#$284,d0
	bgt.s	loc_3E920
	rts
; ---------------------------------------------------------------------------

loc_3E94E:
	move.w	#$FFFF,collision_type(a3)
	jmp	(a0)
; ---------------------------------------------------------------------------

loc_3E956:
	moveq	#0,d0
	subi.w	#1,($FFFFFA06).w
	move.b	$42(a5),d0
	bpl.s	loc_3E97C
	btst	#6,d0
	beq.s	loc_3E98A
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3E98A
; ---------------------------------------------------------------------------

loc_3E97C:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_3E98A:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3E8BA

