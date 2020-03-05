;loc_35EF2
Enemy06_Sphere_Init: 
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w	; --> loads an object data slot at a3
	move.l	current_hp(a5),a0	; address to position in enemy layout
	move.w	4(a0),x_pos(a3)	; x position
	move.w	6(a0),y_pos(a3)	; y position
	bsr.w	sub_36FF4	; FFFAD2 x_pos adjustment
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#6,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)	; initializes palette_line(a3) and vram_tile(a3)
	st	has_level_collision(a3)
	move.l	#stru_36174,d7
	jsr	(j_Init_Animation).w	; init anim
	sf	$19(a3)
	move.w	#0,y_vel(a3)	; y velocity
	move.l	#$10000,x_vel(a3)	; x velocity
	move.w	#$A,d1

;loc_35F4E
Enemy06_Sphere_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	subq.w	#1,d1
	bne.w	+
	move.w	#$96,d1
	clr.l	d0

+
	addi.l	#$800,y_vel(a3)	; apply gravity
	tst.w	collision_type(a3)
	bne.s	Enemy06_Sphere_ExecCollisionBehavior
	bra.s	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;off_35F72
Enemy06_Sphere_CollisionBehaviors:
	dc.l Enemy06_Sphere_BounceWall	; bounce on wall
	dc.l Enemy06_Sphere_BounceWall	; bounce on wall
	dc.l Enemy06_Sphere_BounceFloor	; bounce on floor
	dc.l Enemy06_Sphere_BounceCeiling	; bounce on ceiling
	dc.l Enemy06_Sphere_SlopeUp	; bounce on slope?
	dc.l Enemy06_Sphere_SlopeDown	; bounce on slope?
	dc.l Enemy06_Sphere_Kill	; kill sphere
	dc.l Enemy06_Sphere_Loop	; do nothing
	dc.l Enemy06_Sphere_Loop	; do nothing
	dc.l Enemy06_Sphere_Loop	; do nothing
	dc.l Enemy06_Sphere_Kill	; kill sphere
; ---------------------------------------------------------------------------
;loc_35F9E
Enemy06_Sphere_ExecCollisionBehavior:
	bmi.w	Enemy06_Sphere_Kill
	move.w	#1,d0
	clr.l	d7
	move.w	collision_type(a3),d7
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	Enemy06_Sphere_CollisionBehaviors(pc,d7.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------
;loc_35FB8
Enemy06_Sphere_BounceWall:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	bra.s	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------

loc_35FC4:
	jmp	loc_35FC4(pc)
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	(Addr_GfxObject_Kid).w,a0
	add.l	$26(a0),d7
	move.l	d7,x_vel(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	(Addr_GfxObject_Kid).w,a0
	add.l	$26(a0),d7
	move.l	d7,x_vel(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;loc_35FF4
Enemy06_Sphere_BounceFloor:
	move.l	y_vel(a3),d7
	neg.l	d7
	move.l	d7,y_vel(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;loc_36002
Enemy06_Sphere_BounceCeiling:
	move.l	y_vel(a3),d7
	asr.l	#1,d7
	neg.l	d7
	move.l	d7,y_vel(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;loc_36012
Enemy06_Sphere_SlopeUp:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),d6
	neg.l	d6
	add.l	d7,x_pos(a3)
	add.l	d6,y_pos(a3)
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;loc_36032
Enemy06_Sphere_SlopeDown:
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	neg.l	d7
	neg.l	d6
	add.l	d7,x_pos(a3)
	add.l	d6,y_pos(a3)
	bra.w	Enemy06_Sphere_Loop
; ---------------------------------------------------------------------------
;loc_36052
Enemy06_Sphere_Kill:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	move.l	#stru_36182,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_36088
	btst	#6,d0
	beq.s	loc_36096
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_36096
; ---------------------------------------------------------------------------

loc_36088:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_36096:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	st	has_level_collision(a3)
	move.b	$48(a5),x_direction(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.b	#0,priority(a3)
	move.w	#6,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	$4A(a5),d7
	jsr	(j_Init_Animation).w
	sf	$19(a3)
	move.w	$46(a5),y_vel(a3)
	move.w	$44(a5),x_vel(a3)

loc_360F4:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.s	loc_3610E
	tst.w	d0
	beq.s	loc_36106
	subq.w	#1,d0
	bra.s	loc_360F4
; ---------------------------------------------------------------------------

loc_36106:
	tst.w	collision_type(a3)
	bne.s	loc_3610E
	bra.s	loc_360F4
; ---------------------------------------------------------------------------

loc_3610E:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
	move.w	#6,d0
	clr.l	d7
	move.w	collision_type(a3),d7
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	off_3612A(pc,d7.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------

loc_36128:
	bra.s	loc_36128
; ---------------------------------------------------------------------------
off_3612A:
	dc.l loc_36148
	dc.l loc_36148
	dc.l loc_36142
	dc.l loc_36142
	dc.l loc_3614E
	dc.l loc_36164
; ---------------------------------------------------------------------------

loc_36142:
	neg.l	y_vel(a3)
	bra.s	loc_360F4
; ---------------------------------------------------------------------------

loc_36148:
	neg.l	x_vel(a3)
	bra.s	loc_360F4
; ---------------------------------------------------------------------------

loc_3614E:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),x_vel(a3)
	neg.l	x_vel(a3)
	move.l	d7,y_vel(a3)
	bra.s	loc_360F4
; ---------------------------------------------------------------------------

loc_36164:
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),x_vel(a3)
	move.l	d7,y_vel(a3)
	bra.s	loc_360F4

;stru_36174: 
	include "ingame/anim/enemy/Sphere.asm"
