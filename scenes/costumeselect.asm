LevelSelect_ChkKey:
	;btst	#6,($FFFFF80D).w   ;Ctrl_1_Held
	;sne	($FFFFFDC7).w
	jmp	(j_loc_6E2).w

Costume_DelayTime = 60*15	; 15 seconds

LevelSelect_Loop:
;	jsr	(j_Hibernate_Object_1Frame).w
;	jsr	(sub_1CC88).l
;	movem.l	d0-d3/a0-a3,-(sp)
;	bsr.w	LevelSelect_DrawText
;	movem.l	(sp)+,d0-d3/a0-a3
;	move.w	#$69,d6
;	bsr.s	LevelSelect_Input
;	bclr	#7,($FFFFF80E).w
;	beq.s	LevelSelect_Loop
;
;;LevelSelect_Exit:
;	move.w	($FFFFFDCC).w,($FFFFFC44).w
	move.w	#Costume_DelayTime,$FFFFFDC4
	bra.w	CostumeSelect
; ---------------------------------------------------------------------------
; d6 = max number of options
LevelSelect_Input:
	move.w	($FFFFFDCC).w,d7
	bclr	#0,($FFFFF813).w
	beq.s	++	; UP pressed?
	jsr	(sub_1BC26).l	; play selection sound
	subq.w	#1,d7
	btst	#6,($FFFFF812).w
	beq.s	+	; A held?
	subq.w	#6,d7
+
	tst.w	d7
	bpl.s	+
	clr.w	d7
+
	bclr	#1,($FFFFF813).w
	beq.s	++	; DOWN pressed?
	jsr	(sub_1BC26).l	; play selection sound
	addq.w	#1,d7
	btst	#6,($FFFFF812).w
	beq.s	+	; A held?
	addq.w	#6,d7
+
	cmp.w	d6,d7
	ble.s	+
	move.w	d6,d7
+
	move.w	d7,($FFFFFDCC).w
	rts

; ---------------------------------------------------------------------------
LevelSelect_DrawText:
	move.w	($FFFFFDCC).w,d6
	subq.w	#3,d6
	lea	(AddrTbl_LevelNames).l,a3
	move.w	#$C,d4		; y_pos
LevelSelect_DrawText_loop:
	clr.b	($FFFFFDC6).w
	lea	LevelSelect_spec_char_tbl_junk(pc),a4	; dirty fix: points to 0, $FF
	tst.w	d6
	bmi.s	LevelSelect_DrawText_Do
	cmpi.w	#$69,d6	; ;69 = last level
	bgt.s	LevelSelect_DrawText_Do

	move.w	d6,d7
	cmpi.w	#FirstElsewhere_LevelID,d7
	blt.s	+
	move.b	d6,($FFFFFDC6).w
	subi.b	#FirstElsewhere_LevelID-1,($FFFFFDC6).w
	move.w	#FirstElsewhere_LevelID,d7
+
	mulu.w	#$A,d7
	move.l	(a3,d7.w),a4	; address of level name
	tst.b	($FFFFFDC6).w
	bne.s	LevelSelect_DrawText_Do
	move.w	8(a3,d7.w),d2	; act number
	move.b	d2,($FFFFFDC6).w
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
;x_pos: #7
;y_pos: d4
LevelSelect_make_cmd:
	moveq	#0,d5
	move.w	d4,d5
	lsl.w	#7,d5	; *$80, width of a plane in bytes
	add.w	#$E,d5	; + 2*x_pos
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
	move.b	($FFFFFDC6).w,d2
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
CostumeSelect:
	clr.w	($FFFFFDCC).w
	move.w	#$A,d4
	
CostumeSelect_loop3:
	bsr.w	LevelSelect_make_cmd
	move.w	#$1A,d3		; line width
-
	move.w	#0,(a6)	; clear
	dbf	d3,-
	
	jsr	(j_sub_924).w
	addq.w	#2,d4
	cmpi.w	#$1E,d4
	blt.s	CostumeSelect_loop3

	bclr	#7,($FFFFF813).w
	
CostumeSelect_Loop:
	tst.w	$FFFFFDC4
	bmi.s	+
	subq.w	#1,$FFFFFDC4
+
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(sub_1CC88).l
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	CostumeSelect_DrawText
	movem.l	(sp)+,d0-d3/a0-a3
	move.w	#9,d6
	bsr.w	LevelSelect_Input
	tst.w	$FFFFFDC4	; counter passed 0?
	bpl.s	CostumeSelect_Loop ; if not, don't check for start pressed
	bclr	#7,($FFFFF80E).w
	beq.s	CostumeSelect_Loop

;CostumeSelect_Exit:
	move.w	($FFFFFDCC).w,d7
	move.w	d7,($FFFFFC46).w
	lea	(unk_7EC2).w,a4	; helmet hitpoints
	move.b	(a4,d7.w),d7
	move.w	d7,($FFFFFC40).w
	;move.w	d7,($FFFFFC4A).w
	;add soundtest: jsr	($E1328).l
	clr.w	($FFFFFBCC).w
	st	($FFFFFBCE).w
	st	($FFFFFC36).w

	jsr	(j_sub_8C2).w
	move.w	#8,($FFFFFBCA).w
	sf	($FFFFFDC7).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
CostumeSelect_DrawText:
	move.b	#9,($FFFFFDC6).w

-
	moveq	#0,d5
	move.b	($FFFFFDC6).w,d5
	cmp.w	($FFFFFDCC).w,d5
	seq	d3
	lea	CostumeTextOffsets(pc),a4
	add.w	d5,d5
	add.w	(a4,d5.w),a4
	jsr	(DrawTextLine_Offset).l
	sub.b	#1,($FFFFFDC6).w
	bge.s	-


	move.w	$FFFFFDC4,d5
	bpl.w	CostumeSelect_DrawWait

	; remove the waiting text
	jsr	(j_sub_914).w
	move.l	#vdpComm($0000+$80*19+2*18,VRAM,WRITE),4(a6)
	move.w	#14,d3
-	move.w	#0,(a6)
	dbf	d3,-
	jmp	(j_sub_924).w


CostumeSelect_DrawWait:
	st	d3
	lea	wait,a4
	jsr	(DrawTextLine_Offset).l

	move.w	$FFFFFDC4,d5
	add.w	#60,d5
	jsr	(j_sub_914).w
	move.l	#vdpComm($0000+$80*19+2*23,VRAM,WRITE),4(a6)

	ext.l	d5
	add.w	#1,d5
	divu.w	#60,d5
	ext.l	d5
	divu.w	#10,d5

	move.w	d5,d4
	sub.w	#1,d4
	bpl.s	+
	move.w	#9,d4
+	add.w	#$E524,d4
	move.w	d4,(a6)

	swap	d5
	move.w	d5,d4
	sub.w	#1,d4
	bpl.s	+
	move.w	#9,d4
+	add.w	#$E524,d4
	move.w	d4,(a6)

	jsr	(j_sub_924).w
	rts
	
; ---------------------------------------------------------------------------
CostumeTextOffsets:
	dc.w	cost0-CostumeTextOffsets
	dc.w	cost1-CostumeTextOffsets
	dc.w	cost2-CostumeTextOffsets
	dc.w	cost3-CostumeTextOffsets
	dc.w	cost4-CostumeTextOffsets
	dc.w	cost5-CostumeTextOffsets
	dc.w	cost6-CostumeTextOffsets
	dc.w	cost7-CostumeTextOffsets
	dc.w	cost8-CostumeTextOffsets
	dc.w	cost9-CostumeTextOffsets
; ---------------------------------------------------------------------------
CostumeTexts:
cost0:	dc.b	0,  0, "NONE", 0
cost1:	dc.b	0,  2, "SKYCUTTER", 0
cost2:	dc.b	0,  4, "CYCLONE", 0
cost3:	dc.b	0,  6, "REDmSTEALTH", 0
cost4:	dc.b	0,  8, "EYECLOPS", 0
cost5:	dc.b	0, $A, "JUGGERNAUT", 0
cost6:	dc.b	0, $C, "IRONmKNIGHT", 0
cost7:	dc.b	0, $E, "BERZERKER", 0
cost8:	dc.b	0,$10, "MANIAXE", 0
cost9:	dc.b	0,$12, "MICROMAX", 0
wait:   dc.b   $B,  9, "WAITmmmmSECONDS", 0