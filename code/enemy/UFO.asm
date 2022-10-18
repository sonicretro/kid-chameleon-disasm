;stru_34C7E: 
	include "ingame/anim/enemy/UFO.asm"

unk_34D48:
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
; ---------------------------------------------------------------------------
;$44(a5)	word counter
;$46(a5)	flag whether UFO is shooting
;$47(a5)	flag ?
;$4C(a5)	flag ?
;$4D(a5)	flag ?
;$4E(a5)	flag ?
;$4F(a5)	flag ?
;$50(a5)	flag whether UFO is on screen
;d0	x acceleration
;d1
;d2	y acceleration
;d3
; ---------------------------------------------------------------------------

;loc_34D54:
Enemy0F_UFO_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	bsr.w	sub_36FF4
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	sf	$19(a3)
	sf	$46(a5)
	sf	$47(a5)
	sf	is_moved(a3)
	sf	$50(a5)
	move.w	2(a0),d7
	add.w	d7,d7
	add.w	d7,d7
	lea	unk_34D48(pc,d7.w),a4
	move.b	(a4)+,$4C(a5)
	move.b	(a4)+,$4D(a5)
	move.b	(a4)+,$4E(a5)
	move.b	(a4)+,$4F(a5)
	move.b	#1,priority(a3)
	move.w	#$F,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	move.l	#stru_34C7E,d7
	jsr	(j_Init_Animation).w
	move.l	(Addr_GfxObject_Kid).w,a2

;loc_34DD6
Enemy0F_UFO_1SecLoop:
	; this part happens once per second (every $3C frames)
	bsr.w	loc_35326	; randomness?
	bsr.w	loc_34E10
	move.w	#$3C,$44(a5)

;loc_34DE4
Enemy0F_UFO_Loop:
	; this part happens every frame
	bsr.w	Enemy_HandleAcceleration
	bsr.w	loc_34E2A
	bsr.w	Enemy0F_UFO_ChkShoot
	bsr.w	Enemy0F_UFO_ChkLoadBeam
	bsr.w	Enemy0F_UFO_SpeedToPos
	bsr.w	Enemy0F_UFO_ChkOnScreen
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	loc_35280	; loading/unloading
	bsr.w	Enemy0F_UFO_ExecCollisionBehavior
	subq.w	#1,$44(a5)
	bne.s	Enemy0F_UFO_Loop
	bra.s	Enemy0F_UFO_1SecLoop
; ---------------------------------------------------------------------------

loc_34E10:
	tst.b	$4E(a5)
	beq.w	loc_34E1C
	; double acceleration?
	add.l	d0,d0
	add.l	d2,d2

loc_34E1C:
	tst.b	$4F(a5)
	beq.w	return_34E28
	; double terminal speed?
	add.l	d1,d1
	add.l	d3,d3

return_34E28:
	rts
; ---------------------------------------------------------------------------

loc_34E2A:	; adjust x-vel/accel towards kid if Kid is close and below UFO
	tst.b	$4D(a5)
	beq.w	return_34E9A
	tst.b	(Some_UFO_Shooting).w
	bne.w	return_34E9A
	move.w	$1E(a2),d7
	cmp.w	y_pos(a3),d7	; is Kid lower than UFO?
	ble.w	return_34E9A	; no
	; yes
	move.w	x_pos(a3),d7
	move.w	$1A(a2),d6
	move.w	d6,d5
	subi.w	#$30,d6
	cmp.w	d6,d7
	blt.w	return_34E9A
	addi.w	#$60,d6
	cmp.w	d6,d7
	bgt.w	return_34E9A
	; Kid's x-position is close to UFO's x-position
	moveq	#0,d2
	moveq	#0,d3
	move.l	d2,y_vel(a3)	; clear vertical velocity
	cmp.w	d5,d7
	blt.w	loc_34E86
	move.l	#-$20000,d1	; speed we want to achieve
	move.l	#-$1000,d0	; acceleration (towards that speed)
	sf	x_direction(a3)
	bra.w	loc_34E96
