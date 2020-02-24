;loc_3DB9C:
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
	blt.s	loc_3DBD8
	st	x_direction(a3)

loc_3DBD8:
	st	$13(a3)
	move.w	#$13,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	enemy_hp(a3),d7
	addi.w	#3,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#2,enemy_hp(a3)
	move.l	#$18000,$50(a5)
	move.l	#$18000,$5E(a5)
	move.w	#$16,$4A(a5)
	move.w	#9,$48(a5)
	move.l	#loc_3DD7E,$6A(a5)
	move.l	#stru_3DB60,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3DB60,$62(a5)
	move.w	#$A,$42(a3)
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3A(a5)
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	subi.w	#$16,$1E(a1)
	subi.w	#1,$1A(a1)
	move.w	#(LnkTo_unk_C7E1E-Data_Index),$22(a1)
	move.w	#$4013,$3A(a1)
	move.w	#1,$54(a5)
	move.l	#loc_3DC86,a0
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3DC86:
	move.l	$3A(a5),a4
	move.w	x_pos(a3),x_pos(a4)
	move.w	y_pos(a3),y_pos(a4)
	subi.w	#$16,y_pos(a4)
	tst.b	x_direction(a3)
	bne.s	loc_3DCAA
	subi.w	#1,x_pos(a4)
	bra.s	loc_3DCB0
; ---------------------------------------------------------------------------

loc_3DCAA:
	subi.w	#$16,x_pos(a4)

loc_3DCB0:
	move.w	collision_type(a3),d4
	beq.w	loc_3DD5C
	bmi.s	loc_3DCF4
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3DD0E
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3DD0E
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3DCD4
	cmpi.w	#colid_kidabove,d4
	bne.w	loc_3DD5C

loc_3DCD4:
	subq.w	#1,$44(a3)
	beq.s	loc_3DCF4
	move.l	#stru_3DB7A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3DB60,d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3DD5C
; ---------------------------------------------------------------------------

loc_3DCF4:
	move.l	$3A(a5),a4
	st	$3D(a4)
	move.l	#stru_3DB80,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3DD0E:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3DD5C
	cmpi.w	#(LnkTo_unk_C7E0E-Data_Index),addroffset_sprite(a3)
	bge.s	loc_3DD5C
	move.l	$3A(a5),a4
	st	$3D(a4)
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7DD6-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3DD4A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3DD4A
; ---------------------------------------------------------------------------

loc_3DD5C:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3DD72
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3DD72:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3DD7E:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d4
	move.w	x_pos(a4),d3
	sub.w	d3,d4
	move.w	y_pos(a3),d5
	sub.w	y_pos(a4),d5
	tst.b	$4E(a5)
	bne.s	loc_3DDA8
	tst.w	d4
	bmi.s	loc_3DDA4
	sf	x_direction(a3)
	bra.s	loc_3DDA8
; ---------------------------------------------------------------------------

loc_3DDA4:
	st	x_direction(a3)

loc_3DDA8:
	cmpi.w	#$AA,d4
	bgt.w	loc_3DE7E
	cmpi.w	#$FF56,d4
	blt.w	loc_3DE7E
	cmpi.w	#1,$40(a3)
	ble.s	loc_3DDC8
	move.l	#$38000,$50(a5)

loc_3DDC8:
	cmpi.w	#$24,d4
	bgt.w	loc_3DE64
	cmpi.w	#$FFDC,d4
	blt.w	loc_3DE64
	tst.w	d4
	bmi.s	loc_3DDE6
	tst.b	x_direction(a3)
	beq.s	loc_3DDEE
	bra.w	loc_3DE64
; ---------------------------------------------------------------------------

loc_3DDE6:
	tst.b	x_direction(a3)
	beq.w	loc_3DE64

loc_3DDEE:
	st	$4E(a5)
	cmpi.w	#$FFE0,d5
	blt.w	loc_3DE96
	cmpi.w	#$30,d5
	bgt.w	loc_3DE96
	cmpi.w	#1,$40(a3)
	blt.s	loc_3DE3C
	move.l	$3A(a5),a4
	st	$3D(a4)
	move.l	#0,$50(a5)
	ori.w	#$C000,object_meta(a3)
	move.l	#0,$50(a5)
	ori.w	#$C000,object_meta(a3)
	move.l	#stru_3DB8E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w

loc_3DE3C:
	cmp.w	a2,d3
	beq.s	loc_3DE6C

loc_3DE40:
	move.l	$3A(a5),a4
	sf	$3D(a4)
	move.w	#(LnkTo_unk_C7DDE-Data_Index),addroffset_sprite(a3)
	move.l	#stru_3DB60,d7
	jsr	(j_Init_Animation).w
	move.l	$5E(a5),$50(a5)
	andi.w	#$FFF,object_meta(a3)

loc_3DE64:
	cmpi.w	#(LnkTo_unk_C7E0E-Data_Index),addroffset_sprite(a3)
	bge.s	loc_3DE3C

loc_3DE6C:
	move.w	d3,a2
	clr.w	collision_type(a3)
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2
; ---------------------------------------------------------------------------

loc_3DE7E:
	move.l	#$18000,$50(a5)
	move.l	(Addr_GfxObject_Kid).w,a4
	tst.l	$26(a4)
	beq.s	loc_3DE64
	sf	$4E(a5)
	bra.s	loc_3DE64
; ---------------------------------------------------------------------------

loc_3DE96:
	cmpi.w	#(LnkTo_unk_C7E0E-Data_Index),addroffset_sprite(a3)
	bge.s	loc_3DE40
	bra.s	loc_3DE6C
; ---------------------------------------------------------------------------

loc_3DEA0:
	tst.w	$42(a3)
	ble.s	loc_3DEAE
	cmpi.w	#$A,$42(a3)
	bne.s	loc_3DECE

loc_3DEAE:
	subq.w	#1,$54(a5)
	bne.s	loc_3DECE
	move.l	$6E(a5),d0
	swap	d0
	move.l	d0,$6E(a5)
	move.w	d0,$54(a5)
	tst.b	x_direction(a3)
	beq.w	loc_3E392
	bra.w	loc_3E546
; ---------------------------------------------------------------------------

loc_3DECE:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2