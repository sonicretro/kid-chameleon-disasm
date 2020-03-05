;stru_3C97C: 
	include "ingame/anim/enemy/Goat.asm"

;loc_3C9F8:
Enemy10_Goat_Init: 
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a4
	move.w	2(a4),enemy_hp(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3CA30
	st	x_direction(a3)

loc_3CA30:
	st	$13(a3)
	move.w	#$10,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	enemy_hp(a3),d7
	addq.w	#3,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#4,d7
	blt.s	loc_3CA7E
	beq.s	loc_3CA6E
	move.w	#1,$4C(a5)
	move.l	#$10000,$50(a5)
	addi.l	#$10000,$5E(a5)

loc_3CA6E:
	addi.l	#$10000,$50(a5)
	addi.l	#$10000,$5E(a5)

loc_3CA7E:
	addi.w	#3,$4C(a5)
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)
	move.w	#$10,$4A(a5)
	move.w	#9,$48(a5)
	move.l	#loc_3CC18,$6A(a5)
	cmpi.w	#4,d7
	bge.s	loc_3CACA
	move.l	#stru_3C97C,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C97C,$62(a5)
	move.l	#stru_3C9B0,$66(a5)
	bra.s	loc_3CB02
; ---------------------------------------------------------------------------

loc_3CACA:
	bgt.s	loc_3CAE8
	move.l	#stru_3C996,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C996,$62(a5)
	move.l	#stru_3C9B0,$66(a5)
	bra.s	loc_3CB02
; ---------------------------------------------------------------------------

loc_3CAE8:
	move.l	#stru_3C996,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C996,$62(a5)
	move.l	#stru_3C9CA,$66(a5)

loc_3CB02:
	move.l	#loc_3CB14,a0
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3CB14:
	move.w	collision_type(a3),d4
	bmi.s	loc_3CB64
	beq.w	loc_3CBF6
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3CB38
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3CB76
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3CB76
	cmpi.w	#colid_kidabove,d4
	bne.w	loc_3CBF6

loc_3CB38:
	subq.w	#1,$44(a3)
	beq.s	loc_3CB64
	move.l	#stru_3C9E4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3CBF6
; ---------------------------------------------------------------------------

loc_3CB64:
	move.l	#stru_3C9EA,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3CB76:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3CBF6
	tst.w	$42(a3)
	bgt.s	loc_3CBBA
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7C56-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3CBA8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3CBA8
; ---------------------------------------------------------------------------

loc_3CBBA:
	tst.b	x_direction(a3)
	bne.s	loc_3CBC8
	addi.w	#$14,x_pos(a3)
	bra.s	loc_3CBCE
; ---------------------------------------------------------------------------

loc_3CBC8:
	subi.w	#$14,x_pos(a3)

loc_3CBCE:
	move.l	#stru_3C9E4,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bclr	#7,object_meta(a3)

loc_3CBF6:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3CC0C
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3CC0C:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3CC18:
	tst.w	$42(a3)
	bgt.s	loc_3CC52
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d7
	sub.w	x_pos(a4),d7
	cmpi.w	#$20,d7
	bgt.s	loc_3CC36
	cmpi.w	#$FFE0,d7
	bge.s	loc_3CC52

loc_3CC36:
	tst.w	d7
	bge.s	loc_3CC46
	tst.b	x_direction(a3)
	bne.w	loc_3E3B2
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3CC46:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E546
; ---------------------------------------------------------------------------

loc_3CC52:
	tst.b	x_direction(a3)
	beq.w	loc_3E566
	bra.w	loc_3E3B2