; ---------------------------------------------------------------------------

loc_34E86:
	move.l	#$20000,d1
	move.l	#$1000,d0
	st	x_direction(a3)

loc_34E96:
	bsr.w	loc_34E10

return_34E9A:
	rts
; ---------------------------------------------------------------------------
;loc_34E9C
Enemy0F_UFO_ChkShoot:
	tst.b	$4C(a5)
	beq.w	return_34F16
	tst.b	$46(a5)
	bne.w	return_34F16
	tst.b	(Some_UFO_Shooting).w
	bne.w	return_34F16
	move.w	$1E(a2),d7
	cmp.w	y_pos(a3),d7	; is Kid lower than UFO?
	ble.w	return_34F16	; no
	; yes
	move.w	x_pos(a3),d7
	move.w	$1A(a2),d6
	subq.w	#2,d6
	cmp.w	d6,d7
	blt.w	return_34F16
	addq.w	#4,d6
	cmp.w	d6,d7
	bgt.w	return_34F16
	; Kid is directly below UFO
	tst.b	$19(a3)
	bne.w	loc_34EEC
	move.l	d0,-(sp)
	moveq	#sfx_UFO_shoots,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_34EEC:
	move.w	#4,$48(a5)
	move.w	#5,$4A(a5)
	st	$46(a5)
	st	(Some_UFO_Shooting).w
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	d0,x_vel(a3)	; clear velocities and acceleration,
	move.l	d0,y_vel(a3)	; i.e. UFO stays in place
	move.w	#$32,$44(a5)

return_34F16:
	rts
; ---------------------------------------------------------------------------
;loc_35008
Enemy0F_UFO_ChkOnScreen:
	move.w	x_pos(a3),d7
	sub.w	$1A(a2),d7
	cmpi.w	#-$A0,d7
	blt.w	loc_34F6E
	cmpi.w	#$A0,d7
	bgt.w	loc_34F6E
	; UFO's x-position is within $A0 pixels of Kid's x-position
	move.w	y_pos(a3),d7
	sub.w	$1E(a2),d7
	cmpi.w	#-$A0,d7
	blt.w	loc_34F6E
	cmpi.w	#$50,d7
	bgt.w	loc_34F6E
	; UFO is also not too far away in y-position
	; --> UFO is on screen
	tst.b	$50(a5)
	bne.w	return_34F6C
	move.b	(Number_UFOs_OnScreen).w,d7
	bne.w	loc_34F64
	move.l	d0,-(sp)
	moveq	#sfx_UFO_hovering,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_34F64:
	addq.w	#1,(Number_UFOs_OnScreen).w
	st	$50(a5)

return_34F6C:
	rts
; ---------------------------------------------------------------------------

loc_34F6E:
	; UFO is off screen
	tst.b	$50(a5)
	beq.s	return_34F6C
	subq.w	#1,(Number_UFOs_OnScreen).w
	bne.w	loc_34F88
	move.l	d0,-(sp)
	moveq	#sfx_UFO_hovering,d0
	jsr	(j_PlaySound2).l
	move.l	(sp)+,d0

loc_34F88:
	sf	$50(a5)
	rts
; ---------------------------------------------------------------------------
;loc_34F8E
Enemy0F_UFO_ChkLoadBeam:
	tst.b	$46(a5)
	bne.w	loc_34FD6
	tst.b	(Some_UFO_Shooting).w
	bne.w	return_34FFC
	tst.b	$4C(a5)
	bne.w	return_34FFC
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$FF,d7
	cmpi.w	#4,d7
	bgt.w	return_34FFC
	move.l	d0,-(sp)
	moveq	#sfx_UFO_shoots,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	#4,$48(a5)
	move.w	#5,$4A(a5)
	st	$46(a5)
	st	(Some_UFO_Shooting).w

