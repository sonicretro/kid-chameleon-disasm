;loc_3A770:
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
	blt.s	loc_3A7AC
	st	x_direction(a3)

loc_3A7AC:
	st	$13(a3)
	move.w	#3,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#2,palette_line(a3)
	move.b	#0,priority(a3)
	move.w	#$20,$4A(a5)
	move.w	#$B,$48(a5)
	move.w	enemy_hp(a3),d7
	addi.w	#2,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	blt.s	loc_3A7EE
	move.l	#$8000,$50(a5)

loc_3A7EE:
	addi.l	#$8000,$50(a5)
	move.l	#stru_3A6E2,d7
	jsr	(j_Init_Animation).w
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3A(a5)
	move.b	#0,$10(a1)
	move.w	$4A(a3),$4A(a1)
	move.w	$48(a3),$48(a1)
	st	$13(a1)
	move.b	palette_line(a3),$11(a1)
	move.w	$3E(a3),$3E(a1)
	move.b	x_direction(a3),$16(a1)
	move.w	vram_tile(a3),$24(a1)
	move.w	object_meta(a3),$3A(a1)
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	subi.w	#$10,$1E(a1)
	move.w	#$10,$46(a1)
	exg	a1,a3
	move.l	#stru_3A716,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	move.l	#loc_3A890,a0
	move.l	#$10001,$54(a5)
	tst.b	$19(a3)
	bne.s	loc_3A884
	moveq	#sfx_Robot_jumping_on,d0
	jsr	(j_PlaySound).l

loc_3A884:
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3A890:
	cmpi.w	#(LnkTo_unk_C82A8-Data_Index),addroffset_sprite(a3)
	bne.s	loc_3A8AE
	cmpi.w	#4,animation_timer(a3)
	bne.s	loc_3A8AE
	tst.b	$19(a3)
	bne.s	loc_3A8AE
	moveq	#sfx_Robot_jumping_on,d0
	jsr	(j_PlaySound).l

loc_3A8AE:
	move.w	collision_type(a3),d5
	bmi.w	loc_3A9D2
	cmpi.w	#$800,d5
	beq.w	loc_3A9F0
	cmpi.w	#$1C,d5
	beq.s	loc_3A8FC
	move.l	$3A(a5),a2
	move.w	$38(a2),d4
	bmi.w	loc_3A96C
	beq.w	loc_3A958
	cmpi.w	#$1C,d4
	beq.s	loc_3A8FC
	cmpi.w	#$20,d4
	beq.w	loc_3A9CC
	cmpi.w	#$24,d4
	beq.w	loc_3A9CC
	cmpi.w	#$2C,d4
	beq.s	loc_3A8FC
	cmpi.w	#$800,d4
	beq.w	loc_3A9F0
	bra.w	loc_3A958
; ---------------------------------------------------------------------------

loc_3A8FC:
	st	$3D(a2)
	tst.b	$4E(a5)
	bne.s	loc_3A90C
	move.w	#(LnkTo_unk_C8308-Data_Index),$22(a2)

loc_3A90C:
	addi.w	#4,$1E(a2)
	move.l	#stru_3A744,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	subi.w	#1,$44(a3)
	beq.s	loc_3A96C
	tst.b	$19(a3)
	bne.s	loc_3A936
	moveq	#sfx_Robot_jumping_on,d0
	jsr	(j_PlaySound).l

loc_3A936:
	sf	$3D(a2)
	subi.w	#4,$1E(a2)
	move.l	#stru_3A6E2,d7
	jsr	(j_Init_Animation).w
	exg	a3,a2
	move.l	#stru_3A716,d7
	jsr	(j_Init_Animation).w
	exg	a3,a2

loc_3A958:
	clr.w	$38(a2)
	clr.w	collision_type(a3)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3A96C:
	clr.w	$4E(a5)
	sf	$13(a2)
	st	has_kid_collision(a3)
	st	$3D(a2)
	move.l	#stru_3A74A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	st	$13(a2)
	move.l	#stru_3A6FC,d7
	jsr	(j_Init_Animation).w
	exg	a2,a3
	move.l	#stru_3A730,d7
	jsr	(j_Init_Animation).w
	exg	a2,a3
	move.l	#$28000,$50(a5)
	move.w	#$800,$38(a2)
	move.w	#$800,collision_type(a3)
	move.w	#$F,$54(a5)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3A9CC:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3A958
; START	OF FUNCTION CHUNK FOR sub_3C4F8

loc_3A9D2:
	sf	$13(a2)
	st	$3D(a2)
	st	has_kid_collision(a3)
	move.l	#stru_3A74A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E
; END OF FUNCTION CHUNK	FOR sub_3C4F8
; ---------------------------------------------------------------------------

loc_3A9F0:
	subi.w	#1,$54(a5)
	bne.s	loc_3AA0C
	jsr	(j_Get_RandomNumber_byte).w
	lsr.w	#1,d7
	addi.w	#$F,d7
	move.w	d7,$54(a5)
	eori.b	#$FF,x_direction(a3)

loc_3AA0C:
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_3C4F8

