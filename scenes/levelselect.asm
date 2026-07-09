LevelSelect_ChkKey:
	btst	#6,(Ctrl_1_Held).w   ;Ctrl_1_Held
	sne	(LevelSelect_Flag).w
	jmp	(j_loc_6E2).w

LevelSelect_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(sub_1CC88).l
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	LevelSelect_DrawText
	movem.l	(sp)+,d0-d3/a0-a3
	move.w	#TotalNumberLevels+1,d6
	bsr.s	LevelSelect_Input
	bclr	#5,(Ctrl_Pressed).w
	bne.s	Stop_Music
	bclr	#4,(Ctrl_Pressed).w
	bne.s	Play_SoundTest
	bclr	#7,(Ctrl_Pressed).w
	beq.s	LevelSelect_Loop

;LevelSelect_Exit:
	move.w	(Options_Selected_Option).w,(Current_LevelID).w
	beq.s	Play_SoundTest
	subi.w #1, (Current_LevelID).w
	bra.w	CostumeSelect
; ---------------------------------------------------------------------------
Stop_Music:
	jsr     (j_StopMusic).l
	bra.s	LevelSelect_Loop
Play_SoundTest:
	tst.w	(Options_Selected_Option).w
	bne.s 	LevelSelect_Loop
	jsr     (j_PlaySound2).l
	jsr     (j_StopMusic).l
	move.l  D0,-(SP)
	move.w	(SoundTestOption).w,d0
	jsr     (j_PlaySound).l
	move.l  (SP)+,D0
	bra.s	LevelSelect_Loop
; ---------------------------------------------------------------------------
; d6 = max number of options
LevelSelect_Input:
	move.w	(Options_Selected_Option).w,d7
	bne.s not_sound_test
	move.w	(SoundTestOption).w,d7
	bclr	#2,(Ctrl_Pressed).w
	beq.s	++	; LEFT pressed?
	;jsr	(sub_1BC26).l	; play selection sound
	subq.w	#1,d7
	btst	#6,(Ctrl_Held).w
	beq.s	+	; A held?
	subq.w	#6,d7
+
	tst.w	d7
	bpl.s	+
	clr.w	d7
+
	bclr	#3,(Ctrl_Pressed).w
	beq.s	++	; RIGHT pressed?
	;jsr	(sub_1BC26).l	; play selection sound
	addq.w	#1,d7
	btst	#6,(Ctrl_Held).w
	beq.s	+	; A held?
	addq.w	#6,d7
+
	cmpi.w	#$00FF,d7
	ble.s	+
	moveq	#$00FF, d7
+
	move.w	d7,(SoundTestOption).w
	move.w	(Options_Selected_Option).w,d7
not_sound_test:
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
LevelSelect_DrawText:
	move.w	(Options_Selected_Option).w,d6
	subq.w	#3+1,d6
	lea	(AddrTbl_LevelNames).l,a3
	move.w	#$C,d4		; y_pos
LevelSelect_DrawText_loop:
	clr.b	(LevelSelect_ActNumber).w
	lea	LevelSelect_spec_char_tbl_junk(pc),a4	; dirty fix: points to 0, $FF
	tst.w	d6
	bmi.s	LevelSelect_DrawText_Do
	cmpi.w	#TotalNumberLevels,d6
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
	cmpi.w	#$FFFF,d6
	bne.s +
	bsr.s DrawSoundTest
	bra.s ++
+
	bsr.s	LevelSelect_DrawTextLine
+
	addq.w	#1,d6
	addq.w	#2,d4
	cmpi.w	#$12,d4
	seq	d3
	cmpi.w	#$1A,d4
	blt.s	LevelSelect_DrawText_loop
	rts

; ---------------------------------------------------------------------------
SoundTestOption = Level_Special_Effects
HexString = Level_terrain_layout
DrawSoundTest:
	movem.l	d6/a3-a4, -(sp)
	lea (sndtext).l, A3
	lea (HexString).l, a4
-	move.b (a3)+, (a4)+
	bpl.s -
	subi #1, a4
	move.b #0, (a4)+
	move.w (SoundTestOption).w, d6
	jsr (ConvertToHex).l
	lea (HexString).l, a4
	bsr.s	LevelSelect_DrawTextLine
	movem.l	(sp)+, d6/a3-a4
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
CostumeSelect:
	clr.w	(Options_Selected_Option).w
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

	bclr	#7,(Ctrl_Pressed).w
	
CostumeSelect_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	jsr	(sub_1CC88).l
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	CostumeSelect_DrawText
	movem.l	(sp)+,d0-d3/a0-a3
	move.w	#9,d6
	bsr.w	LevelSelect_Input
	bclr	#7,(Ctrl_1_Pressed).w
	beq.s	CostumeSelect_Loop

;CostumeSelect_Exit:
	move.w	(Options_Selected_Option).w,d7
	move.w	d7,(Current_Helmet).w
	lea	(unk_7EC2).l,a4	; helmet hitpoints
	move.b	(a4,d7.w),d7
	move.w	d7,(Number_Hitpoints).w
	;move.w	d7,(Extra_hitpoint_slots).w
	;add soundtest: jsr	($E1328).l
	clr.w	($FFFFFBCC).w
	st	($FFFFFBCE).w
	st	($FFFFFC36).w

	jsr	(j_sub_8C2).w
	move.w	#8,(Game_Mode).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
CostumeSelect_DrawText:
	move.b	#9,(LevelSelect_ActNumber).w

-
	moveq	#0,d5
	move.b	(LevelSelect_ActNumber).w,d5
	cmp.w	(Options_Selected_Option).w,d5
	seq	d3
	lea	CostumeTextOffsets(pc),a4
	add.w	d5,d5
	add.w	(a4,d5.w),a4
	jsr	(DrawTextLine_Offset).l
	sub.b	#1,(LevelSelect_ActNumber).w
	bge.s	-
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
sndtext: dc.b "sound\0test", $FF, $FF
; ---------------------------------------------------------------------------
ConvertToHex:
 	movem.l	d5/a2,-(sp)

	moveq	#$0,d5
	lea	(HexTable).l ,a2
	move.w	d6,d5
	lsr.w	#4,d5
	andi.w	#$F,d5
	move.b	(a2,d5.w),(a4)+		; move para o próximo byte


	move.w	d6,d5
	andi.w	#$F,d5
	move.b	(a2,d5.w),(a4)+		; move para o próximo byte
	
	move.b	#$FF,(a4)+

	movem.l	(sp)+,d5/a2
	rts

HexTable: dc.b $4e+10,$4e+1,$4e+2,$4e+3,$4e+4,$4e+5,$4e+6,$4e+7,$4e+8,$4e+9,'A'-$D,'B'-$D,'C'-$D,'D'-$D,'E'-$D,'F'-$D