loc_34FD6:
	subq.w	#1,$4A(a5)
	bne.w	return_34FFC
	move.w	#5,$4A(a5)
	subq.w	#1,$48(a5)
	beq.w	loc_34FFE
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Enemy0F_UFOBeam_Init,4(a0)	; laser beam

return_34FFC:
	rts
; ---------------------------------------------------------------------------

loc_34FFE:
	sf	$46(a5)
	sf	(Some_UFO_Shooting).w
	rts
; ---------------------------------------------------------------------------
;loc_35008
Enemy_HandleAcceleration:
	move.l	d0,d7	; d0 = x acceleration?
	bmi.w	loc_3501E
	add.l	x_vel(a3),d7
	cmp.l	d1,d7	; d1 = desired x speed?
	blt.w	loc_3502A
	move.l	d1,d7	; cap the speed at the desired value
	bra.w	loc_3502A
; ---------------------------------------------------------------------------

loc_3501E:
	add.l	x_vel(a3),d7
	cmp.l	d1,d7
	bgt.w	loc_3502A
	move.l	d1,d7

loc_3502A:
	move.l	d7,x_vel(a3)

	move.l	d2,d7
	bmi.w	loc_35044
	add.l	y_vel(a3),d7
	cmp.l	d3,d7
	blt.w	loc_35050
	move.l	d3,d7
	bra.w	loc_35050
; ---------------------------------------------------------------------------

loc_35044:
	add.l	y_vel(a3),d7
	cmp.l	d3,d7
	bgt.w	loc_35050
	move.l	d3,d7

