;stru_3E98E: 
	include "ingame/anim/enemy/Mini_Hopping_Skull.asm"

;loc_3E9C8:
Enemy1C_MiniHoppingSkull_Init: 
	move.l	(Addr_GfxObject_Kid).w,a0
	move.l	$44(a5),a1

loc_3E9D0:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	$1A(a0),d4
	sub.w	4(a1),d4
	cmpi.w	#$FFB0,d4
	blt.s	loc_3E9D0
	cmpi.w	#$50,d4
	bgt.s	loc_3E9D0
	move.w	$1E(a0),d4
	sub.w	6(a1),d4
	blt.s	loc_3E9D0
	cmpi.w	#$A0,d4
	bgt.s	loc_3E9D0
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	2(a1),enemy_level(a3)
	move.w	4(a1),x_pos(a3)
	move.w	6(a1),y_pos(a3)
	bsr.w	sub_36FF4
	move.w	#$1C,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	$40(a3),d7
	addq.w	#1,d7
	move.w	d7,$44(a3)
	tst.b	$19(a3)
	bne.s	loc_3EA48
	moveq	#sfx_Mini_Hopping_Skull_screams,d0
	jsr	(j_PlaySound).l

loc_3EA48:
	st	$13(a3)
	move.w	#(LnkTo_unk_C8050-Data_Index),addroffset_sprite(a3)
	move.w	#$A,-(sp)
	jsr	(j_Hibernate_Object).w
	st	has_level_collision(a3)
	st	is_moved(a3)
	move.l	#stru_3E98E,d7
	jsr	(j_Init_Animation).w
	move.l	#$28000,y_vel(a3)
	move.l	#$1200,d3
	tst.w	$40(a3)
	beq.s	loc_3EA88
	addi.l	#$1000,y_vel(a3)

loc_3EA88:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	add.l	d3,y_vel(a3)
	tst.b	is_animated(a3)
	bne.s	loc_3EAB2
	tst.w	y_vel(a3)
	bpl.s	loc_3EAAC
	move.w	#(LnkTo_unk_C8080-Data_Index),addroffset_sprite(a3)
	bra.s	loc_3EAB2
; ---------------------------------------------------------------------------

loc_3EAAC:
	move.w	#(LnkTo_unk_C8088-Data_Index),addroffset_sprite(a3)

loc_3EAB2:
	move.w	collision_type(a3),d4
	beq.s	loc_3EA88
	cmpi.w	#colid_hurt,d4
	bge.w	loc_3F1B8
	cmpi.w	#colid_leftwall,d4
	ble.w	loc_3F1AA
	cmpi.w	#colid_floor,d4
	beq.w	loc_3EFEC
	cmpi.w	#colid_ceiling,d4
	beq.w	loc_3F1A2

loc_3EAD8:
	sf	is_moved(a3)
	sf	is_animated(a3)
	sf	has_level_collision(a3)
	cmpi.w	#colid_slopeup,d4
	bne.w	loc_3ED6C
	bsr.w	sub_3F366
	tst.w	x_vel(a3)
	ble.w	loc_3EC32
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)

loc_3EB00:
	st	x_direction(a3)
	move.w	#(LnkTo_unk_C8030-Data_Index),addroffset_sprite(a3)
	move.w	#$14,d1

loc_3EB0E:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EB78
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EB60
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EB60
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EB56
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EB56
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EB78

loc_3EB40:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EB78
; ---------------------------------------------------------------------------

loc_3EB56:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EB40
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EB60:
	subi.w	#1,$44(a3)
	beq.w	loc_3F176
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EB78:
	dbf	d1,loc_3EB0E
	move.w	$1A(a0),d4
	cmp.w	x_pos(a3),d4
	ble.w	loc_3EC32
	move.w	#(LnkTo_unk_C8038-Data_Index),addroffset_sprite(a3)
	move.w	#$A,d1

loc_3EB92:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EBFC
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EBE4
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EBE4
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EBDA
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EBDA
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EBFC

loc_3EBC4:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EBFC
; ---------------------------------------------------------------------------

loc_3EBDA:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EBC4
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EBE4:
	subi.w	#1,$44(a3)
	beq.w	loc_3F176
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EBFC:
	dbf	d1,loc_3EB92
	move.l	#$FFFC8000,y_vel(a3)
	move.l	#$18000,x_vel(a3)
	tst.w	$40(a3)
	beq.s	loc_3EC26
	addi.l	#-$10000,y_vel(a3)
	addi.l	#$4000,x_vel(a3)

