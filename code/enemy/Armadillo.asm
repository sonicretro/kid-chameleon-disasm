;stru_3C632: 
	include "ingame/anim/enemy/Armadillo.asm"

;loc_3C6DC:
Enemy04_Armadillo_Init: 
	addi.w	#1,(Number_of_Enemy).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a4
	move.w	2(a4),enemy_level(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3C718
	st	x_direction(a3)

loc_3C718:
	st	$13(a3)
	move.w	#objid_Armadillo,d5 ; loaded sprite id
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	move.b	#0,priority(a3)
	move.w	enemy_level(a3),d7
	addq.w	#1,d7
	move.w	d7,current_hp(a3)
	cmpi.w	#2,d7
	blt.s	loc_3C766 ; hitpoints 8000 speed
	beq.s	loc_3C756 ; hitpoints 18000 speed
	move.w	#1,$4C(a5)
	move.l	#$10000,$50(a5)
	addi.l	#$10000,$5E(a5)

loc_3C756:
	addi.l	#$10000,$50(a5)
	addi.l	#$10000,$5E(a5)

loc_3C766:
	addi.w	#3,$4C(a5)
	addi.l	#$8000,$50(a5)
	addi.l	#$8000,$5E(a5)
	move.w	#$10,$4A(a5)
	move.w	#9,$48(a5)
	move.l	#$32012C,$6E(a5)
	move.w	#$32,$54(a5)
	move.l	#loc_3DEA0,$6A(a5)
	cmpi.w	#2,d7
	bge.s	loc_3C7C0
	move.l	#stru_3C632,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C632,$62(a5)
	move.l	#stru_3C666,$66(a5)
	bra.s	loc_3C7F8
; ---------------------------------------------------------------------------

loc_3C7C0:
	bgt.s	loc_3C7DE
	move.l	#stru_3C64C,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C64C,$62(a5)
	move.l	#stru_3C666,$66(a5)
	bra.s	loc_3C7F8
; ---------------------------------------------------------------------------

loc_3C7DE:
	move.l	#stru_3C64C,d7
	jsr	(j_Init_Animation).w
	move.l	#stru_3C64C,$62(a5)
	move.l	#stru_3C680,$66(a5)

loc_3C7F8:
	move.w	#$12C,$54(a5)
	move.l	#loc_3C810,a0
	tst.b	x_direction(a3)
	beq.w	loc_3E546
	bra.w	loc_3E392
; ---------------------------------------------------------------------------

loc_3C810:
	bclr	#6,object_meta(a3)
	btst	#7,object_meta(a3)
	beq.s	loc_3C824
	bset	#6,object_meta(a3)

loc_3C824:
	move.w	collision_type(a3),d4
	bmi.s	loc_3C87E
	beq.w	loc_3C91A
	cmpi.w	#colid_hurt,d4
	beq.s	loc_3C848
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3C898
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3C898
	cmpi.w	#colid_kidabove,d4
	bne.w	loc_3C91A

loc_3C848:
	tst.w	$42(a3)
	bgt.w	loc_3C91A
	subi.w	#1,$44(a3)
	beq.s	loc_3C87E
	move.l	#stru_3C6D0,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bra.w	loc_3C91A
; ---------------------------------------------------------------------------

loc_3C87E:
	tst.b	$5C(a5)
	bne.w	loc_3C93C

loc_3C886:
	move.l	#stru_3C69A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	bra.w	loc_3E956
; ---------------------------------------------------------------------------

loc_3C898:
	tst.b	(Berzerker_charging).w
	beq.w	loc_3C91A
	tst.w	$42(a3)
	bgt.s	loc_3C8DE
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C76D6-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3C8CC:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3E8BA
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3C8CC
; ---------------------------------------------------------------------------

loc_3C8DE:
	tst.b	x_direction(a3)
	bne.s	loc_3C8EC
	addi.w	#$14,x_pos(a3)
	bra.s	loc_3C8F2
; ---------------------------------------------------------------------------

loc_3C8EC:
	subi.w	#$14,x_pos(a3)

loc_3C8F2:
	move.l	#stru_3C6D6,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FF88,$42(a3)
	move.l	$5E(a5),$50(a5)
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w
	bclr	#7,object_meta(a3)

loc_3C91A:
	clr.w	collision_type(a3)
	tst.b	$5C(a5)
	beq.s	loc_3C930
	tst.b	x_direction(a3)
	beq.w	loc_3E7CA
	bra.w	loc_3E6AE
; ---------------------------------------------------------------------------

loc_3C930:
	tst.b	x_direction(a3)
	beq.w	loc_3E560
	bra.w	loc_3E3AC
; ---------------------------------------------------------------------------

loc_3C93C:
	move.l	#0,x_vel(a3)
	move.l	#$2C000,y_vel(a3)
	st	has_level_collision(a3)
	st	is_moved(a3)

loc_3C954:
	clr.w	collision_type(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d4
	beq.s	loc_3C954
	cmpi.w	#colid_floor,d4
	bne.s	loc_3C954
	sf	has_level_collision(a3)
	sf	is_moved(a3)
	move.l	#0,y_vel(a3)
	bra.w	loc_3C886