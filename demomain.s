; Copyright 2025 Jean-Baptiste M. "JBQ" "Djaybee" Queru
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Affero General Public License as
; published by the Free Software Foundation, either version 3 of the
; License, or (at your option) any later version.
;
; As an added restriction, if you make the program available for
; third parties to use on hardware you own (or co-own, lease, rent,
; or otherwise control,) such as public gaming cabinets (whether or
; not in a gaming arcade, whether or not coin-operated or otherwise
; for a fee,) the conditions of section 13 will apply even if no
; network is involved.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.
;
; SPDX-License-Identifier: AGPL-3.0-or-later

; See main.s for more information

  .text
DemoStart:

; ##############################
; ##############################
; ##                          ##
; ##   Music Initialization   ##
; ##                          ##
; ##############################
; ##############################

  move.l #VmaxMusicStart, MusicPlay.l
  move.l #VBL, VECTOR_VBL.w
  move.w #0, vbl_count.l

; ###########################################
; ###########################################
; ##                                       ##
; ##   Invoke intro, bail if interrupted   ##
; ##                                       ##
; ###########################################
; ###########################################

  bsr.w Intro
  tst.w d0
  beq.s .DoMainDemo
  rts
.DoMainDemo:

; ###################
; ###################
; ##               ##
; ##   Draw Logo   ##
; ##               ##
; ###################
; ###################

  lea.l VmaxLogo.l, a0
  movea.l gfx_fb_front, a1
  lea.l 35*160(a1), a1
  movea.l gfx_fb_back, a2
  lea.l 35*160(a2), a2
  move.w #20*127-1, d7
FillScreen:
  movem.w (a0)+, d0-d2
  move.w d0, (a1)+
  move.w d1, (a1)+
  move.w d2, (a1)+
  addq.l #2, a1
  move.w d0, (a2)+
  move.w d1, (a2)+
  move.w d2, (a2)+
  addq.l #2, a2
  dbra.w d7, FillScreen.l

; #####################
; #####################
; ##                 ##
; ##   Set Palette   ##
; ##                 ##
; #####################
; #####################

  movem.l VmaxPalette.l, d0-d3
  move.l #ANIM_COLOR * $10001, d4
  move.l d4, d5
  move.l d4, d6
  move.l d4, d7
  movem.l d0-d7, $ffff8240.w

; ##############################
; ##############################
; ##                          ##
; ##   Initialize animation   ##
; ##                          ##
; ##############################
; ##############################

  move.l #AnimXY, XYRead.l


MainLoop:
; Wait for VBL
  stop #$2300

  move.l gfx_fb_front.l, d0
  move.l gfx_fb_back.l, gfx_fb_front.l
  move.l d0, gfx_fb_back.l
  lsr.w #8, d0
  move.b d0, $ffff8203.w
  swap d0
  move.b d0, $ffff8201.w

; Clear offscreen buffer
  lea.l LineBufferEnd.l, a6
  moveq.l #0, d0
  moveq.l #0, d1
  moveq.l #0, d2
  moveq.l #0, d3
  moveq.l #0, d4
  moveq.l #0, d5
  moveq.l #0, d6
  moveq.l #0, d7
  movea.l d0, a0
  movea.l d0, a1
  movea.l d0, a2
  movea.l d0, a3
  .rept 22
  movem.l d0-d7/a0-a3, -(a6)
  .endr

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine0:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine0.l
.endif


; Draw lines into offscreen buffer
  move.l XYRead, a6
  move.b (a6)+, d1	; pixel loop counter
  andi.w #$7f, d1	; mast unnecessary bits

; ###############################
; ###############################
; ##                           ##
; ##   Line-drawing routines   ##
; ##                           ##
; ###############################
; ###############################

; At this point, D1.w has the loop counter to draw the lines

