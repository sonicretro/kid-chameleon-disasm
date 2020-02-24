;loc_3D518:
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
	blt.s	loc_3D554
	st	x_direction(a3)

loc_3D554:
	st	$13(a3)
	move.w	#$11,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	#$1D,$4A(a5)
	move.w	#$B,$48(a5)
	move.w	enemy_hp(a3),d7
	addi.w	#2,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	blt.s	loc_3D5AA
	beq.s	loc_3D59A
	move.l	#$8000,$50(a5)
	move.l	#$8000,$5E(a5)

loc_3D59A:
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)

loc_3D5AA:
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)
	move.l	#$32012C,$6E(a5)
	move.w	#$32,$54(a5)
	move.l	#loc_3D92A,$6A(a5)
	move.w	#$A00,$4A(a3)
	move.l	#stru_3D4EA,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3D4EA,$62(a5)
	move.w	#$A,$42(a3)
	move.w	#$12C,$54(a5)
	move.l	#loc_3D606,a0
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3D606:
	tst.b	$5C(a5)
	bne.w	loc_3D878
	move.w	collision_type(a3),d4
	clr.w	collision_type(a3)
	tst.w	d4
	beq.w	loc_3D6DA
	bmi.w	loc_3DB4E
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3D65A
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3D65A
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3D698
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3D698

loc_3D638:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3D64E
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3D64E:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3D65A:
	tst.b	$4C(a5)
	beq.s	loc_3D670
	tst.b	$19(a3)
	bne.s	loc_3D66E
	moveq	#sfx_Ninja_blocking,d0
	jsr	(j_PlaySound).l

loc_3D66E:
	bra.s	loc_3D638
; ---------------------------------------------------------------------------

loc_3D670:
	subi.w	#1,$44(a3)
	beq.w	loc_3DB4E
	move.l	#stru_3D504,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3D638
; ---------------------------------------------------------------------------

loc_3D698:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3D638
	st	has_kid_collision(a3)
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7D7E-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#-$48000,y_vel(a3)

loc_3D6C8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3D6C8
; ---------------------------------------------------------------------------

loc_3D6DA:
	tst.b	$4C(a5)
	beq.s	loc_3D706
	bpl.w	loc_3D79C
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	bne.w	loc_3D79C
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	y_pos(a4),d7
	sub.w	y_pos(a3),d7
	cmpi.w	#-4,d7
	blt.w	loc_3D84E
	bra.w	loc_3D79C
; ---------------------------------------------------------------------------

loc_3D706:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	y_pos(a4),d4
	sub.w	y_pos(a3),d4
	cmpi.w	#-$50,d4
	blt.s	loc_3D734
	cmpi.w	#-$20,d4
	bgt.s	loc_3D734
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#-$10,d4
	blt.s	loc_3D734
	cmpi.w	#$10,d4
	blt.w	loc_3D84E

loc_3D734:
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#-$50,d4
	blt.w	loc_3D776
	cmpi.w	#$50,d4
	bgt.s	loc_3D776
	tst.b	(Berzerker_charging).w
	bne.w	loc_3D9A4
	cmpi.w	#-$30,d4
	blt.s	loc_3D776
	cmpi.w	#$30,d4
	bgt.s	loc_3D776
	move.w	y_pos(a4),d5
	sub.w	y_pos(a3),d5
	cmpi.w	#-4,d5
	blt.s	loc_3D776
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	beq.w	loc_3D826

loc_3D776:
	move.l	(Addr_GfxObject_KidProjectile).w,d4
	beq.s	loc_3D79C
	cmpi.w	#Maniaxe,(Current_Helmet).w
	bne.s	loc_3D79C
	move.l	d4,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#-$5A,d4
	blt.s	loc_3D79C
	cmpi.w	#$5A,d4
	blt.w	loc_3D826

loc_3D79C:
	tst.b	$4C(a5)
	beq.s	loc_3D7EE
	bpl.s	loc_3D7FA
	tst.l	(Addr_GfxObject_KidProjectile).w
	bne.s	loc_3D7EE
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#-$30,d4
	blt.s	loc_3D7CA
	cmpi.w	#$30,d4
	bgt.s	loc_3D7CA
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	beq.s	loc_3D7EE

