;stru_3BCB2: 
	include "ingame/anim/enemy/Driller.asm"

;loc_3BCF0:
Enemy1A_Driller_Init: 
	jsr	(j_Hibernate_Object_1Frame).w
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
	blt.s	loc_3BD2A
	st	x_direction(a3)

loc_3BD2A:
	st	$13(a3)
	st	is_animated(a3)
	move.w	#$1A,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	#$10,$4A(a5)
	move.w	#$C,$48(a5)
	move.w	enemy_hp(a3),d7
	addi.w	#2,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	blt.s	loc_3BD74
	beq.s	loc_3BD6C
	move.l	#$8000,$50(a5)

loc_3BD6C:
	addi.l	#$8000,$50(a5)

loc_3BD74:
	addi.l	#$8000,$50(a5)
	move.l	#stru_3BCB2,d7
	jsr	(j_Init_Animation).w
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3A(a5)
	st	$13(a1)
	st	$3C(a1)
	move.b	palette_line(a3),$11(a1)
	move.w	$3E(a3),$3E(a1)
	move.w	vram_tile(a3),$24(a1)
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	move.l	#$FFFF8000,$26(a1)
	subi.w	#$18,$1A(a1)
	move.w	object_meta(a3),$3A(a1)
	bset	#6,$3A(a1)
	exg	a1,a3
	move.l	#stru_3BCBC,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3E(a5)
	st	$13(a1)
	st	$16(a1)
	st	$3C(a1)
	move.b	palette_line(a3),$11(a1)
	move.w	$3E(a3),$3E(a1)
	move.w	vram_tile(a3),$24(a1)
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	move.l	#$8000,$26(a1)
	addi.w	#$18,$1A(a1)
	move.w	object_meta(a3),$3A(a1)
	bset	#6,$3A(a1)
	exg	a1,a3
	move.l	#stru_3BCBC,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	lea	($FFFFFA34).w,a4
	tst.b	(a4,d5.w)
	bne.s	loc_3BE60
	tst.b	$19(a3)
	bne.s	loc_3BE60
	moveq	#sfx_Drill_moving,d0
	jsr	(j_PlaySound).l

loc_3BE60:
	addi.b	#1,(a4,d5.w)
	move.l	#loc_3BE78,a0
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3BE78:
	move.l	$3A(a5),a4
	moveq	#1,d0
	moveq	#8,d1
	tst.b	x_direction(a3)
	beq.s	loc_3BE8E
	move.l	$3E(a5),a4
	moveq	#3,d0
	moveq	#4,d1

loc_3BE8E:
	move.w	$38(a4),d4
	beq.w	loc_3BF02
	cmp.w	d1,d4
	bne.w	loc_3BF02
	clr.w	$38(a4)
	move.w	x_pos(a4),d6
	move.w	y_pos(a4),d7
	subi.w	#$10,d7
	move.w	d7,d5
	lsr.w	#4,d5
	add.w	d5,d5
	lea	($FFFF4A04).l,a4
	move.w	(a4,d5.w),a4
	move.w	d6,d5
	lsr.w	#4,d5
	add.w	d5,d5
	add.w	d5,a4
	move.w	(a4),d5
	bpl.s	loc_3BF02
	andi.w	#$F00,d5
	beq.s	loc_3BEDE
	cmpi.w	#$100,d5
	beq.s	loc_3BEDE
	cmpi.w	#$200,d5
	beq.s	loc_3BEF2
	bra.w	loc_3BF02
; ---------------------------------------------------------------------------

loc_3BEDE:
	move.w	a4,d3
	jsr	(j_sub_FACE).l
	move.w	d0,d6
	jsr	(j_sub_10E86).l
	bra.w	loc_3BF02
; ---------------------------------------------------------------------------

loc_3BEF2:
	move.w	a4,d3
	jsr	(j_sub_FACE).l
	move.w	d0,d6
	jsr	(j_sub_10F44).l

loc_3BF02:
	move.w	collision_type(a3),d4
	beq.s	loc_3BF66
	bmi.s	loc_3BF1C
	clr.w	collision_type(a3)
	cmpi.w	#colid_kidabove,d4
	bne.s	loc_3BF66
	subi.w	#1,$44(a3)
	bne.s	loc_3BF4E

loc_3BF1C:
	move.l	#stru_3BCD4,d7
	jsr	(j_Init_Animation).w
	exg	a0,a3
	move.l	$3A(a5),a3
	move.l	#stru_3BCE2,d7
	jsr	(j_Init_Animation).w
	move.l	$3E(a5),a3
	move.l	#stru_3BCE2,d7
	jsr	(j_Init_Animation).w
	exg	a0,a3
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3BF4E:
	move.l	#stru_3BCCE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3BCB2,d7
	jsr	(j_Init_Animation).w

loc_3BF66:
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E