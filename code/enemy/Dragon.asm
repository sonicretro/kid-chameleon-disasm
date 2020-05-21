;stru_3CC5E: 
	include "ingame/anim/enemy/Dragon.asm"
; ---------------------------------------------------------------------------
loc_3CD16: ;this first label comes from flaying dragon
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.b	$48(a5),x_direction(a3)
	move.w	$4A(a5),$40(a3)
	st	$5C(a5)
	bra.w	loc_3CD70
; ---------------------------------------------------------------------------

;loc_3CD46:
Enemy0D_Dragon_Init: 
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a4
	move.w	2(a4),enemy_level(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4

loc_3CD70:
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3CD82
	st	x_direction(a3)

loc_3CD82:
	move.w	#$D,d5
	move.w	#$C,d6
	move.w	d5,object_meta(a3)
	move.l	(Addr_EnemyLayoutHeader).w,a4
	moveq	#0,d4
	move.w	2(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3CDB8
	cmp.w	d3,d6
	beq.s	loc_3CDB8
	addq.w	#1,d4
	move.w	4(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3CDB8
	cmp.w	d3,d6
	beq.s	loc_3CDB8
	addq.w	#1,d4

loc_3CDB8:
	lea	EnemyArt_PaletteLines(pc),a4
	move.b	(a4,d4.w),palette_line(a3)
	lea	EnemyArt_VRAMTileAddresses(pc),a4
	add.w	d4,d4
	move.w	(a4,d4.w),vram_tile(a3)
	move.w	d4,$3E(a3)
	st	$13(a3)
	move.b	#0,priority(a3)
	move.w	enemy_level(a3),d7
	addq.w	#1,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	bne.s	loc_3CDFC
	move.l	#$10000,$50(a5)
	move.l	#$10000,$5E(a5)

loc_3CDFC:
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)
	move.w	#$10,$4A(a5)
	move.w	#9,$48(a5)
	move.l	#$32012C,$6E(a5)
	move.w	#$32,$54(a5)
	move.l	#loc_3DEA0,$6A(a5)
	cmpi.w	#3,d7
	bne.s	loc_3CE48
	move.l	#stru_3CC90,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3CC90,$62(a5)
	bra.s	loc_3CE5A
; ---------------------------------------------------------------------------

loc_3CE48:
	move.l	#stru_3CC5E,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3CC5E,$62(a5)

loc_3CE5A:
	move.w	#$A,$42(a3)
	move.w	#$12C,$66(a5)
	move.w	#$12C,$54(a5)
	move.l	#loc_3CE90,a0
	tst.b	$5C(a5)
	beq.s	loc_3CE84
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3CE84:
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3CE90:
	subi.w	#1,$66(a5)
	beq.w	loc_3CF6E

loc_3CE9A:
	move.w	collision_type(a3),d4
	bmi.s	loc_3CEE4
	beq.w	loc_3CF4C
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3CEBE
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3CF0E
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3CF0E
	cmpi.w	#colid_kidabove,d4
	bne.w	loc_3CF4C

loc_3CEBE:
	subq.w	#1,$44(a3)
	ble.s	loc_3CEE4
	tst.b	$5C(a5)
	bne.w	loc_3CF4C
	move.l	#stru_3CCE6,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3CF4C
; ---------------------------------------------------------------------------

loc_3CEE4:
	cmpi.w	#$FFFF,d4
	beq.s	loc_3CEFC
	st	has_kid_collision(a3)
	tst.b	$5C(a5)
	beq.s	loc_3CEFC
	move.w	#$FFFE,collision_type(a3)
	bra.s	loc_3CF50
; ---------------------------------------------------------------------------

loc_3CEFC:
	move.l	#stru_3CCEC,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_UntilAnimFinished).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3CF0E:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3CF4C
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C755E-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3CF3A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3CF3A
; ---------------------------------------------------------------------------

loc_3CF4C:
	clr.w	collision_type(a3)

loc_3CF50:
	tst.b	$5C(a5)
	beq.s	loc_3CF62
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3CF62:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3CF6E:
	move.w	#$1F4,$66(a5)
	move.b	#0,$5B(a5)
	tst.b	$5C(a5)
	bne.w	loc_3D00C
	tst.b	$19(a3)
	bne.s	loc_3CF90
	moveq	#sfx_Dragon_flame_breath,d0  ; NO SOUND!
	jsr	(j_PlaySound).l

loc_3CF90:
	exg	a0,a1
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3D02A,4(a0)
	exg	a0,a1
	move.l	#stru_3CCC2,d7
	jsr	(j_Init_Animation).w

loc_3CFAE:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d4
	bmi.w	loc_3CE9A
	beq.s	loc_3CFE4
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3CFDA
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3CFDA
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3CFD4
	cmpi.w	#colid_kidleft,d4
	bne.s	loc_3CFE4

loc_3CFD4:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3CFE4

loc_3CFDA:
	move.b	#1,$5B(a1)
	bra.w	loc_3CE9A
; ---------------------------------------------------------------------------

loc_3CFE4:
	move.b	$5B(a5),d4
	beq.s	loc_3CFAE
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#2,$40(a3)
	bne.s	loc_3D002
	move.l	#stru_3CC90,d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3D00C
; ---------------------------------------------------------------------------

loc_3D002:
	move.l	#stru_3CC5E,d7
	jsr	(j_Init_Animation).w

loc_3D00C:
	tst.b	$5C(a5)
	beq.s	loc_3D01E
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3D01E:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3D02A:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	st	$13(a3)
	move.b	$11(a0),palette_line(a3)
	move.w	$3E(a0),$3E(a3)
	move.w	$16(a0),x_direction(a3)
	move.w	$24(a0),vram_tile(a3)
	move.w	#-$1C,d0
	tst.b	$16(a0)
	beq.s	loc_3D070
	neg.w	d0

loc_3D070:
	add.w	d0,x_pos(a3)
	st	$13(a3)
	move.l	#stru_3CCC8,d7
	jsr	(j_Init_Animation).w

loc_3D082:
	jsr	(j_Hibernate_Object_1Frame).w
	move.b	$5B(a5),d0
	bne.w	loc_3D09E
	tst.b	$18(a3)
	beq.s	loc_3D082
	move.l	$A(a5),a0
	move.b	#1,$5B(a0)

loc_3D09E:
	jmp	(j_Delete_CurrentObject).w