loc_3D7CA:
	sf	$4C(a5)
	move.l	#stru_3D4EA,d7
	jsr	(j_Init_Animation).w
	st	is_animated(a3)
	move.l	$5E(a5),$50(a5)
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3D7EE:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3D7FA:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	y_pos(a4),d4
	sub.w	y_pos(a3),d4
	cmpi.w	#-$60,d4
	blt.s	loc_3D7CA
	tst.w	d4
	bge.s	loc_3D7CA
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#-$10,d4
	blt.s	loc_3D7CA
	cmpi.w	#$10,d4
	bgt.s	loc_3D7CA
	bra.s	loc_3D7EE
; ---------------------------------------------------------------------------

loc_3D826:
	st	$4C(a5)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7D8E-Data_Index),addroffset_sprite(a3)
	move.l	#0,$50(a5)
	sf	x_direction(a3)
	tst.w	d4
	bmi.w	loc_3D79C
	st	x_direction(a3)
	bra.w	loc_3D79C
; ---------------------------------------------------------------------------

loc_3D84E:
	sf	is_animated(a3)
	move.b	#1,$4C(a5)
	move.w	#(LnkTo_unk_C7D86-Data_Index),addroffset_sprite(a3)
	move.l	#0,$50(a5)
	sf	x_direction(a3)
	tst.w	d4
	bmi.w	loc_3D79C
	st	x_direction(a3)
	bra.w	loc_3D79C
; ---------------------------------------------------------------------------

loc_3D878:
	move.w	collision_type(a3),d4
	clr.w	collision_type(a3)
	tst.w	d4
	beq.s	loc_3D89C
	bmi.w	loc_3DB4E
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3D8A8
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3D8A8
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3D8BC

loc_3D89C:
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3D8A8:
	cmpi.w	#Berzerker,(Current_Helmet).w
	bne.s	loc_3D89C
	move.l	(Addr_GfxObject_Kid).w,a4
	cmpi.w	#(LnkTo_unk_ADFC8-Data_Index),$22(a4)
	bgt.s	loc_3D89C

loc_3D8BC:
	subq.w	#1,$44(a3)
	beq.w	loc_3D8D6
	move.l	#$18000,y_vel(a3)
	move.l	#0,x_vel(a3)
	bra.s	loc_3D89C
; ---------------------------------------------------------------------------

loc_3D8D6:
	move.l	#$18000,y_vel(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)

loc_3D8E6:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$1800,y_vel(a3)
	cmpi.w	#colid_floor,collision_type(a3)
	bne.s	loc_3D8E6
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	sf	is_moved(a3)
	sf	has_level_collision(a3)
	andi.l	#$FFFF0000,y_pos(a3)
	addi.w	#$F,y_pos(a3)
	andi.w	#$FFF0,y_pos(a3)
	bra.w	loc_3DB4E
; ---------------------------------------------------------------------------

loc_3D92A:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	sub.w	x_pos(a3),d4
	cmpi.w	#$80,d4
	bgt.s	loc_3D978
	cmpi.w	#-$80,d4
	blt.s	loc_3D978

loc_3D942:
	subq.w	#1,$54(a5)
	bne.s	loc_3D998
	cmpi.w	#(LnkTo_unk_C7DBE-Data_Index),addroffset_sprite(a3)
	bne.s	loc_3D958
	cmpi.w	#3,animation_timer(a3)
	beq.s	loc_3D960

loc_3D958:
	move.w	#1,$54(a5)
	bra.s	loc_3D998
; ---------------------------------------------------------------------------

loc_3D960:
	move.l	$6E(a5),d0
	swap	d0
	move.l	d0,$6E(a5)
	move.w	d0,$54(a5)
	tst.b	$4C(a5)
	bne.s	loc_3D998
	bra.w	loc_3D9A4
; ---------------------------------------------------------------------------

loc_3D978:
	tst.w	d4
	bmi.s	loc_3D98A
	tst.b	x_direction(a3)
	bne.s	loc_3D942
	eori.b	#$FF,x_direction(a3)
	bra.s	loc_3D942
; ---------------------------------------------------------------------------

loc_3D98A:
	tst.b	x_direction(a3)
	beq.s	loc_3D942
	eori.b	#$FF,x_direction(a3)
	bra.s	loc_3D942
; ---------------------------------------------------------------------------

loc_3D998:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3D9A4:
	clr.w	collision_type(a3)
	tst.b	x_direction(a3)
	bne.s	loc_3D9B8
	move.l	#-$18000,x_vel(a3)
	bra.s	loc_3D9C0
; ---------------------------------------------------------------------------

loc_3D9B8:
	move.l	#$10000,x_vel(a3)

loc_3D9C0:
	move.l	#-$48000,y_vel(a3)
	st	has_level_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7D6E-Data_Index),addroffset_sprite(a3)

loc_3D9DA:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$2800,y_vel(a3)
	cmpi.l	#-$8000,y_vel(a3)
	blt.s	loc_3DA0C
	cmpi.l	#$8000,y_vel(a3)
	bgt.s	loc_3DA06
	move.w	#(LnkTo_unk_C7D76-Data_Index),addroffset_sprite(a3)
	bra.s	loc_3DA0C
; ---------------------------------------------------------------------------

loc_3DA06:
	move.w	#(LnkTo_unk_C7D7E-Data_Index),addroffset_sprite(a3)

loc_3DA0C:
	move.w	collision_type(a3),d4
	clr.w	collision_type(a3)
	cmpi.w	#colid_floor,d4
	beq.s	loc_3DA56
	cmpi.w	#colid_rightwall,d4
	beq.s	loc_3DA46
	cmpi.w	#colid_leftwall,d4
	beq.s	loc_3DA46
	cmpi.w	#colid_ceiling,d4
	beq.w	loc_3DAB0
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3DA98
	cmpi.w	#colid_kidright,d4
	beq.w	loc_3DB0A
	cmpi.w	#colid_kidleft,d4
	beq.w	loc_3DB0A
	bra.s	loc_3D9DA
; ---------------------------------------------------------------------------

loc_3DA46:
	clr.w	collision_type(a3)
	neg.l	x_vel(a3)
	eori.b	#$FF,x_direction(a3)
	bra.s	loc_3D9DA
; ---------------------------------------------------------------------------

loc_3DA56:
	clr.w	collision_type(a3)
	move.l	#0,x_vel(a3)
	move.l	#0,y_vel(a3)
	move.l	#stru_3D4EA,d7
	jsr	(j_Init_Animation).w
	clr.w	collision_type(a3)
	move.l	#0,y_vel(a3)
	sf	is_moved(a3)
	sf	has_level_collision(a3)
	st	is_animated(a3)
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3DA98:
	move.l	#$38000,y_vel(a3)
	subi.w	#1,$44(a3)
	beq.s	loc_3DABC
	clr.w	collision_type(a3)
	bra.w	loc_3D9DA
; ---------------------------------------------------------------------------

loc_3DAB0:
	clr.w	collision_type(a3)
	neg.l	y_vel(a3)
	bra.w	loc_3D9DA
; ---------------------------------------------------------------------------

loc_3DABC:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$1800,y_vel(a3)
	cmpi.w	#colid_floor,collision_type(a3)
	bne.s	loc_3DABC
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	sf	is_moved(a3)
	sf	has_level_collision(a3)
	andi.l	#$FFFF0000,y_pos(a3)
	addi.w	#$F,y_pos(a3)
	andi.w	#$FFF0,y_pos(a3)
	bra.s	loc_3DB4E
; ---------------------------------------------------------------------------
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3DB0A:
	tst.b	(Berzerker_charging).w
	beq.w	loc_3D9DA
	st	has_kid_collision(a3)
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7D7E-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3DB3C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3DB3C
; ---------------------------------------------------------------------------

loc_3DB4E:
	move.l	#stru_3D50A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956