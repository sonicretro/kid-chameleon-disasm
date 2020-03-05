;stru_3A31A: 
	include "ingame/anim/enemy/Fire_Demon.asm"


;loc_3A392:
Enemy00_FireDemon_Init: 
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	current_hp(a5),a4
	move.w	2(a4),enemy_hp(a3)
	move.w	4(a4),x_pos(a3)
	move.w	6(a4),y_pos(a3)
	bsr.w	sub_36FF4
	addi.w	#1,(Number_of_Enemy).w
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a4),d4
	cmp.w	x_pos(a3),d4
	blt.s	loc_3A3D2
	st	x_direction(a3)

loc_3A3D2:
	st	$13(a3)
	st	is_animated(a3)
	move.w	#0,d5
	move.w	d5,object_meta(a3)
	bsr.w	sub_36E84
	bset	#6,object_meta(a3)
	move.b	#0,priority(a3)
	move.w	enemy_hp(a3),d7 ; enemy hitpoints
	addq.w	#3,d7
	move.w	d7,$44(a3)
	cmpi.w	#4,d7
	blt.s	loc_3A414
	beq.s	loc_3A40C
	move.l	#$8000,$50(a5) ; movement speed 3 hitpoint and higher also add (speeds below)

loc_3A40C:
	addi.l	#$8000,$50(a5) ; movement speed 2 hitpoint also add (speeds below)

loc_3A414:
	addi.l	#$8000,$50(a5) ; movement speed 1 hitpoint
	move.w	#$20,$4A(a5)
	move.w	#$B,$48(a5)
	tst.b	(Fire_Demon).w
	bne.s	loc_3A444
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3A48E,4(a0)
	addi.b	#1,(Fire_Demon).w

loc_3A444:
	move.l	#loc_3A542,a0
	cmpi.w	#5,d7
	bne.s	loc_3A464
	move.l	#stru_3A334,d7 ; walking sprite
	jsr	(j_Init_Animation).w
	move.l	#stru_3A334,$62(a5)
	bra.s	loc_3A476
; ---------------------------------------------------------------------------

loc_3A464:
	move.l	#stru_3A31A,d7 ; walking sprite
	jsr	(j_Init_Animation).w
	move.l	#stru_3A31A,$62(a5)

loc_3A476:
	tst.b	x_direction(a3)
	beq.w	loc_3C0D2
	bra.w	loc_3C026
; ---------------------------------------------------------------------------
dword_3A482:
	dc.l Palette_Buffer+$22
	dc.l Palette_Buffer+$42
	dc.l Palette_Buffer+$52
; ---------------------------------------------------------------------------

loc_3A48E:
	move.l	$A(a5),a4
	move.l	$36(a4),a4
	move.w	$3E(a4),d1
	lsl.w	#2,d1
	move.l	dword_3A482(pc,d1.w),a3
	move.w	#$634,d7
	move.w	$40(a4),d4
	beq.s	loc_3A4B8
	cmpi.w	#1,d4
	beq.s	loc_3A4B4
	addi.w	#$C,d7

loc_3A4B4:
	addi.w	#$C,d7

loc_3A4B8:
	lea	(Data_Index).l,a4
	move.l	(a4,d7.w),a2

loc_3A4C2:
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	(Fire_Demon).w
	beq.s	loc_3A53E
	move.l	a3,a1
	move.l	a2,a0
	moveq	#6,d0

loc_3A4D6:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_3A4D6
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	(Fire_Demon).w
	beq.s	loc_3A53E
	move.l	a3,a1
	move.l	a2,a0
	addi.l	#$E,a0
	moveq	#6,d0

loc_3A4F6:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_3A4F6
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	(Fire_Demon).w
	beq.s	loc_3A53E
	move.l	a3,a1
	move.l	a2,a0
	addi.l	#$1C,a0
	moveq	#6,d0

