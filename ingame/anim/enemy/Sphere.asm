;stru_36174:	; sphere normal?
	anim_frame	  1,   9, LnkTo_unk_C8120-Data_Index
	anim_frame	  1,   9, LnkTo_unk_C8128-Data_Index
	anim_frame	  1,   9, LnkTo_unk_C8130-Data_Index
	dc.b   2, $D	; go back $D bytes, i.e. to beginning of anim list
stru_36182:	; sphere disappearing?
	anim_frame	  1,  $A, LnkTo_unk_C8108-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8110-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8118-Data_Index
	dc.b   0	; stop animating
	dc.b   0
	anim_frame	1, 9, LnkTo_unk_C80F8-Data_Index
	dc.b   2
	dc.b   5
	anim_frame	1, 9, LnkTo_unk_C80F0-Data_Index
	dc.b   2
	dc.b   5
	anim_frame	1, 9, LnkTo_unk_C8100-Data_Index
	dc.b   2
	dc.b   5