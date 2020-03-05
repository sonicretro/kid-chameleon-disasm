;stru_3B270: 
	include "ingame/anim/enemy/Tank.asm"
;loc_3B2A8:
Enemy0A_RockTank_Init: 
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
	blt.s	loc_3B2E4
	st	x_direction(a3)

loc_3B2E4:
	st	$13(a3)
	move.w	#$A,d5
	move.w	#$B,d6
	move.w	d5,object_meta(a3)
	move.l	(Addr_EnemyLayoutHeader).w,a4
	moveq	#0,d4
	move.w	2(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3B31E
	cmp.w	d3,d6
	beq.s	loc_3B31E
	addq.w	#1,d4
	move.w	4(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3B31E
	cmp.w	d3,d6
	beq.s	loc_3B31E
	addq.w	#1,d4

loc_3B31E:
	lea	EnemyArt_PaletteLines(pc),a4
	move.b	(a4,d4.w),palette_line(a3)
	lea	EnemyArt_VRAMTileAddresses(pc),a4
	add.w	d4,d4
	move.w	(a4,d4.w),vram_tile(a3)
	move.w	d4,$3E(a3)
	bset	#7,object_meta(a3)
	move.b	#0,priority(a3)
	move.w	#$20,$4A(a5)
	move.w	#$B,$48(a5)
	move.w	enemy_hp(a3),d7
	addq.w	#2,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#3,d7
	blt.s	loc_3B372
	beq.s	loc_3B36A
	move.l	#$8000,$50(a5)

loc_3B36A:
	addi.l	#$8000,$50(a5)

loc_3B372:
	addi.l	#$8000,$50(a5)
	move.l	#stru_3B270,d7
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
	subi.w	#8,$1E(a1)
	move.w	#8,$46(a1)
	exg	a1,a3
	move.l	#stru_3B27E,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	move.l	#loc_3B41C,a0
	lea	($FFFFFA34).w,a4
	tst.b	(a4,d5.w)
	bne.s	loc_3B40A
	tst.b	$19(a3)
	bne.s	loc_3B40A
	moveq	#sfx_Tank_driving,d0
	jsr	(j_PlaySound).l

loc_3B40A:
	addi.b	#1,(a4,d5.w)
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3B41C:
	tst.w	collision_type(a3)
	bmi.s	loc_3B480
	move.l	$3A(a5),a2
	cmpi.w	#(LnkTo_unk_C7F20-Data_Index),$22(a2)
	bne.s	loc_3B446
	cmpi.w	#$A,$32(a2)
	bne.s	loc_3B446
	tst.b	$19(a3)
	bne.s	loc_3B444
	moveq	#sfx_Tank_mouth_open,d0
	jsr	(j_PlaySound).l

loc_3B444:
	bra.s	loc_3B464
; ---------------------------------------------------------------------------

loc_3B446:
	cmpi.w	#(LnkTo_unk_C7EC8-Data_Index),$22(a2)
	bne.s	loc_3B464
	cmpi.w	#$37,$32(a2)
	bne.s	loc_3B464
	tst.b	$19(a3)
	bne.s	loc_3B464
	moveq	#sfx_Tank_mouth_closed,d0
	jsr	(j_PlaySound).l

loc_3B464:
	move.w	$38(a2),d4
	beq.s	loc_3B4BA
	bmi.s	loc_3B480
	cmpi.w	#$2C,d4
	beq.s	loc_3B478
	cmpi.w	#$1C,d4
	bne.s	loc_3B4BA

loc_3B478:
	subi.w	#1,$44(a3)
	bne.s	loc_3B49A

loc_3B480:
	sf	$13(a2)
	st	$3D(a2)
	move.l	#stru_3B29A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3B49A:
	move.l	#0,$50(a5)
	move.w	#6,$46(a2)
	move.l	#stru_3B294,d7
	jsr	(j_Init_Animation).w
	move.w	#5,-(sp)
	jsr	(j_Hibernate_Object).w

loc_3B4BA:
	clr.w	$38(a2)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E