loc_3EC26:
	st	is_moved(a3)
	st	has_level_collision(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3EC32:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	x_direction(a3)
	move.w	#(LnkTo_unk_C8010-Data_Index),addroffset_sprite(a3)
	move.w	#$14,d1

loc_3EC48:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3ECB2
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EC9A
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EC9A
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EC90
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EC90
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3ECB2

loc_3EC7A:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3ECB2
; ---------------------------------------------------------------------------

loc_3EC90:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EC7A
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EC9A:
	subi.w	#1,$44(a3)
	beq.w	loc_3F18C
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3ECB2:
	dbf	d1,loc_3EC48
	move.w	$1A(a0),d4
	cmp.w	x_pos(a3),d4
	bgt.w	loc_3EB00
	move.w	#(LnkTo_unk_C8018-Data_Index),addroffset_sprite(a3)
	move.w	#$A,d1

loc_3ECCC:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3ED36
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3ED1E
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3ED1E
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3ED14
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3ED14
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3ED36

loc_3ECFE:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3ED36
; ---------------------------------------------------------------------------

loc_3ED14:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3ECFE
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3ED1E:
	subi.w	#1,$44(a3)
	beq.w	loc_3F18C
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3ED36:
	dbf	d1,loc_3ECCC
	move.l	#$FFFC8000,y_vel(a3)
	move.l	#$FFFE8000,x_vel(a3)
	tst.w	$40(a3)
	beq.s	loc_3ED60
	addi.l	#-$10000,y_vel(a3)
	addi.l	#-$4000,x_vel(a3)

loc_3ED60:
	st	is_moved(a3)
	st	has_level_collision(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3ED6C:
	bsr.w	sub_3F3A6
	tst.w	x_vel(a3)
	bge.w	loc_3EEB2
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)

loc_3ED80:
	sf	x_direction(a3)
	move.w	#(LnkTo_unk_C8030-Data_Index),addroffset_sprite(a3)
	move.w	#$14,d1

loc_3ED8E:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EDF8
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EDE0
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EDE0
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EDD6
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EDD6
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EDF8

loc_3EDC0:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EDF8
; ---------------------------------------------------------------------------

loc_3EDD6:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EDC0
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EDE0:
	subi.w	#1,$44(a3)
	beq.w	loc_3F176
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EDF8:
	dbf	d1,loc_3ED8E
	move.w	$1A(a0),d4
	cmp.w	x_pos(a3),d4
	bgt.w	loc_3EEB2
	move.w	#(LnkTo_unk_C8038-Data_Index),addroffset_sprite(a3)
	move.w	#$A,d1

loc_3EE12:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EE7C
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EE64
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EE64
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EE5A
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EE5A
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EE7C

loc_3EE44:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EE7C
; ---------------------------------------------------------------------------

loc_3EE5A:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EE44
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EE64:
	subi.w	#1,$44(a3)
	beq.w	loc_3F176
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EE7C:
	dbf	d1,loc_3EE12
	move.l	#$FFFC8000,y_vel(a3)
	move.l	#$FFFE8000,x_vel(a3)
	tst.w	$40(a3)
	beq.s	loc_3EEA6
	addi.l	#-$10000,y_vel(a3)
	addi.l	#-$4000,x_vel(a3)

loc_3EEA6:
	st	is_moved(a3)
	st	has_level_collision(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3EEB2:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	st	x_direction(a3)
	move.w	#(LnkTo_unk_C8010-Data_Index),addroffset_sprite(a3)
	move.w	#$14,d1

loc_3EEC8:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EF32
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EF1A
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EF1A
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EF10
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EF10
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EF32

loc_3EEFA:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EF32
; ---------------------------------------------------------------------------

loc_3EF10:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EEFA
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EF1A:
	subi.w	#1,$44(a3)
	beq.w	loc_3F18C
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EF32:
	dbf	d1,loc_3EEC8
	move.w	$1A(a0),d4
	cmp.w	x_pos(a3),d4
	ble.w	loc_3ED80
	move.w	#(LnkTo_unk_C8018-Data_Index),addroffset_sprite(a3)
	move.w	#$A,d1

loc_3EF4C:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3EFB6
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3EF9E
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3EF9E
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3EF94
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3EF94
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3EFB6

loc_3EF7E:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3EFB6
; ---------------------------------------------------------------------------

loc_3EF94:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3EF7E
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3EF9E:
	subi.w	#1,$44(a3)
	beq.w	loc_3F18C
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3EFB6:
	dbf	d1,loc_3EF4C
	move.l	#$FFFC8000,y_vel(a3)
	move.l	#$18000,x_vel(a3)
	tst.w	$40(a3)
	beq.s	loc_3EFE0
	addi.l	#-$10000,y_vel(a3)
	addi.l	#$4000,x_vel(a3)

loc_3EFE0:
	st	is_moved(a3)
	st	has_level_collision(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3EFEC:
	sf	is_moved(a3)
	sf	is_animated(a3)
	sf	has_level_collision(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)

loc_3F000:
	move.w	#(LnkTo_unk_C8070-Data_Index),addroffset_sprite(a3)
	move.w	#$14,d1

loc_3F00A:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3F074
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3F05C
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3F05C
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3F052
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3F052
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3F074

loc_3F03C:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3F074
; ---------------------------------------------------------------------------

loc_3F052:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3F03C
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3F05C:
	subi.w	#1,$44(a3)
	beq.w	loc_3F158
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3F074:
	dbf	d1,loc_3F00A
	move.w	$1A(a0),d4
	cmp.w	x_pos(a3),d4
	bgt.s	loc_3F090
	tst.b	x_direction(a3)
	beq.s	loc_3F09E
	sf	x_direction(a3)
	bra.w	loc_3F000
; ---------------------------------------------------------------------------

loc_3F090:
	tst.b	x_direction(a3)
	bne.s	loc_3F09E
	st	x_direction(a3)
	bra.w	loc_3F000
; ---------------------------------------------------------------------------

loc_3F09E:
	move.w	#(LnkTo_unk_C8078-Data_Index),addroffset_sprite(a3)
	move.w	#$A,d1

loc_3F0A8:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3F29A
	move.w	collision_type(a3),d4
	beq.s	loc_3F112
	cmpi.w	#colid_kidabove,d4
	beq.w	loc_3F0FA
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3F0FA
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3F0F0
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3F0F0
	cmpi.w	#colid_kidbelow,d4
	bne.s	loc_3F112

loc_3F0DA:
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.s	loc_3F112
; ---------------------------------------------------------------------------

loc_3F0F0:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3F0DA
	bra.w	loc_3F262
; ---------------------------------------------------------------------------

loc_3F0FA:
	subi.w	#1,$44(a3)
	beq.w	loc_3F158
	move.l	#stru_3E9C2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_3F112:
	dbf	d1,loc_3F0A8
	move.l	#$FFFC8000,y_vel(a3)
	move.l	#$18000,x_vel(a3)
	tst.w	$40(a3)
	beq.s	loc_3F13C
	addi.l	#-$10000,y_vel(a3)
	addi.l	#$4000,x_vel(a3)

loc_3F13C:
	tst.b	x_direction(a3)
	bne.s	loc_3F146
	neg.l	x_vel(a3)

loc_3F146:
	move.w	#(LnkTo_unk_C8080-Data_Index),addroffset_sprite(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3F158:
	tst.w	$44(a3)
	bne.w	loc_3EFEC
	sf	is_moved(a3)
	move.l	#stru_3E9AC,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	bra.w	loc_3F32E
; ---------------------------------------------------------------------------

loc_3F176:
	sf	is_moved(a3)
	move.l	#stru_3E998,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	bra.w	loc_3F32E
; ---------------------------------------------------------------------------

loc_3F18C:
	sf	is_moved(a3)
	move.l	#stru_3E9A2,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	bra.w	loc_3F32E
; ---------------------------------------------------------------------------

loc_3F1A2:
	neg.l	y_vel(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3F1AA:
	eori.b	#$FF,x_direction(a3)
	neg.l	x_vel(a3)
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3F1B8:
	beq.s	loc_3F1E6
	cmpi.w	#$20,d4
	beq.w	loc_3F244
	cmpi.w	#$24,d4
	beq.s	loc_3F244
	cmpi.w	#$2C,d4
	beq.s	loc_3F1E6
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3F1E6:
	subi.w	#1,$44(a3)
	move.l	#$28800,y_vel(a3)
	move.l	x_vel(a3),d2
	clr.l	x_vel(a3)
	clr.w	collision_type(a3)

loc_3F200:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$4000,y_vel(a3)
	move.w	collision_type(a3),d4
	beq.s	loc_3F200
	clr.w	collision_type(a3)
	cmpi.w	#colid_floor,d4
	beq.w	loc_3F158
	cmpi.w	#colid_slopeup,d4
	beq.s	loc_3F22A
	cmpi.w	#colid_slopedown,d4
	bne.s	loc_3F200

loc_3F22A:
	tst.w	$44(a3)
	beq.s	loc_3F238
	move.l	d2,x_vel(a3)
	bra.w	loc_3EAD8
; ---------------------------------------------------------------------------

loc_3F238:
	swap	d2
	tst.w	d2
	ble.w	loc_3F18C
	bra.w	loc_3F176
; ---------------------------------------------------------------------------

loc_3F244:
	tst.b	(Berzerker_charging).w
	bne.s	loc_3F262
	exg	a0,a4
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3F3F0,4(a0)
	exg	a0,a4
	bra.w	loc_3EA88
; ---------------------------------------------------------------------------

loc_3F262:
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C8040-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3F288:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3F288

; =============== S U B	R O U T	I N E =======================================


sub_3F29A:
	cmpi.w	#$FFE0,x_pos(a3)
	ble.s	loc_3F300
	cmpi.w	#$FFE0,y_pos(a3)
	ble.s	loc_3F300
	move.w	(Level_width_pixels).w,d7
	addi.w	#$20,d7
	cmp.w	x_pos(a3),d7
	blt.s	loc_3F300
	move.w	(Level_height_pixels).w,d7
	addi.w	#$20,d7
	cmp.w	y_pos(a3),d7
	blt.s	loc_3F300
	cmpi.w	#$A,(Number_Objects).w
	ble.s	return_3F2FE
	cmpi.w	#$14,(Number_Objects).w
	ble.s	loc_3F304
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FFC0,d0
	blt.s	loc_3F300
	cmpi.w	#$180,d0
	bgt.s	loc_3F300
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FFC0,d0
	blt.s	loc_3F300
	cmpi.w	#$120,d0
	bgt.s	loc_3F300

return_3F2FE:
	rts
; ---------------------------------------------------------------------------

loc_3F300:
	bra.w	loc_3F32E
; ---------------------------------------------------------------------------

loc_3F304:
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3F300
	cmpi.w	#$2E4,d0
	bgt.s	loc_3F300
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3F300
	cmpi.w	#$284,d0
	bgt.s	loc_3F300
	rts
; ---------------------------------------------------------------------------

loc_3F32E:
	moveq	#0,d0
	subi.w	#1,(Number_of_Enemy).w
	move.b	$42(a5),d0
	bpl.s	loc_3F354
	btst	#6,d0
	beq.s	loc_3F362
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3F362
; ---------------------------------------------------------------------------

loc_3F354:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_3F362:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3F29A


; =============== S U B	R O U T	I N E =======================================


sub_3F366:
	move.w	x_pos(a3),d6
	move.w	y_pos(a3),d7
	move.w	d7,d5
	asr.w	#4,d5
	add.w	d5,d5
	lea	($FFFF4A04).l,a4
	move.w	(a4,d5.w),a4
	move.w	d6,d5
	asr.w	#4,d5
	add.w	d5,d5
	add.w	d5,a4

loc_3F386:
	addi.w	#$10,d6
	move.w	(a4)+,d5
	andi.w	#$7000,d5
	cmpi.w	#$4000,d5
	bne.s	loc_3F386
	andi.w	#$F,d7
	andi.w	#$FFF0,d6
	sub.w	d7,d6
	move.w	d6,x_pos(a3)
	rts
; End of function sub_3F366


; =============== S U B	R O U T	I N E =======================================


sub_3F3A6:
	move.w	x_pos(a3),d6
	move.w	y_pos(a3),d7
	move.w	d7,d5
	asr.w	#4,d5
	add.w	d5,d5
	lea	($FFFF4A04).l,a4
	move.w	(a4,d5.w),a4
	move.w	d6,d5
	asr.w	#4,d5
	add.w	d5,d5
	add.w	d5,a4
	addi.w	#2,a4
	addi.w	#$20,d6

loc_3F3CE:
	move.w	(a4),d5
	subi.w	#$10,d6
	subq.w	#2,a4
	andi.w	#$7000,d5
	cmpi.w	#$5000,d5
	bne.s	loc_3F3CE
	andi.w	#$F,d7
	andi.w	#$FFF0,d6
	add.w	d7,d6
	move.w	d6,x_pos(a3)
	rts
; End of function sub_3F3A6


; =============== S U B	R O U T	I N E =======================================


sub_3F3F0:
	move.w	#$F,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	$19(a3)
	bne.s	loc_3F406
	moveq	#sfx_Mini_Hopping_Skull_screams,d0
	jsr	(j_PlaySound).l

loc_3F406:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3F3F0