Enemy03_Robot_Shoot:
	exg	a0,a1
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Enemy03_Robot_Shot_Init,4(a0)
	exg	a0,a1
	move.l	$3A(a5),a2
	sf	$15(a2)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C8328-Data_Index),$22(a2)	; head when shooting
	move.w	#(LnkTo_unk_C8330-Data_Index),addroffset_sprite(a3)	; legs when shooting
	addi.w	#3,$1E(a2)
	moveq	#8,d0

loc_3AA4C:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	$38(a2)
	bne.w	loc_3AAD4
	dbf	d0,loc_3AA4C
	tst.b	$16(a2)
	beq.s	loc_3AA68
	move.w	#$FFFC,d1
	bra.s	loc_3AA6C
; ---------------------------------------------------------------------------

loc_3AA68:
	move.w	#4,d1

loc_3AA6C:
	add.w	d1,$1A(a2)
	moveq	#4,d0

loc_3AA72:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	$38(a2)
	bne.w	loc_3AAD4
	dbf	d0,loc_3AA72
	sub.w	d1,$1A(a2)
	moveq	#$A,d0

loc_3AA88:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	$38(a2)
	bne.w	loc_3AAD4
	dbf	d0,loc_3AA88
	subi.w	#3,$1E(a2)

loc_3AA9E:
	st	$15(a2)
	move.l	#stru_3A6E2,a1
	addi.w	#$14,a1
	move.l	a1,$2E(a3)
	move.w	2(a1),addroffset_sprite(a3)
	st	is_animated(a3)
	sf	$18(a3)
	move.w	#9,animation_timer(a3)

loc_3AAC4:
	clr.w	$38(a2)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3AAD4:
	move.w	$38(a2),d0
	cmpi.w	#$2C,d0
	beq.s	loc_3AB04
	cmpi.w	#$1C,d4
	beq.s	loc_3AB04
	cmpi.w	#colid_hurt,collision_type(a3)
	beq.s	loc_3AB04
	cmpi.w	#$20,d4
	beq.w	loc_3AAFA
	cmpi.w	#$24,d4
	bne.s	loc_3AA9E

loc_3AAFA:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3AA9E
	bra.w	loc_3A9D2
; ---------------------------------------------------------------------------

loc_3AB04:
	st	$3D(a2)
	tst.b	$4E(a5)
	bne.s	loc_3AB14
	move.w	#(LnkTo_unk_C8308-Data_Index),$22(a2)

loc_3AB14:
	addi.w	#4,$1E(a2)
	move.l	#stru_3A744,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	subi.w	#1,$44(a3)
	beq.s	loc_3AB56
	sf	$3D(a2)
	subi.w	#4,$1E(a2)
	move.l	#stru_3A6E2,d7
	jsr	(j_Init_Animation).w
	exg	a3,a2
	move.l	#stru_3A716,d7
	jsr	(j_Init_Animation).w
	exg	a3,a2
	bra.w	loc_3AAC4
; ---------------------------------------------------------------------------

loc_3AB56:
	clr.w	$4E(a5)
	sf	$13(a2)
	st	has_kid_collision(a3)
	st	$3D(a2)
	move.l	#stru_3A74A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	st	$13(a2)
	move.l	#stru_3A6FC,d7
	jsr	(j_Init_Animation).w
	exg	a2,a3
	move.l	#stru_3A730,d7
	jsr	(j_Init_Animation).w
	exg	a2,a3
	move.l	#$28000,$50(a5)
	move.w	#$800,$38(a2)
	move.w	#$800,collision_type(a3)
	move.w	#$F,$54(a5)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; END OF FUNCTION CHUNK	FOR sub_3C4F8

; =============== S U B	R O U T	I N E =======================================

;sub_3ABB6:
Enemy03_Robot_Shot_Init:
	move.w	#$A,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$3A(a0),a1
	move.l	$36(a0),a0
	move.b	#1,priority(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	$11(a0),palette_line(a3)
	move.w	$3E(a0),$3E(a3)
	move.w	$24(a0),vram_tile(a3)
	move.w	#$FFFB,d0
	move.w	#$FFE6,d1
	move.b	$16(a1),x_direction(a3)
	beq.s	loc_3AC0C
	neg.w	d0
	neg.w	d1

loc_3AC0C:
	move.w	d0,x_vel(a3)
	move.w	$1A(a0),x_pos(a3)
	add.w	d1,x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	move.w	$46(a1),d0
	subi.w	#2,d0
	sub.w	d0,y_pos(a3)
	move.l	#stru_3A754,d7	; animation for shot
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.s	loc_3AC48
	moveq	#sfx_Robot_shoots,d0
	jsr	(j_PlaySound).l

loc_3AC48:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FF80,d0
	blt.s	loc_3AC7E
	cmpi.w	#$1C0,d0
	bgt.s	loc_3AC7E
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FF80,d0
	blt.s	loc_3AC7E
	cmpi.w	#$1C0,d0
	bgt.s	loc_3AC7E
	tst.w	collision_type(a3)
	beq.s	loc_3AC48

loc_3AC7E:
	move.l	#0,x_vel(a3)
	move.w	#$FFF8,d0
	tst.b	x_direction(a3)
	beq.s	loc_3AC92
	neg.w	d0

loc_3AC92:
	add.w	d0,x_pos(a3)
	move.l	#stru_3A762,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; End of function Enemy03_Robot_Shot_Init