;stru_3B4CA: 
	include "ingame/anim/enemy/Tank_Shooting.asm"

;loc_3B530:
Enemy0B_RockTank_shooting_Init: 
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
	blt.s	loc_3B56C
	st	x_direction(a3)

loc_3B56C:
	st	$13(a3)
	move.w	#$A,d6
	move.w	#$B,d5
	move.w	d5,object_meta(a3)
	move.l	(Addr_EnemyLayoutHeader).w,a4
	moveq	#0,d4
	move.w	2(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3B5A6
	cmp.w	d3,d6
	beq.s	loc_3B5A6
	addq.w	#1,d4
	move.w	4(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5
	beq.s	loc_3B5A6
	cmp.w	d3,d6
	beq.s	loc_3B5A6
	addq.w	#1,d4

loc_3B5A6:
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
	blt.s	loc_3B5FA
	beq.s	loc_3B5F2
	move.l	#$8000,$50(a5)

loc_3B5F2:
	addi.l	#$8000,$50(a5)

loc_3B5FA:
	addi.l	#$8000,$50(a5)
	move.w	#$49,$54(a5)
	move.l	#stru_3B4CA,d7
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
	cmpi.w	#4,d7
	bne.s	loc_3B682
	exg	a1,a3
	move.l	#stru_3B4D8,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	bra.s	loc_3B690
; ---------------------------------------------------------------------------

loc_3B682:
	exg	a1,a3
	move.l	#stru_3B4F6,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3

loc_3B690:
	move.l	#loc_3B6C0,a0
	lea	($FFFFFA34).w,a4
	tst.b	(a4,d5.w)
	bne.s	loc_3B6AE
	tst.b	$19(a3)
	bne.s	loc_3B6AE
	moveq	#sfx_Tank_driving,d0
	jsr	(j_PlaySound).l

loc_3B6AE:
	addi.b	#1,(a4,d5.w)
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3B6C0:
	tst.w	collision_type(a3)
	bmi.s	loc_3B6E6
	move.l	$3A(a5),a2
	move.w	$38(a2),d4
	beq.s	loc_3B720
	bmi.s	loc_3B6E6
	cmpi.w	#$2C,d4
	beq.s	loc_3B6DE
	cmpi.w	#$1C,d4
	bne.s	loc_3B720

loc_3B6DE:
	subi.w	#1,$44(a3)
	bne.s	loc_3B700

loc_3B6E6:
	sf	$13(a2)
	st	$3D(a2)
	move.l	#stru_3B518,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3B700:
	move.l	#0,$50(a5)
	move.w	#6,$46(a2)
	move.l	#stru_3B294,d7
	jsr	(j_Init_Animation).w
	move.w	#5,-(sp)
	jsr	(j_Hibernate_Object).w

loc_3B720:
	clr.w	$38(a2)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3B730:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a4
	move.l	$3A(a4),a1
	move.l	$36(a4),a2
	move.b	#1,priority(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	$11(a2),palette_line(a3)
	move.w	$3E(a2),$3E(a3)
	move.w	$24(a2),vram_tile(a3)
	move.w	#$FFFD,d4
	move.w	#$FFF1,d5
	move.b	$16(a2),x_direction(a3)
	beq.s	loc_3B77E
	neg.w	d4
	neg.w	d5

loc_3B77E:
	move.w	d4,x_vel(a3)
	move.w	$1A(a2),x_pos(a3)
	add.w	d5,x_pos(a3)
	move.w	$1E(a2),y_pos(a3)
	move.w	$46(a1),d4
	addi.w	#6,d4
	sub.w	d4,y_pos(a3)
	move.l	#stru_3B526,d7
	jsr	(j_Init_Animation).w
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.s	loc_3B7BA
	moveq	#sfx_Tank_shoots,d0
	jsr	(j_PlaySound).l

loc_3B7BA:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	x_pos(a3),d4
	sub.w	(Camera_X_pos).w,d4
	cmpi.w	#$FF80,d4
	blt.s	loc_3B7EC
	cmpi.w	#$1C0,d4
	bgt.s	loc_3B7EC
	move.w	y_pos(a3),d4
	sub.w	(Camera_Y_pos).w,d4
	cmpi.w	#$FF80,d4
	blt.s	loc_3B7EC
	cmpi.w	#$1C0,d4
	bgt.s	loc_3B7EC
	move.w	collision_type(a3),d4
	beq.s	loc_3B7BA

loc_3B7EC:
	jmp	(j_Delete_CurrentObject).w