; Some macros for data structures.
; ---------------------------------------------------------------------------

levnamhdr	macro	name, unknown, act
		dc.l	name
		dc.l	unknown
		dc.w	act
		endm

; ---------------------------------------------------------------------------
; the header file contains the following entries (12 bytes):
;		dc.b	xsize, ysize, fgstyle, bgstyle
;		dc.w	playerx, playery, flagx, flagy
maphdr		macro	fnamehdr, fgtile, block, bgtile, enemy
		binclude fnamehdr
		dc.l	fgtile, block, bgtile, enemy
		endm
; ---------------------------------------------------------------------------

anim_frame	macro	duration, unk2, spriteframe
		dc.b	duration
		dc.b	unk2
		dc.w	spriteframe
		endm

; ---------------------------------------------------------------------------

enemyloaddata	macro	paladdr, artaddr, codeaddr
		dc.w	paladdr
		dc.w	artaddr
		dc.l	codeaddr
		endm

; ---------------------------------------------------------------------------

sprite_frame_unc	macro	xcenter, ycenter, width, height, art
		dc.b	xcenter, ycenter
		dc.w	width, height
		binclude art
		endm

; ---------------------------------------------------------------------------

sprite_frame_vram	macro	spriteindex, xcenter, ycenter, width, height
		dc.w	spriteindex
		dc.b	xcenter, ycenter
		dc.w	width, height
		endm

; ---------------------------------------------------------------------------
ptfm_move	macro	duration, xvel, yvel
		dc.w	duration
		dc.l	xvel, yvel
		endm

; ---------------------------------------------------------------------------
ptfm		macro	xpos, ypos, bufL, bufR, bufT, bufB, t, s, h, v, pp
		dc.w	xpos, ypos
		dc.b	bufL, bufR, bufT, bufB
		dc.b	(t<<7)|(s<<1), (h<<4)|v
		dc.w	pp
		endm

; simplifying macros and functions, taken from Sonic 2 disassembly
; ---------------------------------------------------------------------------
; VDP addresses
VDP_data_port =			$C00000 ; (8=r/w, 16=r/w)
VDP_control_port =		$C00004 ; (8=r/w, 16=r/w)
PSG_input =			$C00011
; 68k address for the DMA macro
DMA_data_thunk = 		$FFFFF800


; makes a VDP address difference
vdpCommDelta function addr,((addr&$3FFF)<<16)|((addr&$C000)>>14)

; makes a VDP command
vdpComm function addr,type,rwd,(((type&rwd)&3)<<30)|((addr&$3FFF)<<16)|(((type&rwd)&$FC)<<2)|((addr&$C000)>>14)

; values for the type argument
VRAM = %100001
CRAM = %101011
VSRAM = %100101

; values for the rwd argument
READ = %001100
WRITE = %000111
DMA = %100111

; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
; a6 is the address of VDP_data_port
dma68kToVDP macro source,dest,length,type
	move.l	#($9400|((((length)>>1)&$FF00)>>8))|(($9300|(((length)>>1)&$FF))<<16),4(a6)
	move.l	#($9600|((((source)>>1)&$FF00)>>8))|(($9500|(((source)>>1)&$FF))<<16),4(a6)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),4(a6)
	move.l	#vdpComm(dest,type,DMA),(DMA_data_thunk).w
	move.w	(DMA_data_thunk).w,4(a6)
	move.w	(DMA_data_thunk+2).w,4(a6)
    endm

; ---------------------------------------------------------------------------
; Z80 addresses
Z80_RAM =			$A00000 ; start of Z80 RAM
Z80_RAM_End =			$A02000 ; end of non-reserved Z80 RAM
Z80_Bus_Request =		$A11100
Z80_Reset =			$A11200

Security_Addr =			$A14000

; ---------------------------------------------------------------------------
; I/O Area 
HW_Version =				$A10001
HW_Port_1_Data =			$A10003
HW_Port_2_Data =			$A10005
HW_Expansion_Data =			$A10007
HW_Port_1_Control =			$A10009
HW_Port_2_Control =			$A1000B
HW_Expansion_Control =		$A1000D
HW_Port_1_TxData =			$A1000F
HW_Port_1_RxData =			$A10011
HW_Port_1_SCtrl =			$A10013
HW_Port_2_TxData =			$A10015
HW_Port_2_RxData =			$A10017
HW_Port_2_SCtrl =			$A10019
HW_Expansion_TxData =		$A1001B
HW_Expansion_RxData =		$A1001D
HW_Expansion_SCtrl =		$A1001F



    if zeroOffsetOptimization=0
    ; disable a space optimization in AS so we can build a bit-perfect rom
    ; (the hard way, but it requires no modification of AS itself)


chkop function op,ref,(substr(lowstring(op),0,strlen(ref))<>ref)

; 1-arg instruction that's self-patching to remove 0-offset optimization
insn1op	 macro oper,x
	  if (chkop("x","0(") && chkop("x","id(") && chkop("x","slot_rout("))
		!oper	x
	  else
		!oper	1+x
		!org	*-1
		!dc.b	0
	  endif
	 endm

; 2-arg instruction that's self-patching to remove 0-offset optimization
insn2op	 macro oper,x,y
	  if (chkop("x","0(") && chkop("x","id(") && chkop("x","slot_rout("))
		  if (chkop("y","0(") && chkop("y","id(") && chkop("y","slot_rout("))
			!oper	x,y
		  else
			!oper	x,1+y
			!org	*-1
			!dc.b	0
		  endif
	  else
		if chkop("y","d")
		  if (chkop("y","0(") && chkop("y","id(") && chkop("y","slot_rout("))
start:
			!oper	1+x,y
end:
			!org	start+3
			!dc.b	0
			!org	end
		  else
			!oper	1+x,1+y
			!org	*-3
			!dc.b	0
			!org	*+1
			!dc.b	0
		  endif
		else
			!oper	1+x,y
			!org	*-1
			!dc.b	0
		endif
	  endif
	 endm

	; instructions that were used with 0(a#) syntax
	; defined to assemble as they originally did
_move	macro
		insn2op move.ATTRIBUTE, ALLARGS
	endm
_add	macro
		insn2op add.ATTRIBUTE, ALLARGS
	endm
_addq	macro
		insn2op addq.ATTRIBUTE, ALLARGS
	endm
_cmp	macro
		insn2op cmp.ATTRIBUTE, ALLARGS
	endm
_cmpi	macro
		insn2op cmpi.ATTRIBUTE, ALLARGS
	endm
_clr	macro
		insn1op clr.ATTRIBUTE, ALLARGS
	endm
_tst	macro
		insn1op tst.ATTRIBUTE, ALLARGS
	endm
    else

	; regular meaning to the assembler; better but unlike original
_move	macro
		!move.ATTRIBUTE ALLARGS
	endm
_add	macro
		!add.ATTRIBUTE ALLARGS
	endm
_addq	macro
		!addq.ATTRIBUTE ALLARGS
	endm
_cmp	macro
		!cmp.ATTRIBUTE ALLARGS
	endm
_cmpi	macro
		!cmpi.ATTRIBUTE ALLARGS
	endm
_clr	macro
		!clr.ATTRIBUTE ALLARGS
	endm
_tst	macro
		!tst.ATTRIBUTE ALLARGS
	endm
    endif