loc_35050:
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_35056:
	move.w	collision_type(a3),d7
	bmi.w	loc_35070
	beq.w	return_3506E
	subq.w	#4,d7
	clr.w	collision_type(a3)
	move.l	(a4,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

return_3506E:
	rts
; ---------------------------------------------------------------------------

loc_35070:
	clr.w	collision_type(a3)
	rts
; ---------------------------------------------------------------------------
;loc_35076
Enemy0F_UFO_ExecCollisionBehavior:
	lea	Enemy0F_UFO_CollisionBehaviors(pc),a4
	bra.s	loc_35056
; ---------------------------------------------------------------------------
;off_3507C
Enemy0F_UFO_CollisionBehaviors:
	dc.l Enemy0F_UFO_BounceWall
	dc.l Enemy0F_UFO_BounceWall
	dc.l Enemy0F_UFO_BounceFloorCeil
	dc.l Enemy0F_UFO_BounceFloorCeil
	dc.l Enemy0F_UFO_BounceUpSlope
	dc.l Enemy0F_UFO_BounceDownSlope
	dc.l Enemy0F_UFO_Hurt	; hit by e.g. projectile
	dc.l return_350A8	; touching kid
	dc.l return_350A8	; touching kid
	dc.l return_350A8	; touching kid
	dc.l Enemy0F_UFO_Hurt	; kid jumped on top
; ---------------------------------------------------------------------------

return_350A8:
	rts
; ---------------------------------------------------------------------------
;loc_350AA
Enemy0F_UFO_BounceUpSlope:
	bsr.w	loc_350F2
	move.l	#-$10000,d7
	move.l	d7,x_vel(a3)
	move.l	d7,y_vel(a3)
	move.l	#$800,d7
	move.l	d7,d0
	move.l	d7,d2
	moveq	#0,d1
	moveq	#0,d3
	rts
; ---------------------------------------------------------------------------
;loc_350CC
Enemy0F_UFO_BounceDownSlope:
	bsr.w	loc_350F2
	move.l	#$10000,d7
	move.l	d7,x_vel(a3)
	neg.l	d7
	move.l	d7,y_vel(a3)
	move.l	#$800,d7
	move.l	d7,d2
	neg.l	d7
	move.l	d7,d0
	moveq	#0,d1
	moveq	#0,d3
	rts
; ---------------------------------------------------------------------------

loc_350F2:
	move.l	x_vel(a3),d7
	sub.l	d7,x_pos(a3)
	move.l	y_vel(a3),d7
	sub.l	d7,y_pos(a3)
	rts
; ---------------------------------------------------------------------------
;loc_35104
Enemy0F_UFO_BounceWall:
	moveq	#0,d1
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	bmi.w	loc_35120
	tst.l	d0
	bmi.w	return_35128
	neg.l	d0
	bra.w	return_35128
; ---------------------------------------------------------------------------

loc_35120:
	tst.l	d0
	bpl.w	return_35128
	neg.l	d0

return_35128:
	rts
; ---------------------------------------------------------------------------
;loc_3512A
Enemy0F_UFO_BounceFloorCeil:
	moveq	#0,d3
	move.l	y_vel(a3),d7
	neg.l	d7
	move.l	d7,y_vel(a3)
	bmi.w	loc_35146
	tst.l	d2
	bmi.w	return_3514E
	neg.l	d2
	bra.w	return_3514E
; ---------------------------------------------------------------------------

loc_35146:
	tst.l	d2
	bpl.w	return_3514E
	neg.l	d2

return_3514E:
	rts
; ---------------------------------------------------------------------------
;loc_35150
Enemy0F_UFO_Hurt:
	tst.b	$47(a5)
	beq.w	loc_351EE
	tst.b	$50(a5)
	beq.w	loc_35174
	subq.w	#1,(Number_UFOs_OnScreen).w
	bne.w	loc_35174
	move.l	d0,-(sp)
	moveq	#sfx_UFO_hovering,d0
	jsr	(j_PlaySound2).l
	move.l	(sp)+,d0

loc_35174:
	tst.b	$46(a5)
	beq.w	loc_35180
	sf	(Some_UFO_Shooting).w

loc_35180:
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_355E2,4(a0)	; UFO Driver?
	move.w	#$FFFF,$46(a0)
	move.w	x_vel(a3),$44(a0)
	sf	$13(a1)
	st	is_moved(a3)
	move.l	#$30000,y_vel(a3)
	move.l	#stru_34CA0,d7
	jsr	(j_Init_Animation).w

loc_351B6:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	beq.s	loc_351B6
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
unk_351C4:	dc.b $FF
	dc.b $FB ; û
	dc.b $FF
	dc.b $FD ; ý
	dc.b $FF
	dc.b $FD ; ý
	dc.b $FF
	dc.b $FC ; ü
	dc.b $FF
	dc.b $FA ; ú
	dc.b $FF
	dc.b $FB ; û
	dc.b $FF
	dc.b $FC ; ü
	dc.b $FF
	dc.b $F9 ; ù
	dc.b $FF
	dc.b $FE ; þ
	dc.b $FF
	dc.b $FA ; ú
	dc.b   0
	dc.b   1
	dc.b $FF
	dc.b $FA ; ú
	dc.b   0
	dc.b   1
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   3
	dc.b $FF
	dc.b $FC ; ü
	dc.b   0
	dc.b   4
	dc.b $FF
	dc.b $FA ; ú
	dc.b   0
	dc.b   5
	dc.b $FF
	dc.b $FD ; ý
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_351EE:
	lea	unk_351C4(pc),a4

loc_351F2:
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_354DA,4(a0)
	moveq	#0,d7
	move.w	(a4)+,d7
	beq.w	loc_35228
	swap	d7
	asr.l	#1,d7
	move.l	x_vel(a3),d6
	asr.l	#1,d6
	add.l	d6,d7
	move.l	d7,$44(a0)
	moveq	#0,d7
	move.w	(a4)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,$48(a0)
	bra.s	loc_351F2
; ---------------------------------------------------------------------------

loc_35228:
	st	$47(a5)
	jsr	loc_32188(pc)
	move.l	a1,$3A(a5)
	move.w	#$F,d0
	exg	a1,a3
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	#stru_34D02,d7
	jsr	(j_Init_Animation).w
	exg	a1,a3
	st	$13(a1)
	sf	$19(a1)
	sf	$14(a1)
	sf	$3C(a1)
	move.b	#1,$10(a1)
	move.l	#stru_34C92,d7
	jsr	(j_Init_Animation).w
	addi.l	#$40000,y_vel(a3)
	move.l	#$FFFFF400,d2
	moveq	#0,d3
	rts
; ---------------------------------------------------------------------------

loc_35280:
	bsr.w	loc_320E2
	bne.w	loc_3528A
	rts
; ---------------------------------------------------------------------------

loc_3528A:
	tst.b	$50(a5)
	beq.w	loc_352A6
	subq.w	#1,(Number_UFOs_OnScreen).w
	bne.w	loc_352A6
	move.l	d0,-(sp)
	moveq	#sfx_UFO_hovering,d0
	jsr	(j_PlaySound2).l
	move.l	(sp)+,d0

loc_352A6:
	tst.b	$46(a5)
	beq.w	loc_352B2
	sf	(Some_UFO_Shooting).w

loc_352B2:
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_352D2
	btst	#6,d0
	beq.s	loc_352E0
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_352E0
; ---------------------------------------------------------------------------

loc_352D2:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_352E0:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

Enemy0F_UFO_SpeedToPos:
	move.l	x_vel(a3),d7
	add.l	d7,x_pos(a3)
	move.l	y_vel(a3),d7
	add.l	d7,y_pos(a3)
	tst.b	$47(a5)
	beq.w	return_35324
	move.b	x_direction(a3),$16(a1)
	move.w	y_pos(a3),d7
	subi.w	#$B,d7
	move.w	d7,$1E(a1)
	move.w	#4,d6
	tst.b	$16(a1)
	beq.s	loc_3531A
	neg.w	d6

loc_3531A:
	move.w	x_pos(a3),d7
	sub.w	d6,d7
	move.w	d7,$1A(a1)

return_35324:
	rts
; ---------------------------------------------------------------------------

loc_35326:
	jsr	(j_Get_RandomNumber_byte).w
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	x_pos(a3),d6
	eor.b	d6,d7
	andi.w	#$F,d7
	asl.w	#4,d7
	lea	unk_35344(pc),a4
	add.w	d7,a4
	bra.w	loc_35444
; ---------------------------------------------------------------------------
; each entry is 4 longs
unk_35344:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F4 ; ô
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F8 ; ø
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F8 ; ø
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F4 ; ô
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F8 ; ø
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b $80 ; €
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F4 ; ô
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F4 ; ô
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; þ
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F8 ; ø
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $F0 ; ð
	dc.b   0
; ---------------------------------------------------------------------------

loc_35444:
	st	x_direction(a3)
	move.l	(a4)+,d1
	bpl.w	loc_35452
	sf	x_direction(a3)

loc_35452:
	move.l	(a4)+,d3
	move.l	(a4)+,d0
	bne.w	loc_3546E
	move.l	#$C00,d0
	tst.l	x_vel(a3)
	bmi.w	loc_35496
	neg.l	d0
	bra.w	loc_35496
; ---------------------------------------------------------------------------

loc_3546E:
	move.l	x_vel(a3),d7
	bmi.w	loc_35488
	tst.l	d1
	bmi.w	loc_35496
	cmp.l	d7,d1
	bge.w	loc_35496
	neg.l	d0
	bra.w	loc_35496
; ---------------------------------------------------------------------------

loc_35488:
	tst.l	d1
	bpl.w	loc_35496
	cmp.l	d7,d1
	ble.w	loc_35496
	neg.l	d0

loc_35496:
	move.l	(a4)+,d2
	bne.w	loc_354B0
	move.l	#$C00,d2
	tst.l	y_vel(a3)
	bmi.w	return_354D8
	neg.l	d2
	bra.w	return_354D8
; ---------------------------------------------------------------------------

loc_354B0:
	move.l	y_vel(a3),d7
	bmi.w	loc_354CA
	tst.l	d3
	bmi.w	return_354D8
	cmp.l	d7,d3
	bge.w	return_354D8
	neg.l	d2
	bra.w	return_354D8
; ---------------------------------------------------------------------------

loc_354CA:
	tst.l	d3
	bpl.w	return_354D8
	cmp.l	d7,d3
	ble.w	return_354D8
	neg.l	d2

return_354D8:
	rts
; ---------------------------------------------------------------------------

loc_354DA:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.l	$44(a5),x_vel(a3)
	move.l	$48(a5),y_vel(a3)
	move.w	$1A(a0),x_pos(a3)
	subi.w	#$B,x_pos(a3)
	tst.b	x_direction(a3)
	beq.w	loc_35512
	addi.w	#$16,x_pos(a3)

loc_35512:
	move.w	$1E(a0),y_pos(a3)
	subi.w	#$18,y_pos(a3)
	st	$13(a3)
	st	is_moved(a3)
	sf	has_level_collision(a3)
	sf	$19(a3)
	move.b	#1,priority(a3)
	move.w	#$F,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.w	#(LnkTo_unk_C8408-Data_Index),addroffset_sprite(a3)
	move.w	#5,d0

loc_3554A:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.s	loc_3555A
	not.b	x_direction(a3)
	move.w	#$A,d0

loc_3555A:
	addi.l	#$3000,y_vel(a3)
	tst.b	$19(a3)
	beq.s	loc_3554A
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
;loc_3556C
Enemy0F_UFOBeam_Init:
	move.l	#$3000003,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	addi.w	#$A,y_pos(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	move.b	#1,priority(a3)
	move.w	#$F,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	$19(a3)
	move.w	#(LnkTo_unk_C83A0-Data_Index),addroffset_sprite(a3)
	move.l	#$30000,y_vel(a3)
	subi.w	#4,x_pos(a3)
	tst.b	$16(a0)
	beq.w	Enemy0F_UFOBeam_Loop
	addi.w	#8,x_pos(a3)

;loc_355D4
Enemy0F_UFOBeam_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	collision_type(a3)
	beq.s	Enemy0F_UFOBeam_Loop
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_355E2:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$A(a5),a0
	move.l	$36(a0),a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),y_pos(a3)
	subi.w	#$B,y_pos(a3)
	move.b	$16(a0),x_direction(a3)
	move.w	$46(a5),y_vel(a3)
	move.w	$44(a5),x_vel(a3)
	st	$13(a3)
	st	$13(a3)
	st	is_moved(a3)
	st	has_level_collision(a3)
	st	has_kid_collision(a3)
	sf	$19(a3)
	move.b	#1,priority(a3)
	move.w	#$F,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	move.l	#stru_34CD0,d7
	jsr	(j_Init_Animation).w

