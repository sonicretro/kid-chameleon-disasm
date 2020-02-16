byte_321BC:
	dc.b 2
	dc.b 4
	dc.b 6
	dc.b 0

;loc_321C0:
Enemy05_TarMonster_Init:
	move.l	#$1000002,a3

loc_321C6:
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	2(a0),d3
	move.b	byte_321BC(pc,d3.w),d3
	ext.w	d3
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)

loc_321E4:
	bsr.w	sub_36FF4
	move.b	#0,priority(a3)
	move.w	#5,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	a3,$3A(a5)
	move.l	a3,a2

loc_32200:
	move.w	#(LnkTo_unk_C7826-Data_Index),$22(a2)
	jsr	loc_32188(pc)
	exg	a1,a3
	move.l	a3,$36(a5)
	move.w	#5,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.b	#0,priority(a3)
	move.l	$1A(a2),x_pos(a3)
	move.l	$1E(a2),y_pos(a3)
	st	$13(a3)
	move.w	#2,8(a3)
	move.w	#$100,$A(a3)
	move.l	($FFFFF86A).w,4(a3)
	move.l	a3,($FFFFF86A).w

loc_32248:
	lea	(unk_32264).l,a0

loc_3224E:
	clr.w	collision_type(a3)
	lea	off_32290(pc),a1

loc_32256:
	move.w	(a0)+,d0
	bmi.s	loc_32248
	moveq	#0,d7
	move.b	d0,d7
	move.l	(a1,d7.w),a1
	jmp	(a1)
; ---------------------------------------------------------------------------
unk_32264:	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $10
	dc.b $5A ; Z
	dc.b   0
	dc.b   0
	dc.b $10
unk_3226C:	dc.b   5
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b  $A
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   7
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b $32 ; 2
	dc.b   0
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b $10
	dc.b $1E
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b $46 ; F
	dc.b   0
unk_32284:	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b   4
	dc.b $14
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b $46 ; F
	dc.b   0
	dc.b $FF
	dc.b $FF
off_32290:	dc.l loc_322A8
	dc.l loc_322BC
	dc.l loc_322DA
	dc.l loc_322FC
	dc.l loc_32308
	dc.l loc_32310
; ---------------------------------------------------------------------------

loc_322A8:
	lsr.w	#8,d0

loc_322AA:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3237A
	dbf	d0,loc_322AA
	bra.s	loc_3224E
; ---------------------------------------------------------------------------

loc_322BC:
	move.l	d0,-(sp)
	moveq	#sfx_Tar_Monster_appears,d0

loc_322C0:
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_322C8:
	move.l	#stru_3272E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_322DA:
	move.l	d0,-(sp)
	moveq	#sfx_Tar_Monster_disappears,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	sf	$13(a2)
	move.l	#stru_3274C,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_322FC:
	not.b	x_direction(a3)
	not.b	$16(a2)
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_32308:
	not.b	$13(a2)
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_32310:
	sf	$13(a2)
	move.w	#(LnkTo_unk_C77DE-Data_Index),addroffset_sprite(a3)
	moveq	#8,d0

loc_3231C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3237A
	dbf	d0,loc_3231C
	move.l	a0,-(sp)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_32468,4(a0)
	move.l	(sp)+,a0
	move.w	#(LnkTo_unk_C77E6-Data_Index),addroffset_sprite(a3)
	moveq	#8,d0

loc_32348:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3237A
	dbf	d0,loc_32348
	move.w	#(LnkTo_unk_C77DE-Data_Index),addroffset_sprite(a3)

loc_3235E:
	moveq	#8,d0

loc_32360:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3237A
	dbf	d0,loc_32360
	move.w	#(LnkTo_unk_C77D6-Data_Index),addroffset_sprite(a3)
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_3237A:
	move.w	collision_type(a3),d7
	bmi.w	loc_323E6
	beq.w	return_3243E

loc_32386:
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d7
	beq.w	loc_323C0
	cmpi.w	#$1C,d7
	beq.w	loc_323C0
	cmpi.w	#$20,d7
	beq.w	loc_323AA
	cmpi.w	#$24,d7
	bne.w	return_3243E

loc_323AA:
	tst.b	(Berzerker_charging).w
	beq.w	return_3243E
	move.l	(Addr_GfxObject_Kid).w,a4
	clr.l	$26(a4)
	addq.w	#4,sp
	bra.w	loc_323E6
; ---------------------------------------------------------------------------

loc_323C0:
	addq.w	#4,sp
	move.b	$13(a2),d2
	sf	$13(a2)
	subq.w	#1,d3
	beq.w	loc_323E6
	move.l	#stru_326EE,d7

