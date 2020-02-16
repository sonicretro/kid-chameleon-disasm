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