StartLine:
  moveq.l #0, d2	; Clear register
  move.b (a6)+, d2	; Read line info
			; 76: top 2 bits of draw offset
			; 54: line angle
			; 3210: initial pixel number
  bclr.l #5, d2		; line angle, H or V?
  beq.s LineH.l
  bclr.l #4, d2		; line direction, U or D?
  beq.s LineVUp.l

LineVDown:
; Set exactly 1 bit in d0.w, specified by bits 0-3 of d2
; d2 bit 4 is guaranteed to be 0, bits 5-7 are ignored
  moveq.l #0, d0
  bset.l d2, d0

; shift bits 6-7 to 8-9
  add.w d2, d2
  add.w d2, d2
; read low 8 bits of word count
  move.b (a6)+, d2
; multiply by 2 to get byte offset
  add.w d2, d2
; compute base address of drawing code
  lea.l LineBuffer.l, a0
  adda.w d2, a0

  move.b (a6)+, d6
  moveq.l #127, d7
.NextLine:
  or.w d0, (a0)
  add.b d6, d7
  bcc.s .ColOk.l
  ror.w d0
  bcc.s .ColOk.l
  addq.l #2, a0
.ColOk:
  lea 12(a0), a0
  dbra.w d1, .NextLine.l
  bra.w LineDone.l

LineVUp:
; Set exactly 1 bit in d0.w, specified by bits 0-3 of d2
; d2 bit 4 is guaranteed to be 0, bits 5-7 are ignored
  moveq.l #0, d0
  bset.l d2, d0

; shift bits 6-7 to 8-9
  add.w d2, d2
  add.w d2, d2
; read low 8 bits of word count
  move.b (a6)+, d2
; multiply by 2 to get byte offset
  add.w d2, d2
; compute base address of drawing code
  lea.l LineBuffer.l, a0
  adda.w d2, a0

  move.b (a6)+, d6
  moveq.l #127, d7
.NextLine:
  or.w d0, (a0)
  add.b d6, d7
  bcc.s .ColOk.l
  ror.w d0
  bcc.s .ColOk.l
  addq.l #2, a0
.ColOk:
  lea -12(a0), a0
  dbra.w d1, .NextLine.l
  bra.s LineDone.l

LineH:
  bclr.l #4, d2		; line direction, U or D?
  beq.s LineHUp

LineHDown:
; Set exactly 1 bit in d0.w, specified by bits 0-3 of d2
; d2 bit 4 is guaranteed to be 0, bits 5-7 are ignored
  moveq.l #0, d0
  bset.l d2, d0

; shift bits 6-7 to 8-9
  add.w d2, d2
  add.w d2, d2
; read low 8 bits of word count
  move.b (a6)+, d2
; multiply by 2 to get byte offset
  add.w d2, d2
; compute base address of drawing code
  lea.l LineBuffer.l, a0
  adda.w d2, a0

  move.b (a6)+, d6
  moveq.l #127, d7
.NextLine:
  or.w d0, (a0)
  ror.w d0
  bcc.s .ColOk.l
  addq.l #2, a0
.ColOk:
  add.b d6, d7
  bcc.s .RowOk.l
  lea 12(a0), a0
.RowOk:
  dbra.w d1, .NextLine.l
  bra.s LineDone.l

LineHUp:
; Set exactly 1 bit in d0.w, specified by bits 0-3 of d2
; d2 bit 4 is guaranteed to be 0, bits 5-7 are ignored
  moveq.l #0, d0
  bset.l d2, d0

; shift bits 6-7 to 8-9
  add.w d2, d2
  add.w d2, d2
; read low 8 bits of word count
  move.b (a6)+, d2
; multiply by 2 to get byte offset
  add.w d2, d2
; compute base address of drawing code
  lea.l LineBuffer.l, a0
  adda.w d2, a0

  move.b (a6)+, d6
  moveq.l #127, d7
.NextLine:
  or.w d0, (a0)
  ror.w d0
  bcc.s .ColOk.l
  addq.l #2, a0
.ColOk:
  add.b d6, d7
  bcc.s .RowOk.l
  lea -12(a0), a0
