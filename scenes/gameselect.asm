LevelSelect_ChkKey:
	jsr	Get_RandomNumber_long
	move.l	d7,Level_RNG_seed
	clr.w	Level_RNG_seed	; clear the first two bytes, leave the last 2

	;btst	#6,(Ctrl_1_Held).w   ;Ctrl_1_Held
	st	(LevelSelect_Flag).w
	jmp	(j_loc_6E2).w

LevelSelect_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(sub_1CC88).l
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	LevelSelect_DrawText
	movem.l	(sp)+,d0-d3/a0-a3
	move.w	#$3,d6	; 3 options
	bsr.s	LevelSelect_Input
	bclr	#7,(Ctrl_1_Pressed).w
	beq.s	LevelSelect_Loop

;LevelSelect_Exit:
	move.w	(Options_Selected_Option).w,(Current_LevelID).w
	bra.w	LengthSelect
; ---------------------------------------------------------------------------
; d6 = max number of options
LevelSelect_Input:
	move.w	(Options_Selected_Option).w,d7
	bclr	#2,(Ctrl_Pressed).w
	beq.s	+	; LEFT pressed?
	jsr	(sub_1BC26).l	; play selection sound
	addq.w	#1,d7

	cmp.w	d6,d7
	ble.s	+
	move.w	d6,d7
+
	bclr	#3,(Ctrl_Pressed).w
	beq.s	+	; RIGHT pressed?
	jsr	(sub_1BC26).l	; play selection sound
	subq.w	#1,d7

	tst.w	d7
	bpl.s	+
	clr.w	d7
+
	move.w	d7,(Options_Selected_Option).w
	lsl.w	#2,d7

	move.w	#$F,d6
	lsl.w	d7,d6
	move.l	Level_RNG_seed,d3
	and.w	d6,d3
	lsr.w	d7,d3	; active digit

	bclr	#0,(Ctrl_Pressed).w
	beq.s	+	; UP pressed?
	jsr	(sub_1BC26).l	; play selection sound
	addq.w	#1,d3
+
	bclr	#1,(Ctrl_Pressed).w
	beq.s	+	; DOWN pressed?
	jsr	(sub_1BC26).l	; play selection sound
	subq.w	#1,d3
+
	and.w	#$F,d3
	; write the new selected digit
	lsl.w	d7,d3
	move.w	#$F,d6
	lsl.w	d7,d6
	not.w	d6
	move.l	Level_RNG_seed,d7
	and.w	d6,d7
	or.w	d3,d7
	move.l	d7,Level_RNG_seed
	
	rts

; ---------------------------------------------------------------------------
fixedtext0:	dc.b	2, 2, "RANDOMmSEED",   0
fixedtext1:	dc.b	0, 6, "EACHmRANDOMmSEEDmYIELDSmA",   0
fixedtext2:	dc.b	0, 8, "UNIQUEmRANDOMIZEDmGAMEf",   0
fixedtext3:	dc.b	0,10, "THEmSAMEmSEEDmALWAYSmYIELDS",   0
fixedtext4:	dc.b	0,12, "THEmSAMEmRANDOMIZEDmGAMEf",   0

hexnumbers:	dc.b "\x65\x5C\x5D\x5E\x5F\x60\x61\x62\x63\x64ABCDEF"
	align 2
; ---------------------------------------------------------------------------
LevelSelect_DrawText:
	st	d3
	lea	fixedtext0(pc),a4
	jsr	(DrawTextLine_Offset).l
	lea	fixedtext1(pc),a4
	jsr	(DrawTextLine_Offset).l
	lea	fixedtext2(pc),a4
	jsr	(DrawTextLine_Offset).l
	lea	fixedtext3(pc),a4
	jsr	(DrawTextLine_Offset).l
	lea	fixedtext4(pc),a4
	jsr	(DrawTextLine_Offset).l

	moveq	#22,d7
	moveq	#12,d4
	st	d3	; highlight
	bsr.w	LevelSelect_make_cmd
	move.w	#$E49B,d7
;	move.w	#$E4C8,d7
	; two art sets for letters and numbers.
	; subtract 2D to get from one to the other.
	; numbers come after letters, with one . in between.

	moveq	#$3,d4
	move.l	Level_RNG_seed,d6
-
	rol.w	#4,d6
	move.w	d6,d5
	and.w	#$F,d5
	move.b	hexnumbers(pc,d5.w),d5
	move.w	#$E49B,d7
	cmp.w	Options_Selected_Option,d4
	bne.s	+
	move.w	#$E4C8,d7
+
	add.w	d7,d5
	move.w	d5,(a6)
	;move.w	#0,(a6)
	dbf	d4,-

;	moveq	#0,d5
;	move.b	#"\x65",d5
;	add.w	d7,d5
;	move.w	d5,(a6)
;
;	moveq	#0,d5
;	move.b	#"\x5C",d5
;	add.w	d7,d5
;	move.w	d5,(a6)
;
;	moveq	#0,d5
;	move.b	#"B",d5
;	add.w	d7,d5
;	move.w	d5,(a6)
	jsr	(j_sub_924).w
	rts


	move.w	(Options_Selected_Option).w,d6
	subq.w	#3,d6
	lea	(AddrTbl_LevelNames).l,a3
	move.w	#$C,d4		; y_pos
LevelSelect_DrawText_loop:
	clr.b	(LevelSelect_ActNumber).w
	lea	LevelSelect_spec_char_tbl_junk(pc),a4	; dirty fix: points to 0, $FF
	tst.w	d6
	bmi.s	LevelSelect_DrawText_Do
	cmpi.w	#$69,d6
	bgt.s	LevelSelect_DrawText_Do

	move.w	d6,d7
	cmpi.w	#FirstElsewhere_LevelID,d7
	blt.s	+
	move.b	d6,(LevelSelect_ActNumber).w
	subi.b	#FirstElsewhere_LevelID-1,(LevelSelect_ActNumber).w
	move.w	#FirstElsewhere_LevelID,d7
+
	mulu.w	#$A,d7
	move.l	(a3,d7.w),a4	; address of level name
	tst.b	(LevelSelect_ActNumber).w
	bne.s	LevelSelect_DrawText_Do
	move.w	8(a3,d7.w),d2	; act number
	move.b	d2,(LevelSelect_ActNumber).w
LevelSelect_DrawText_Do:
	bsr.s	LevelSelect_DrawTextLine
	addq.w	#1,d6
	addq.w	#2,d4
	cmpi.w	#$12,d4
	seq	d3
	cmpi.w	#$1A,d4
	blt.s	LevelSelect_DrawText_loop
	rts

; ---------------------------------------------------------------------------
;x_pos: d7
;y_pos: d4
LevelSelect_make_cmd:
	moveq	#0,d5
	move.w	d4,d5
	lsl.w	#7,d5	; *$80, width of a plane in bytes
	add.w	d7,d5	; 
	add.w	d7,d5	; + 2*x_pos
	asl.l	#2,d5
	lsr.w	#2,d5
	add.w	#$4000,d5
	swap	d5
	;move.w	#$4DC,d7	; first character set
	;move.w	#$509,d7	; second character set

	;move.w	#$C509,d7
	move.w	#$C47B,d7
	;move.w	#$C4A8,d7
	tst.b	d3		; set palette line
	beq.s	+
	move.w	#$E4A8,d7
+
	jsr	(j_sub_914).w
	move.l	d5,4(a6)
	rts
; ---------------------------------------------------------------------------
LevelSelect_DrawTextLine:
	moveq	#7,d7
	bsr.s	LevelSelect_make_cmd
	move.w	#$1A,d3		; line width
LevelSelect_DrawTextLine_loop:
	moveq	#0,d5
	move.b	(a4)+,d5	; next letter
	cmpi.b	#$FF,d5		; string terminator
	beq.s	LevelSelect_DrawTextLine_number
	;subi.w	#$61,d5
	tst.b	d5
	beq.s	+
	cmpi.b	#$84,d5
	bcc.s	+
	cmpi.b	#$7C,d5
	bcc.s	LevelSelect_spec_char
	add.w	d7,d5
	bra.s	LevelSelect_DrawTextLine_cmd
+
	moveq	#0,d5
LevelSelect_DrawTextLine_cmd:
	move.w	d5,(a6)		; put onto plane
	subq.w	#1,d3
	bra.s	LevelSelect_DrawTextLine_loop

LevelSelect_DrawTextLine_number:	
	moveq	#0,d2
	move.b	(LevelSelect_ActNumber).w,d2
	tst.w	d2
	beq.s	LevelSelect_DrawTextLine_Clear
	move.w	#0,(a6)
	cmpi.w	#10,d2
	blt.s	LevelSelect_DrawTextLine_num_low
	nop
	;move.w	#$FFFF,d5
	moveq	#-1,d5
-
	addq.w	#1,d5
	sub.w	#10,d2
	bge.s	-
	add.w	#10,d2
	add.w	#$7B,d5
	add.w	d7,d5
	move.w	d5,(a6)
	subq.w	#1,d3

LevelSelect_DrawTextLine_num_low:
	tst.w	d2
	bne.s	+
	add.w	#10,d2
+
	add.w	#$7B,d2
	add.w	d7,d2
	move.w	d2,(a6)
	subq.w	#2,d3

LevelSelect_DrawTextLine_Clear:
	move.w	#0,(a6)
	dbf	d3,LevelSelect_DrawTextLine_Clear

	jsr	(j_sub_924).w
	rts			; end of text
; ---------------------------------------------------------------------------
LevelSelect_spec_char:
	subi.b	#$7C,d5
	lea	LevelSelect_spec_char_tbl(pc),a1
	add.w	d5,d5
	add.w	d5,d5
	add.w	d5,a1
-
	moveq	#0,d5
	move.b	(a1)+,d5
	beq.w	LevelSelect_DrawTextLine_loop
	add.w	d7,d5
	move.w	d5,(a6)
	subq.w	#1,d3
	bra.s	-
; ---------------------------------------------------------------------------
LevelSelect_spec_char_tbl:
	dc.b	"the", 0
	dc.b	"the", 0
	dc.b	"of",  0,   0
	dc.b	"to",  0,   0
LevelSelect_spec_char_tbl_junk:	
	dc.b	  0,   0,   0, $FF
	dc.b	  0,   0,   0,   0
	dc.b	  0,   0,   0,   0
	dc.b	$87,   0
; ---------------------------------------------------------------------------
; d6 = max number of options
LengthSelect_Input:
	move.w	(Options_Selected_Option).w,d7
	bclr	#0,(Ctrl_Pressed).w
	beq.s	++	; UP pressed?
	jsr	(sub_1BC26).l	; play selection sound
	subq.w	#1,d7
	btst	#6,(Ctrl_Held).w
	beq.s	+	; A held?
	subq.w	#6,d7
+
	tst.w	d7
	bpl.s	+
	clr.w	d7
+
	bclr	#1,(Ctrl_Pressed).w
	beq.s	++	; DOWN pressed?
	jsr	(sub_1BC26).l	; play selection sound
	addq.w	#1,d7
	btst	#6,(Ctrl_Held).w
	beq.s	+	; A held?
	addq.w	#6,d7
+
	cmp.w	d6,d7
	ble.s	+
	move.w	d6,d7
+
	move.w	d7,(Options_Selected_Option).w
	rts
; ---------------------------------------------------------------------------
LengthSelect:
	clr.w	(Options_Selected_Option).w
	move.w	#$A,d4
	
LengthSelect_loop3:
	moveq	#7,d7
	bsr.w	LevelSelect_make_cmd
	move.w	#$1A,d3		; line width
-
	move.w	#0,(a6)	; clear
	dbf	d3,-
	
	jsr	(j_sub_924).w
	addq.w	#2,d4
	cmpi.w	#$1E,d4
	blt.s	LengthSelect_loop3

	bclr	#7,(Ctrl_Pressed).w
	
LengthSelect_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(sub_1CC88).l
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	LengthSelect_DrawText
	movem.l	(sp)+,d0-d3/a0-a3
	move.w	#3,d6
	bsr.w	LengthSelect_Input
	bclr	#7,(Ctrl_1_Pressed).w
	beq.s	LengthSelect_Loop

;LengthSelect_Exit:
	move.w	(Options_Selected_Option).w,d7
	addq.w	#1,d7
	move.w	d7,Number_Bosses
	;move.w	d7,(Current_Helmet).w
	;lea	(unk_7EC2).l,a4	; helmet hitpoints
	;move.b	(a4,d7.w),d7
	;move.w	d7,(Number_Hitpoints).w
	;move.w	d7,(Extra_hitpoint_slots).w
	;add soundtest: jsr	($E1328).l
	clr.w	($FFFFFBCC).w
	st	($FFFFFBCE).w
	st	($FFFFFC36).w
	jsr	Init_LevelRandomizer

	jsr	(j_sub_8C2).w
	move.w	#8,(Game_Mode).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
LengthSelect_DrawText:
	move.b	#3,(LevelSelect_ActNumber).w

-
	moveq	#0,d5
	move.b	(LevelSelect_ActNumber).w,d5
	cmp.w	(Options_Selected_Option).w,d5
	seq	d3
	lea	LengthTextOffsets(pc),a4
	add.w	d5,d5
	add.w	(a4,d5.w),a4
	jsr	(DrawTextLine_Offset).l
	sub.b	#1,(LevelSelect_ActNumber).w
	bge.s	-
	rts
	
; ---------------------------------------------------------------------------
LengthTextOffsets:
	dc.w	lengthtxt0-LengthTextOffsets
	dc.w	lengthtxt1-LengthTextOffsets
	dc.w	lengthtxt2-LengthTextOffsets
	dc.w	lengthtxt3-LengthTextOffsets
; ---------------------------------------------------------------------------
LengthTexts:
lengthtxt0:	dc.b	0,  3, "mSHORTmGAMEmmm\x2FmBOSS",   0
lengthtxt1:	dc.b	0,  6, "MEDIUMmGAMEmmm\x30mBOSSES", 0
lengthtxt2:	dc.b	0,  9, "mmLONGmGAMEmmm\x31mBOSSES", 0
lengthtxt3:	dc.b	0, 12, "mmFULLmGAMEmmm\x32mBOSSES", 0
	align 2