loc_323D6:
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.b	d2,$13(a2)
	bra.w	loc_3224E
; ---------------------------------------------------------------------------

loc_323E6:
	sf	$13(a2)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_32468,4(a0)
	st	$44(a0)
	move.l	#stru_32700,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_3242C
	btst	#6,d0
	beq.s	loc_3243A
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3243A
; ---------------------------------------------------------------------------

loc_3242C:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_3243A:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

return_3243E:
	rts
; ---------------------------------------------------------------------------
	sf	$13(a2)
	move.l	#stru_3274C,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#$50,d0

loc_32454:

	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	bsr.w	loc_3237A
	dbf	d0,loc_32454
	bra.w	loc_32248
; ---------------------------------------------------------------------------

loc_32468:
	move.l	d0,-(sp)
	moveq	#sfx_Tar_Monster_shoots,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w

loc_3247E:
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	tst.b	$44(a5)
	bne.w	loc_325AC
	subi.w	#$12,y_pos(a3)
	subi.w	#$19,x_pos(a3)
	move.w	#5,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	st	has_level_collision(a3)
	move.w	#(LnkTo_unk_C781E-Data_Index),addroffset_sprite(a3)
	move.b	$16(a0),x_direction(a3)

loc_324D0:
	move.w	#$FFFC,x_vel(a3)
	tst.b	x_direction(a3)
	beq.s	loc_324E6

loc_324DC:
	neg.w	x_vel(a3)
	addi.w	#$32,x_pos(a3)

loc_324E6:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	bne.w	loc_324F8
	tst.b	$19(a3)
	beq.s	loc_324E6

loc_324F8:
	sf	$13(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325E6,4(a0)
	move.l	#$10000,$44(a0)
	move.l	#-$10000,$48(a0)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325E6,4(a0)

loc_32534:
	move.l	#-$10000,$44(a0)
	move.l	#-$10000,$48(a0)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325E6,4(a0)
	move.l	#$8000,$44(a0)
	move.l	#-$20000,$48(a0)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325E6,4(a0)
	move.l	#-$8000,$44(a0)
	move.l	#-$20000,$48(a0)
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_325E6,4(a0)
	move.l	#$2000,$44(a0)
	move.l	#-$1C000,$48(a0)
	jsr	(j_Hibernate_Object_1Frame).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_325AC:
	subi.w	#$10,y_pos(a3)
	bra.w	loc_324F8
; ---------------------------------------------------------------------------

loc_325B6:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.l	$48(a5),d7
	asl.l	#1,d7
	move.l	d7,x_vel(a3)
	move.w	#(LnkTo_unk_C7BDE-Data_Index),addroffset_sprite(a3)
	moveq	#0,d1
	move.w	#$16,d0
	bra.w	loc_3261C
; ---------------------------------------------------------------------------

loc_325E6:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	move.l	$44(a5),x_vel(a3)
	move.l	$48(a5),y_vel(a3)
	move.w	#(LnkTo_unk_C782E-Data_Index),addroffset_sprite(a3)
	moveq	#1,d1

loc_32618:
	move.w	#5,d0

loc_3261C:
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	st	has_kid_collision(a3)
	move.b	#0,priority(a3)
	st	has_level_collision(a3)
	moveq	#2,d3

loc_3263C:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1000,y_vel(a3)
	bsr.w	loc_32682
	tst.b	$19(a3)
	beq.s	loc_3263C

loc_32652:

	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
off_32656:	dc.l loc_326AA
	dc.l loc_326AA
	dc.l loc_326B8
	dc.l loc_326B8
	dc.l loc_326C6
	dc.l loc_326DC
	dc.l loc_326DC
	dc.l loc_326AA
	dc.l loc_326AA
	dc.l loc_326B8
	dc.l loc_32652
; ---------------------------------------------------------------------------

loc_32682:

	move.w	collision_type(a3),d7
	bmi.s	loc_32652
	beq.w	return_326A8
	tst.w	d1
	beq.w	loc_32698
	move.w	#(LnkTo_unk_C7836-Data_Index),addroffset_sprite(a3)

loc_32698:
	subq.w	#1,d3
	bmi.s	loc_32652
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	off_32656(pc,d7.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------

return_326A8:
	rts
; ---------------------------------------------------------------------------

loc_326AA:
	move.l	x_vel(a3),d7
	asr.l	#1,d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_326B8:
	move.l	y_vel(a3),d7
	asr.l	#1,d7
	neg.l	d7

loc_326C0:
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_326C6:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),d6
	neg.l	d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_326DC:
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts