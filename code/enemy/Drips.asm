stru_33332:
	anim_frame	1, 1, LnkTo_unk_C7B96-Data_Index
	dc.b 0
	dc.b 0
unk_33338:
	dc.w 0
	dc.w $FF00
	dc.w $FFFF

;loc_3333E:
Enemy16_Drip_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	move.w	2(a0),d7
	add.w	d7,d7
	lea	unk_33338(pc,d7.w),a4
	move.b	(a4)+,$44(a5)
	move.b	(a4)+,$45(a5)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	sf	x_direction(a3)
	st	has_kid_collision(a3)
	move.b	#0,priority(a3)
	move.w	#$16,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	st	has_level_collision(a3)
	move.w	#(LnkTo_unk_C7B0E-Data_Index),addroffset_sprite(a3)
	move.l	#-$10000,y_vel(a3)
	move.l	#$3000003,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3A(a5)
	exg	a1,a3
	move.w	#$16,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	exg	a1,a3
	exg	a1,a2
	move.l	#$3000003,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$3D(a1)
	move.l	a1,$3E(a5)
	exg	a1,a3
	move.w	#$16,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	exg	a1,a3
	exg	a1,a2
	moveq	#1,d3
	lea	(off_33520).l,a0

loc_333F6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	cmpi.w	#colid_ceiling,collision_type(a3)
	bne.s	loc_333F6
	clr.w	collision_type(a3)
	clr.l	y_vel(a3)

loc_3340E:
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$FF,d7
	asr.w	#2,d7
	move.w	d7,d0
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d7
	eor.b	d7,d0

loc_33424:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.s	loc_33424
	move.l	#stru_33F90,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	st	$13(a1)
	st	$14(a1)
	st	$3C(a1)
	move.w	#(LnkTo_unk_C7B26-Data_Index),$22(a1)
	move.l	x_pos(a3),$1A(a1)
	move.l	y_pos(a3),$1E(a1)
	clr.l	$2A(a1)

loc_3345C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	addi.l	#$2000,$2A(a1)
	cmpi.w	#$C,$38(a1)
	bne.s	loc_3345C
	tst.b	$19(a3)
	bne.w	loc_33488
	move.l	d0,-(sp)
	moveq	#sfx_Drips_dripping,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_33488:
	sf	$14(a1)
	clr.w	$38(a1)
	addi.w	#$A,$1E(a1)
	exg	a1,a3
	move.l	#stru_33332,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	exg	a1,a3
	move.l	$1A(a1),$1A(a2)
	move.l	$1E(a1),$1E(a2)
	st	$13(a2)
	sf	$13(a1)
	subq.w	#1,d3
	bne.w	loc_3340E
	move.w	#1,d3
	move.w	(a0)+,d7
	bpl.w	loc_3350E
	cmpi.w	#5,($FFFFFB42).w
	bge.w	loc_33506
	addq.w	#1,($FFFFFB42).w
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_335D8,4(a0)
	move.w	$1A(a1),$44(a0)
	addi.w	#1,$44(a0)
	move.w	$1E(a1),d7
	addi.w	#$A,d7
	andi.w	#$FFF0,d7
	move.w	d7,$46(a0)

loc_33506:
	lea	(off_33520).l,a0
	moveq	#0,d7

loc_3350E:
	move.w	d7,$22(a2)
	bra.w	loc_3340E
; ---------------------------------------------------------------------------

loc_33516:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bra.s	loc_33516
; ---------------------------------------------------------------------------
off_33520:	dc.w LnkTo_unk_C7B9E-Data_Index
	dc.w LnkTo_unk_C7BA6-Data_Index
	dc.b $FF
	dc.b $FF
; ---------------------------------------------------------------------------

loc_33526:
	moveq	#0,d7
	moveq	#0,d6
	tst.b	$44(a5)
	beq.w	loc_33546
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	tst.b	$45(a5)
	beq.w	loc_33546
	add.l	d7,d7
	add.l	d6,d6

loc_33546:
	add.l	d7,x_vel(a3)
	add.l	d6,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_33550:
	move.w	collision_type(a3),d5
	beq.w	loc_33584
	bmi.w	loc_33576
	clr.w	collision_type(a3)
	subi.w	#$1C,d5
	bmi.w	loc_33584
	asr.w	#1,d5
	jmp	loc_3356E(pc,d5.w)

loc_3356E:
	bra.s	loc_33576