loc_3A516:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_3A516
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	(Fire_Demon).w
	beq.s	loc_3A53E
	move.l	a3,a1
	move.l	a2,a0
	addi.l	#$E,a0
	moveq	#6,d0

loc_3A536:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_3A536
	bra.s	loc_3A4C2
; ---------------------------------------------------------------------------

loc_3A53E:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3A542:
	cmpi.w	#(LnkTo_unk_C771E-Data_Index),addroffset_sprite(a3)
	bne.s	loc_3A586
	cmpi.w	#2,$40(a3)
	beq.s	loc_3A55C
	cmpi.w	#6,animation_timer(a3)
	bne.s	loc_3A586
	bra.s	loc_3A564
; ---------------------------------------------------------------------------

loc_3A55C:
	cmpi.w	#3,animation_timer(a3)
	bne.s	loc_3A586

loc_3A564:
	cmpi.w	#7,(Number_of_Fire_Trails).w
	bge.w	loc_3A586
	exg	a0,a4
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3A63C,4(a0)
	exg	a0,a4
	addq.w	#1,(Number_of_Fire_Trails).w

loc_3A586:
	move.w	collision_type(a3),d4
	bmi.s	loc_3A5A6 ; fire demon death
	beq.s	loc_3A5D4
	cmpi.w	#colid_kidright,d4
	beq.s	loc_3A5E4
	cmpi.w	#colid_kidleft,d4
	beq.s	loc_3A5E4
	cmpi.w	#colid_hurt,d4
	bne.s	loc_3A5D4
	subq.w	#1,$44(a3) ; remove one hitpoint from enemy
	bne.s	loc_3A5BE

loc_3A5A6: ; fire demon death
	move.l	#stru_3A378,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	subi.b	#1,(Fire_Demon).w
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3A5BE:
	move.l	#stru_3A34E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	$62(a5),d7
	jsr	(j_Init_Animation).w

loc_3A5D4:
	clr.w	collision_type(a3)
	tst.b	x_direction(a3)
	beq.w	loc_3C0FA
	bra.w	loc_3C04E
; ---------------------------------------------------------------------------

loc_3A5E4:
	tst.b	(Berzerker_charging).w
	beq.s	loc_3A5D4
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	st	is_moved(a3)
	sf	is_animated(a3)
	move.w	#(LnkTo_unk_C773E-Data_Index),addroffset_sprite(a3)
	move.l	#0,x_vel(a3)
	move.l	#$FFFB8000,y_vel(a3)

loc_3A610:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	addi.l	#$4000,y_vel(a3)
	bra.s	loc_3A610
; ---------------------------------------------------------------------------
stru_3A622:
	anim_frame	  1,   6, LnkTo_unk_C7776-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C777E-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C7786-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C778E-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C7796-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C779E-Data_Index
	dc.b   2
	dc.b $19
; ---------------------------------------------------------------------------

loc_3A63C:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	addi.w	#$F,y_pos(a3)
	andi.w	#$FFF0,y_pos(a3)
	move.b	#0,priority(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	$3A(a0),object_meta(a3)
	move.w	$24(a0),vram_tile(a3)
	move.b	$11(a0),palette_line(a3)
	move.l	#stru_3A622,d7 ; fire trail sprite
	jsr	(j_Init_Animation).w
	move.w	#$96,d3
	moveq	#8,d7
	move.w	#$3E7,d6
	bsr.w	loc_33286
	bclr	#$F,d6
	bne.w	loc_3A6DA
	andi.w	#$7000,d6
	cmpi.w	#$6000,d6
	bne.w	loc_3A6DA
	andi.w	#$7000,d5
	cmpi.w	#$6000,d5
	bne.w	loc_3A6DA
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bne.w	loc_3A6DA

loc_3A6CA:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_3A6DA
	subq.w	#1,d3
	bne.s	loc_3A6CA

loc_3A6DA:
	subq.w	#1,(Number_of_Fire_Trails).w
	jmp	(j_Delete_CurrentObject).w