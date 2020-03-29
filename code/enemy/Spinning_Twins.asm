;stru_3B7F0: 
	include "ingame/anim/enemy/Spinning_Twins.asm"

Enemy14_SpinningTwins_Init: 
	addi.w	#1,(Number_of_Enemy).w
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a4
	move.w	2(a4),enemy_level(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	st	$13(a3)
	move.w	#$14,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	bset	#7,object_meta(a3)
	move.b	#0,priority(a3)
	move.l	#stru_3B7F0,d7
	jsr	(j_Init_Animation).w
	move.l	#$1010002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,$3A(a5)
	move.b	#0,$10(a1)
	st	$13(a1)
	move.b	palette_line(a3),$11(a1)
	move.w	$3E(a3),$3E(a1)
	move.b	x_direction(a3),$16(a1)
	move.w	vram_tile(a3),$24(a1)
	move.w	x_pos(a3),$1A(a1)
	move.w	y_pos(a3),$1E(a1)
	subi.w	#$1A,$1E(a1)
	subi.w	#$FFF0,$1A(a1)
	exg	a1,a3
	move.l	#stru_3B802,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	clr.w	d1
	move.w	addroffset_sprite(a3),d3
	move.w	x_pos(a3),d2
	move.b	#$A,$5B(a5)

loc_3B904:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	move.w	collision_type(a3),d7
	bmi.s	loc_3B93C
	cmpi.w	#$2C,d7
	beq.s	loc_3B93C
	cmpi.w	#$1C,d7
	beq.s	loc_3B93C
	cmpi.w	#1,animation_timer(a3)
	bne.s	loc_3B904
	addq.w	#1,d1
	andi.w	#7,d1
	move.w	d1,d5
	add.w	d5,d5
	move.w	d2,d4
	add.w	word_3B9A0(pc,d5.w),d4
	move.w	d4,$1A(a1)
	bra.s	loc_3B904
; ---------------------------------------------------------------------------

loc_3B93C:
	clr.w	$44(a3)
	move.l	$3A(a5),a4
	sf	$13(a4)
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3BA74,4(a0)
	move.l	a0,a4
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3BA74,4(a0)
	move.l	a4,$5C(a0)
	move.l	a0,$5C(a4)
	move.b	$42(a5),$42(a0)
	move.b	$42(a5),$42(a4)
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3B9B0,4(a0)
	move.l	#stru_3B810,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
word_3B9A0:	dc.w $FFF0
	dc.b $FF
	dc.b $F6 ; ö
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b $11
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b  $A
	dc.b $FF
	dc.b $FB ; û
	dc.b $FF
	dc.b $EF ; ï
; ---------------------------------------------------------------------------

loc_3B9B0:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a2
	move.l	$36(a2),a4
	move.w	x_pos(a4),x_pos(a3)
	move.w	y_pos(a4),y_pos(a3)
	subi.w	#$40,y_pos(a3)
	subi.w	#$13,x_pos(a3)
	move.b	#1,priority(a3)
	st	$13(a3)
	move.b	$11(a4),palette_line(a3)
	move.w	$3E(a4),$3E(a3)
	move.w	$24(a4),vram_tile(a3)
	move.w	#(LnkTo_unk_C7D26-Data_Index),addroffset_sprite(a3)
	clr.w	d0
	moveq	#4,d1

loc_3BA00:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7
	cmpi.w	#$FEFC,d7
	blt.s	loc_3BA5C
	cmpi.w	#$244,d7
	bgt.s	loc_3BA5C
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#$FEFC,d7
	blt.s	loc_3BA5C
	cmpi.w	#$1E4,d7
	bgt.s	loc_3BA5C
	move.w	d0,d6
	add.w	d6,d6
	add.w	d6,d6
	move.l	dword_3BA60(pc,d6.w),d5
	tst.b	d3
	bpl.s	loc_3BA3C
	neg.l	d5

loc_3BA3C:
	add.l	d5,x_pos(a3)
	addi.w	#1,y_pos(a3)
	subq.w	#1,d1
	bne.s	loc_3BA00
	moveq	#4,d1
	addq.w	#1,d0
	cmpi.w	#5,d0
	bne.s	loc_3BA00
	eori.b	#$FF,d3
	moveq	#0,d0
	bra.s	loc_3BA00
; ---------------------------------------------------------------------------

loc_3BA5C:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
dword_3BA60:	dc.l $12000
	dc.b   0
	dc.b   1
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b $40 ; @
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_3BA74:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a2
	move.l	$36(a2),a4
	move.w	x_pos(a4),x_pos(a3)
	move.w	y_pos(a4),y_pos(a3)
	move.w	$40(a4),$40(a3)
	move.b	#0,priority(a3)
	st	$13(a3)
	move.b	$11(a4),palette_line(a3)
	move.w	$3E(a4),$3E(a3)
	move.w	$24(a4),vram_tile(a3)
	move.w	$40(a3),d7
	addi.w	#1,d7
	move.w	d7,$44(a3)
	move.l	#$18000,$50(a5)
	move.w	#$1C,$4A(a5)
	move.w	#$B,$48(a5)
	move.w	#$14,object_meta(a3)
	move.w	#(LnkTo_unk_C7CDE-Data_Index),addroffset_sprite(a3)
	addi.w	#1,(Number_of_Enemy).w
	st	has_level_collision(a3)
	st	is_moved(a3)
	tst.w	$44(a4)
	bne.s	loc_3BB06
	st	x_direction(a3)
	move.w	#1,$44(a4)
	subi.w	#$20,x_pos(a3)
	bra.s	loc_3BB0C
; ---------------------------------------------------------------------------

loc_3BB06:
	addi.w	#$20,x_pos(a3)

loc_3BB0C:
	tst.b	x_direction(a3)
	beq.s	loc_3BB1C
	move.l	#$FFFC8000,x_vel(a3)
	bra.s	loc_3BB24
; ---------------------------------------------------------------------------

loc_3BB1C:
	move.l	#$38000,x_vel(a3)

loc_3BB24:
	move.l	#-$10000,y_vel(a3)

loc_3BB2C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	tst.l	y_vel(a3)
	beq.s	loc_3BB42
	addi.l	#$2800,y_vel(a3)

loc_3BB42:
	tst.b	x_direction(a3)
	beq.s	loc_3BB52
	addi.l	#$1200,x_vel(a3)
	bra.s	loc_3BB5A
; ---------------------------------------------------------------------------

loc_3BB52:
	subi.l	#$1200,x_vel(a3)

loc_3BB5A:
	cmpi.l	#$3000,x_vel(a3)
	bgt.s	loc_3BB6E
	cmpi.l	#$FFFFD000,x_vel(a3)
	bgt.s	loc_3BB94

loc_3BB6E:
	move.w	collision_type(a3),d4
	cmpi.w	#colid_floor,d4
	beq.s	loc_3BB8A
	cmpi.w	#colid_rightwall,d4
	beq.s	loc_3BB94
	cmpi.w	#colid_leftwall,d4
	beq.s	loc_3BB94
	clr.w	collision_type(a3)
	bra.s	loc_3BB2C
; ---------------------------------------------------------------------------

loc_3BB8A:
	clr.w	collision_type(a3)
	clr.l	y_vel(a3)
	bra.s	loc_3BB2C
; ---------------------------------------------------------------------------

loc_3BB94:
	clr.w	collision_type(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	has_level_collision(a3)
	sf	is_moved(a3)
	move.l	#stru_3B81C,d7
	jsr	(j_Init_Animation).w
	move.l	#loc_3BBC4,a0
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3BBC4:
	move.w	collision_type(a3),d4
	beq.s	loc_3BBE6
	bmi.w	loc_3BC56
	cmpi.w	#colid_kidabove,d4
	beq.s	loc_3BC34
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3BC34
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3BBF6
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3BBF6

loc_3BBE6:
	clr.w	collision_type(a3)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3BBF6:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3BBE6
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C7CDE-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3BC22:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3BC22
; ---------------------------------------------------------------------------

loc_3BC34:
	subi.w	#1,$44(a3)
	beq.s	loc_3BC56
	move.l	#stru_3B836,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3B81C,d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3BBE6
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_3C3CE

loc_3BC56:
	subi.w	#1,(Number_of_Enemy).w
	cmpi.b	#$A,$5B(a5)
	beq.s	loc_3BC78
	move.l	#stru_3B83C,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	tst.b	$5B(a5)
	beq.s	loc_3BCA6

loc_3BC78:
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_3BC98
	btst	#6,d0
	beq.s	loc_3BCA2
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3BCA2
; ---------------------------------------------------------------------------

loc_3BC98:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	clr.w	(a0,d0.w)

loc_3BCA2:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3BCA6:
	move.l	$5C(a5),a2
	st	$5B(a2)
	jmp	(j_Delete_CurrentObject).w
; END OF FUNCTION CHUNK	FOR sub_3C3CE