; ---------------------------------------------------------------------------
	dc.b $60 ; `
	dc.b  $C
	dc.b $60 ; `
	dc.b  $A
	dc.b $60 ; `
	dc.b  $E
; ---------------------------------------------------------------------------

loc_33576:
	clr.w	collision_type(a3)
	moveq	#1,d5
	rts
; ---------------------------------------------------------------------------
	tst.b	(Berzerker_charging).w
	bne.s	loc_33576

loc_33584:
	moveq	#0,d5
	rts
; ---------------------------------------------------------------------------

loc_33588:
	tst.b	$19(a3)
	bne.w	loc_335D4
	move.w	x_pos(a3),d5
	tst.l	x_vel(a3)
	bmi.w	loc_335AA
	addq.w	#8,d5
	cmp.w	(Level_width_pixels).w,d5
	bge.w	loc_335D4
	bra.w	loc_335B0
; ---------------------------------------------------------------------------

loc_335AA:
	subq.w	#8,d5
	bmi.w	loc_335D4

loc_335B0:
	move.w	y_pos(a3),d5
	tst.l	y_vel(a3)
	bmi.w	loc_335CA
	addq.w	#8,d5
	cmp.w	(Level_height_blocks).w,d5
	bge.w	loc_335D4
	bra.w	loc_335D0
; ---------------------------------------------------------------------------

loc_335CA:
	subq.w	#8,d5
	bmi.w	loc_335D4

loc_335D0:
	moveq	#0,d5
	rts
; ---------------------------------------------------------------------------

loc_335D4:
	moveq	#1,d5
	rts
; ---------------------------------------------------------------------------

loc_335D8:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#0,priority(a3)
	move.w	#$16,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.l	$A(a5),a4
	move.b	$44(a4),$44(a5)
	move.b	$45(a4),$45(a5)
	move.l	#$3000,x_vel(a3)
	jsr	(j_Get_RandomNumber_byte).w
	bclr	#2,d7
	beq.w	loc_33630
	not.b	x_direction(a3)
	neg.l	x_vel(a3)

loc_33630:
	move.l	#stru_33FA6,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_33F14,d7
	jsr	(j_Init_Animation).w
	st	is_moved(a3)
	bsr.w	loc_33526

loc_33650:

	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#0,d6
	moveq	#-8,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	moveq	#0,d1
	moveq	#8,d0
	bsr.w	loc_331D2
	cmpi.w	#$6000,d0
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338EA
	moveq	#6,d7
	tst.b	x_direction(a3)
	beq.w	loc_336AA
	neg.w	d7
	bsr.w	loc_331F6
	cmpi.w	#$6000,d6
	beq.w	loc_3393C
	cmpi.w	#$5000,d6
	beq.w	loc_33A40
	cmpi.w	#$6000,d5
	beq.s	loc_33650
	cmpi.w	#$4000,d5
	beq.w	loc_33A2C
	bra.w	loc_33982
; ---------------------------------------------------------------------------

loc_336AA:
	bsr.w	loc_331F6
	cmpi.w	#$4000,d6
	beq.w	loc_339DC
	cmpi.w	#$6000,d6
	beq.w	loc_33996
	cmpi.w	#$6000,d5
	beq.s	loc_33650
	cmpi.w	#$5000,d5
	beq.w	loc_33A18
	bra.w	loc_339C8
; ---------------------------------------------------------------------------

loc_336D0:

	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#0,d6
	moveq	#8,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	moveq	#0,d1
	moveq	#-8,d0
	bsr.w	loc_331D2
	cmpi.w	#$6000,d0
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338F8
	moveq	#6,d7
	tst.b	x_direction(a3)
	bne.w	loc_3371A
	neg.w	d7
	bsr.w	loc_331F6
	cmpi.w	#$6000,d5
	beq.w	loc_3396E
	cmpi.w	#$6000,d6
	beq.s	loc_336D0
	bra.w	loc_33950
; ---------------------------------------------------------------------------

loc_3371A:
	bsr.w	loc_331F6
	cmpi.w	#$6000,d5
	beq.w	loc_339B4
	cmpi.w	#$6000,d6
	beq.s	loc_336D0
	bra.w	loc_339AA
; ---------------------------------------------------------------------------

loc_33730:

	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#8,d6
	moveq	#0,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	moveq	#-8,d1
	moveq	#0,d0
	bsr.w	loc_331D2
	cmpi.w	#$6000,d0
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338F8
	moveq	#6,d7
	tst.l	y_vel(a3)
	bpl.w	loc_33782
	neg.w	d7
	bsr.w	loc_33286
	cmpi.w	#$6000,d6
	beq.w	loc_33964
	cmpi.w	#$6000,d5
	beq.s	loc_33730
	cmpi.w	#$5000,d5
	beq.w	loc_339FA
	bra.w	loc_339D2
; ---------------------------------------------------------------------------

loc_33782:
	bsr.w	loc_33286
	cmpi.w	#$6000,d6
	beq.w	loc_33946
	cmpi.w	#$5000,d6
	beq.w	loc_33A72
	cmpi.w	#$6000,d5
	beq.s	loc_33730
	bra.w	loc_339A0
; ---------------------------------------------------------------------------

loc_337A0:
	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#-8,d6
	moveq	#0,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	moveq	#8,d1
	moveq	#0,d0
	bsr.w	loc_331D2
	cmpi.w	#$6000,d0
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338F8
	moveq	#6,d7
	tst.l	y_vel(a3)
	bpl.w	loc_337F2
	neg.w	d7
	bsr.w	loc_33286
	cmpi.w	#$6000,d5
	beq.w	loc_339BE
	cmpi.w	#$6000,d6
	beq.s	loc_337A0
	cmpi.w	#$4000,d6
	beq.w	loc_33A04
	bra.w	loc_33978
; ---------------------------------------------------------------------------

loc_337F2:
	bsr.w	loc_33286
	cmpi.w	#$6000,d5
	beq.w	loc_3398C
	cmpi.w	#$4000,d5
	beq.w	loc_33A5E
	cmpi.w	#$6000,d6
	beq.s	loc_337A0
	bra.w	loc_3395A
; ---------------------------------------------------------------------------

loc_33810:
	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#-8,d6
	moveq	#-8,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338F8
	move.w	x_pos(a3),d7
	andi.w	#$F,d7
	move.w	y_pos(a3),d6
	andi.w	#$F,d6
	add.w	d6,d7
	cmpi.w	#$F,d7
	bne.s	loc_33810
	moveq	#5,d7
	tst.l	y_vel(a3)
	bpl.w	loc_33878
	neg.w	d7
	move.w	#5,d6
	bsr.w	loc_3330E
	cmpi.w	#$4000,d7
	beq.s	loc_33810
	cmpi.w	#$6000,d7
	bne.w	loc_339E6
	bra.w	loc_33A54
; ---------------------------------------------------------------------------

loc_33866:
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_33866
; ---------------------------------------------------------------------------
	cmpi.w	#$4000,d6
	beq.w	loc_337A0
	bra.w	loc_33978
; ---------------------------------------------------------------------------

loc_33878:
	move.w	#$FFFB,d6
	bsr.w	loc_3330E
	cmpi.w	#$4000,d7
	beq.s	loc_33810
	cmpi.w	#$6000,d7
	beq.w	loc_33A36
	bra.w	loc_33A0E
; ---------------------------------------------------------------------------

loc_33892:

	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#8,d6
	moveq	#-8,d7
	bsr.w	loc_33550
	bne.w	loc_338F8
	bsr.w	loc_33588
	bne.w	loc_338F8
	moveq	#5,d7
	tst.l	y_vel(a3)
	bmi.w	loc_338CE
	move.w	#5,d6
	bsr.w	loc_3330E
	cmpi.w	#$5000,d7
	beq.s	loc_33892
	cmpi.w	#$6000,d7
	beq.w	loc_33A22
	bra.w	loc_339F0
; ---------------------------------------------------------------------------

loc_338CE:
	neg.w	d7
	move.w	#$FFFB,d6
	bsr.w	loc_3330E
	cmpi.w	#$5000,d7
	beq.s	loc_33892
	cmpi.w	#$6000,d7
	bne.w	loc_33A4A
	bra.w	loc_33A68
; ---------------------------------------------------------------------------

loc_338EA:
	move.l	#stru_33FB4,d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3392C
; ---------------------------------------------------------------------------

loc_338F8:
	add.w	d6,x_pos(a3)
	add.w	d7,y_pos(a3)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325B6,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	x_vel(a3),$48(a0)
	move.l	#stru_33F06,d7
	jsr	(j_Init_Animation).w

loc_3392C:
	sf	is_moved(a3)
	jsr	(j_sub_105E).w
	subq.w	#1,($FFFFFB42).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3393C:
	lea	(unk_33C80).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33946:
	lea	(unk_33C30).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33950:
	lea	(unk_33BC0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_3395A:
	lea	(unk_33C00).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33964:
	lea	(unk_33C70).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_3396E:
	lea	(unk_33C40).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33978:
	lea	(unk_33BD0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33982:
	lea	(unk_33BF0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_3398C:
	lea	(unk_33C90).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33996:
	lea	(unk_33C20).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339A0:
	lea	(unk_33BB0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339AA:
	lea	(unk_33C10).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339B4:
	lea	(unk_33C60).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339BE:
	lea	(unk_33C50).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339C8:
	lea	(unk_33BA0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339D2:
	lea	(unk_33BE0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339DC:
	lea	(unk_33CA0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339E6:
	lea	(unk_33CB0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339F0:
	lea	(unk_33D70).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_339FA:
	lea	(unk_33D80).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A04:
	lea	(unk_33CF0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A0E:
	lea	(unk_33D90).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A18:
	lea	(unk_33CC0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A22:
	lea	(unk_33CD0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A2C:
	lea	(unk_33CE0).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A36:
	lea	(unk_33D00).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A40:
	lea	(unk_33D10).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A4A:
	lea	(unk_33D20).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A54:
	lea	(unk_33D30).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A5E:
	lea	(unk_33D40).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A68:
	lea	(unk_33D50).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A72:
	lea	(unk_33D60).l,a2
	bra.w	loc_33AF6
; ---------------------------------------------------------------------------

loc_33A7C:

	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_33A7C
; ---------------------------------------------------------------------------
off_33A82:	dc.l stru_33E10
	dc.l stru_33E1E
	dc.l stru_33E2C
	dc.l stru_33E3A
	dc.l stru_33E80
	dc.l stru_33EB2
	dc.l stru_33F14
	dc.l stru_33F52
	dc.l stru_33E48
	dc.l stru_33E56
	dc.l stru_33E64
	dc.l stru_33E72
	dc.l stru_33EE6
	dc.l stru_33DA0
	dc.l stru_33DF4
	dc.l stru_33E02
	dc.l stru_33DAE
	dc.l stru_33DBC
	dc.l stru_33DCA
	dc.l stru_33DD8
	dc.l stru_33DE6
	dc.l stru_33EF6
off_33ADA:	dc.l loc_33650
	dc.l loc_336D0
	dc.l loc_33730
	dc.l loc_337A0
	dc.l loc_33A7C
	dc.l loc_33810
	dc.l loc_33892
; ---------------------------------------------------------------------------

loc_33AF6:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	clr.w	$1C(a3)
	clr.w	$20(a3)
	moveq	#0,d7
	move.b	(a2)+,d6
	ext.w	d6
	move.w	(a3,d6.w),d7
	move.b	(a2)+,d5
	ext.w	d5
	add.w	d5,d7
	andi.w	#$FFF0,d7
	move.b	(a2)+,d5
	ext.w	d5
	add.w	d5,d7
	swap	d7
	move.l	d7,(a3,d6.w)
	tst.b	(a2)+
	beq.w	loc_33B30
	not.b	x_direction(a3)

loc_33B30:
	move.b	(a2)+,d7
	ext.w	d7
	add.w	d7,x_pos(a3)
	move.b	(a2)+,d7
	ext.w	d7
	add.w	d7,y_pos(a3)
	lea	off_33A82(pc),a4
	move.b	(a2)+,d7
	ext.w	d7
	move.l	(a4,d7.w),d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	tst.b	(a2)+
	beq.w	loc_33B5E
	not.b	x_direction(a3)

loc_33B5E:
	move.b	(a2)+,d7
	ext.w	d7
	add.w	d7,x_pos(a3)
	move.b	(a2)+,d7
	ext.w	d7
	add.w	d7,y_pos(a3)
	move.w	(a2)+,d7
	ext.l	d7
	add.l	d7,x_vel(a3)
	move.w	(a2)+,d7
	ext.l	d7
	add.l	d7,y_vel(a3)
	lea	off_33A82(pc),a4
	move.b	(a2)+,d7
	ext.w	d7
	move.l	(a4,d7.w),d7
	jsr	(j_Init_Animation).w
	bsr.w	loc_33526
	lea	off_33ADA(pc),a4
	move.b	(a2)+,d7
	ext.w	d7
	move.l	(a4,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------
unk_33BA0:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b   8
unk_33BB0:	dc.b $1E
	dc.b   8
	dc.b   1
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $FB ; û
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1C
	dc.b   4
unk_33BC0:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $FF
	dc.b $FB ; û
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b  $C
unk_33BD0:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   4
	dc.b $FF
	dc.b   5
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33BE0:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   4
	dc.b $FF
	dc.b $FB ; û
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33BF0:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b  $C
unk_33C00:	dc.b $1E
	dc.b   8
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1C
	dc.b   4
unk_33C10:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b   1
	dc.b $FB ; û
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b   8
unk_33C20:	dc.b $1A
	dc.b   8
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $2C ; ,
	dc.b $FF
	dc.b   0
	dc.b $FB ; û
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b  $C
unk_33C30:	dc.b $1E
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $28 ; (
	dc.b $FF
	dc.b   5
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33C40:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   1
	dc.b   0
	dc.b $20
	dc.b $FF
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b   8
unk_33C50:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b $24 ; $
	dc.b   0
	dc.b $FB ; û
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1C
	dc.b   4
unk_33C60:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b $20
	dc.b $FF
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b  $C
unk_33C70:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b $24 ; $
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1C
	dc.b   4
unk_33C80:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $2C ; ,
	dc.b $FF
	dc.b   0
	dc.b $FB ; û
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b   8
unk_33C90:	dc.b $1E
	dc.b   8
	dc.b   1
	dc.b $FF
	dc.b   0
	dc.b $FF
	dc.b $28 ; (
	dc.b $FF
	dc.b $FB ; û
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33CA0:	dc.b $1A
	dc.b   8
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $34 ; 4
	dc.b   0
	dc.b   4
	dc.b $FD ; ý
	dc.b $20
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $30 ; 0
	dc.b $14
unk_33CB0:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b   1
	dc.b $38 ; 8
	dc.b   0
	dc.b   3
	dc.b $FF
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33CC0:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b   2
	dc.b   1
	dc.b $3C ; <
	dc.b   0
	dc.b   3
	dc.b   4
	dc.b $20
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $54 ; T
	dc.b $18
unk_33CD0:	dc.b $1E
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b $40 ; @
	dc.b $FF
	dc.b   5
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33CE0:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   1
	dc.b $3C ; <
	dc.b   0
	dc.b $FE ; þ
	dc.b   3
	dc.b $E0 ; à
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $54 ; T
	dc.b $14
unk_33CF0:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $4C ; L
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $30 ; 0
	dc.b $14
unk_33D00:	dc.b $1E
	dc.b   8
	dc.b   1
	dc.b   0
	dc.b $FC ; ü
	dc.b $FF
	dc.b $40 ; @
	dc.b $FF
	dc.b $FD ; ý
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33D10:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $34 ; 4
	dc.b   0
	dc.b $FC ; ü
	dc.b $FD ; ý
	dc.b $E0 ; à
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $30 ; 0
	dc.b $18
unk_33D20:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FE ; þ
	dc.b   1
	dc.b $38 ; 8
	dc.b   0
	dc.b $FE ; þ
	dc.b $FF
	dc.b $D0 ; Ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
unk_33D30:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FC ; ü
	dc.b $44 ; D
	dc.b $FF
	dc.b   0
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b  $C
unk_33D40:	dc.b $1E
	dc.b   8
	dc.b   1
	dc.b $FF
	dc.b   0
	dc.b $FF
	dc.b $48 ; H
	dc.b   0
	dc.b $FE ; þ
	dc.b   2
	dc.b $E0 ; à
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $54 ; T
	dc.b $14
unk_33D50:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $FD ; ý
	dc.b $44 ; D
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $D0 ; Ð
	dc.b   0
	dc.b $14
	dc.b   8
unk_33D60:	dc.b $1E
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $48 ; H
	dc.b   0
	dc.b   3
	dc.b   4
	dc.b $20
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $54 ; T
	dc.b $18
unk_33D70:	dc.b $1A
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   3
	dc.b $50 ; P
	dc.b $FF
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b   8
unk_33D80:	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $4C ; L
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $E0 ; à
	dc.b   0
	dc.b $E0 ; à
	dc.b   0
	dc.b $30 ; 0
	dc.b $18
unk_33D90:	dc.b $1A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   3
	dc.b $50 ; P
	dc.b  $F
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $10
	dc.b  $C

;stru_33DA0: 
	include "ingame/anim/enemy/Drips.asm"