.RowOk:
  dbra.w d1, .NextLine.l

LineDone:
  moveq.l #0, d1
  move.b (a6)+, d1	; pixel loop counter
  bclr #7, d1
  beq.w StartLine.l

  subq.l #1, a6
  cmpa.l #EndAnim, a6
  bne.s .AnimOK
  lea.l AnimXY, a6
.AnimOK:
  move.l a6, XYRead

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine1:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine1.l
.endif

  lea.l LineBuffer.l, a0
  movea.l gfx_fb_back.l, a1
  lea.l 112*160+6(a1), a1
  moveq.l #87, d7
CopyLine:
  movem.w (a0)+, d0-d5
  move.w d0, (a1)
  move.w d1, 8(a1)
  move.w d2, 16(a1)
  move.w d3, 24(a1)
  move.w d4, 32(a1)
  move.w d5, 40(a1)

  move.w d0, 56(a1)
  move.w d1, 64(a1)
  move.w d2, 72(a1)
  move.w d3, 80(a1)
  move.w d4, 88(a1)
  move.w d5, 96(a1)

  move.w d0, 112(a1)
  move.w d1, 120(a1)
  move.w d2, 128(a1)
  move.w d3, 136(a1)
  move.w d4, 144(a1)
  move.w d5, 152(a1)

  lea.l 160(a1), a1
  dbra.w d7, CopyLine.l

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine2:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine2.l
.endif

.if STUB_SCROLLTEXT
  lea.l DemoStart.l, a0
  movea.l gfx_fb_back.l, a1
  lea.l 160 * 167(a1), a2
  moveq.l #63, d7
.TextHalfLine:
  movem.l (a0)+, d0-d6/a4-a6
  move.l d0, (a1)
  move.l d0, (a2)
  move.l d1, 8(a1)
  move.l d1, 8(a2)
  move.l d2, 16(a1)
  move.l d2, 16(a2)
  move.l d3, 24(a1)
  move.l d3, 24(a2)
  move.l d4, 32(a1)
  move.l d4, 32(a2)
  move.l d5, 40(a1)
  move.l d5, 40(a2)
  move.l d6, 48(a1)
  move.l d6, 48(a2)
  move.l a4, 56(a1)
  move.l a4, 56(a2)
  move.l a5, 64(a1)
  move.l a5, 64(a2)
  move.l a6, 72(a1)
  move.l a6, 72(a2)
  lea.l 80(a1), a1
  lea.l 80(a2), a2
  dbra.w d7, .TextHalfLine.l
.endif

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine3:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine3.l
.endif

  cmp.b #$39, $fffffc02.w
  bne.w MainLoop.l

  move.l #_IrqVblEmpty, VECTOR_VBL.w

  rts

VBL:
  movem.l d7/a0, -(sp)
  ; Play music
  movea.l MusicPlay.l, a0
  moveq.l #13, d7
.CopyReg:
  move.b d7, PSG_REG.w
  move.b (a0)+, PSG_WRITE.w
  dbra.w d7, .CopyReg.l
  cmpa.l #VmaxMusicEnd, a0
  bne.s .MusicOk.l
  lea.l VmaxMusicRestart, a0
.MusicOk:
  move.l a0, MusicPlay.l
  movem.l (sp)+, d7/a0
  jmp _IrqVblEmpty

; ##############################################33
  .data
  .even
VmaxLogo:
  .incbin "out/inc/vmax_bitmap.bin"
VmaxPalette:
  .incbin "out/inc/vmax_palette.bin"

VmaxMusicStart:
  .incbin "AREGDUMP.BIN"
VmaxMusicEnd:
VmaxMusicRestart .equ VmaxMusicStart + 14 * 7 * 64 * 3

  .include "out/inc/3d.inc"

  .bss
  .even
LineBuffer:
  .ds.w 6*88
LineBufferEnd:

XYRead:
  .ds.l 1
MusicPlay:
  .ds.l 1

  .include "intro.s"