loc_3564C:
	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#1,d0
	bsr.w	Object_CheckInRange
	addi.l	#$2000,y_vel(a3)
	lea	(off_3569E).l,a4
	moveq	#1,d0
	bsr.w	loc_35762
	bra.s	loc_3564C
; ---------------------------------------------------------------------------

loc_3566C:
	move.l	#$FFFF8000,x_vel(a3)
	tst.b	x_direction(a3)
	beq.w	loc_35680
	neg.l	x_vel(a3)

loc_35680:
	sf	has_kid_collision(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Object_CheckInRange
	lea	(off_356B6).l,a4
	moveq	#0,d0
	bsr.w	loc_35762
	bsr.w	loc_35724
	bra.s	loc_35680
; ---------------------------------------------------------------------------
off_3569E:	dc.l loc_357FA
	dc.l loc_357FA
	dc.l loc_3581E
	dc.l loc_35810
	dc.l loc_35838
	dc.l loc_35864
off_356B6:	dc.l loc_356CE
	dc.l loc_356CE
	dc.l loc_3571E
	dc.l loc_3571E
	dc.l loc_356F2
	dc.l loc_356F2
; ---------------------------------------------------------------------------

loc_356CE:

	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	lsl.l	#2,d7
	add.l	d7,x_pos(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------
word_356E4:	dc.w $FFFF
	dc.b $FF
	dc.b $FE ; þ
	dc.b $FF
	dc.b $FD ; ý
	dc.b $FF
	dc.b $FC ; ü
	dc.b $FF
	dc.b $FB ; û
	dc.b $FF
	dc.b $FA ; ú
	dc.b $FF
	dc.b $F9 ; ù
; ---------------------------------------------------------------------------

loc_356F2:

	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$2F,d7
	cmpi.w	#$A,d7
	bgt.s	loc_356CE
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#6,d7
	move.w	word_356E4(pc,d7.w),d7
	move.w	d7,y_vel(a3)
	move.l	x_vel(a3),d7
	asl.l	#1,d7
	move.l	d7,x_vel(a3)
	bra.w	loc_3564C
; ---------------------------------------------------------------------------

loc_3571E:
	addq.w	#4,sp
	bra.w	loc_35680
; ---------------------------------------------------------------------------

loc_35724:
	move.w	x_pos(a3),d7
	subi.w	#$F,d7
	tst.b	x_direction(a3)
	beq.w	loc_35738
	addi.w	#$1E,d7

loc_35738:
	move.w	y_pos(a3),d6
	addi.w	#8,d6
	lea	($FFFF4A04).l,a4
	lsr.w	#4,d6
	add.w	d6,d6
	move.w	(a4,d6.w),a4
	lsr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bne.s	loc_356F2
	rts
; ---------------------------------------------------------------------------

loc_35762:
	move.w	collision_type(a3),d7
	beq.s	return_357C0
	bmi.w	loc_357C2
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d7
	beq.s	loc_357C2
	cmpi.w	#$1C,d7
	beq.s	loc_357C2
	bgt.w	loc_35788
	subq.w	#4,d7
	move.l	(a4,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

loc_35788:
	cmpi.w	#$28,d7
	bge.w	return_357C0
	tst.b	(Berzerker_charging).w
	beq.w	return_357C0
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	$26(a4),d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	move.l	#$FFFC0000,y_vel(a3)
	sf	has_level_collision(a3)
	move.l	#stru_34CAE,d7
	jsr	(j_Init_Animation).w
	bra.w	loc_357E6
; ---------------------------------------------------------------------------

return_357C0:
	rts
; ---------------------------------------------------------------------------

loc_357C2:
	clr.l	y_vel(a3)
	clr.l	x_vel(a3)
	sf	has_level_collision(a3)
	move.l	#stru_34CAE,d7
	jsr	(j_Init_Animation).w
	tst.w	d0
	bne.w	loc_357E6
	jsr	(j_Hibernate_UntilAnimFinished).w

loc_357E2:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_357E6:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$4000,y_vel(a3)
	tst.b	$19(a3)
	beq.s	loc_357E6
	bra.s	loc_357E2
; ---------------------------------------------------------------------------

loc_357FA:
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	lsl.l	#2,d7
	add.l	d7,x_pos(a3)
	not.b	x_direction(a3)
	rts
; ---------------------------------------------------------------------------

loc_35810:
	move.l	y_vel(a3),d7
	neg.l	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_3581E:
	addq.w	#4,sp
	clr.l	y_vel(a3)
	clr.w	$20(a3)
	addi.w	#8,y_pos(a3)
	andi.w	#$FFF0,y_pos(a3)
	bra.w	loc_3566C
; ---------------------------------------------------------------------------

loc_35838:
	move.l	#-$10000,x_vel(a3)
	move.l	#-$10000,y_vel(a3)
	rts
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	asr.l	#1,d7
	move.l	y_vel(a3),d6
	neg.l	d6
	asr.w	#1,d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_35864:
	move.l	#$10000,x_vel(a3)
	move.l	#-$10000,y_vel(a3)
	rts
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	asr.l	#1,d7
	asr.l	#1,d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts
