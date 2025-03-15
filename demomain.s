; Copyright 2025 Jean-Baptiste M. "JBQ" "Djaybee" Queru
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Affero General Public License as
; published by the Free Software Foundation, either version 3 of the
; License, or (at your option) any later version.
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

; #############################
; #############################
; ##                         ##
; ##   Precompute graphics   ##
; ##                         ##
; #############################
; #############################

; *************************
; ** Set palette color 0 **
; *************************
  stop #$2300
  move.w VmaxPalette.l, GFX_COLOR0.w

  bsr.w ScrollPrecompute.l

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
  move.l #LineBuffer, CurrentBuffer.l
  move.l #StartCurve1, ReadCurve1.l
  move.l #StartCurve2, ReadCurve2.l
  move.l #StartCurve3, ReadCurve3.l
  move.l #EndCurve1, WrapCurve1.l
  move.l #EndCurve2, WrapCurve2.l
  move.l #EndCurve3, WrapCurve3.l
  move.b #112, PrevCurve1.l
  move.b #112, PrevPrevCurve1.l
  move.b #112, PrevCurve2.l
  move.b #112, PrevPrevCurve2.l
  move.b #112, PrevCurve3.l
  move.b #112, PrevPrevCurve3.l
  move.l #$7064d2b2, RandomCurve.l
  move.b #0, Display3D.l

  bsr.w ScrollInit.l

MainLoop:
; Wait for VBL
  stop #$2300

  cmp.w #START_3D, vbl_count.l
  bne.s .NotStart3D.l
  move.b #1, Display3D.l
.NotStart3D:

  move.l gfx_fb_front.l, d0
  move.l gfx_fb_back.l, gfx_fb_front.l
  move.l d0, gfx_fb_back.l
  lsr.w #8, d0
  move.b d0, $ffff8203.w
  swap d0
  move.b d0, $ffff8201.w

; Clear offscreen buffer
  movea.l CurrentBuffer.l, a6
  lea.l 12*88(a6), a6
  cmpa.l #EndLineBuffer, a6
  bne.s .InBuffers.l
  lea.l LineBuffer, a6
.InBuffers:
  move.l a6, CurrentBuffer.l
  lea.l 12*88(a6), a6

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
  movea.l CurrentBuffer, a0
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
  movea.l CurrentBuffer.l, a0
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
  movea.l CurrentBuffer.l, a0
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
  movea.l CurrentBuffer.l, a0
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

  tst.b Display3D.l
  beq.w Skip3D.l

  movea.l CurrentBuffer.l, a0

  movea.l ReadCurve1.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l WrapCurve1, a1
  bne.s .InCurve1
  move.l RandomCurve.l, d2
  rol.l #5, d2
  addi.l #$a3873268, d2
  move.l d2, RandomCurve.l
  btst.l #0, d2
  bne.s .MidCurve1.l
  btst.l #1, d2
  bne.s .BigCurve1.l
  lea.l StartCurve3, a1
  move.l #EndCurve3, WrapCurve1.l
  bra.s .InCurve1.l
.BigCurve1:
  lea.l StartCurve1, a1
  move.l #EndCurve1, WrapCurve1.l
  bra.s .InCurve1.l
.MidCurve1:
  lea.l StartCurve2, a1
  move.l #EndCurve2, WrapCurve1.l
.InCurve1:
  move.l a1, ReadCurve1.l

  moveq.l #0, d1
  move.b PrevPrevCurve1.l, d1
  move.b PrevCurve1.l, PrevPrevCurve1.l
  move.b d0, PrevCurve1.l
  cmp.b d1, d0
  blt.s .Curve1Up.l
.Curve1Down:
; from here, d0 >= d1, going down
  move.l d0, d6
  sub.b d1, d6
  moveq.l #0, d7
  move.b d1, d0
  bra.s .Curve1Done.l
.Curve1Up:
; from here, d0 < d1, going up
  moveq.l #0, d6
  move.l d1, d7
  sub.b d0, d7
.Curve1Done:
  mulu.w #160, d0
  movea.l gfx_fb_back.l, a1
  lea 6(a1, d0.w), a1

  moveq.l #0, d0
  bra.s LoopLineTop1.l
ClearLineTop1:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineTop1:
  dbra.w d6, ClearLineTop1.l

  moveq.l #87, d6
CopyLine1:
  movem.w (a0)+, d0-d5
  move.w d0, (a1)
  move.w d1, 8(a1)
  move.w d2, 16(a1)
  move.w d3, 24(a1)
  move.w d4, 32(a1)
  move.w d5, 40(a1)

  lea.l 160(a1), a1
  dbra.w d6, CopyLine1.l

  moveq.l #0, d0
  bra.s LoopLineBottom1.l
ClearLineBottom1:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineBottom1:
  dbra.w d7, ClearLineBottom1.l

  movea.l CurrentBuffer.l, a0
  lea 12*88*26(a0), a0
  cmpa.l #EndLineBuffer, a0
  blt.s .InBuffer3
  suba.l #12*88*51, a0
.InBuffer3:

  movea.l ReadCurve2.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l WrapCurve2.l, a1
  bne.s .InCurve2
  move.l RandomCurve.l, d2
  rol.l #5, d2
  addi.l #$a3873268, d2
  move.l d2, RandomCurve.l
  btst.l #0, d2
  bne.s .MidCurve2.l
  btst.l #1, d2
  bne.s .BigCurve2.l
  lea.l StartCurve3, a1
  move.l #EndCurve3, WrapCurve2.l
  bra.s .InCurve2.l
.BigCurve2:
  lea.l StartCurve1, a1
  move.l #EndCurve1, WrapCurve2.l
  bra.s .InCurve2.l
.MidCurve2:
  lea.l StartCurve2, a1
  move.l #EndCurve2, WrapCurve2.l
.InCurve2:
  move.l a1, ReadCurve2.l

  moveq.l #0, d1
  move.b PrevPrevCurve2.l, d1
  move.b PrevCurve2.l, PrevPrevCurve2.l
  move.b d0, PrevCurve2.l
  cmp.b d1, d0
  blt.s .Curve2Up.l
.Curve2Down:
; from here, d0 >= d1, going down
  move.l d0, d6
  sub.b d1, d6
  moveq.l #0, d7
  move.b d1, d0
  bra.s .Curve2Done.l
.Curve2Up:
; from here, d0 < d1, going up
  moveq.l #0, d6
  move.l d1, d7
  sub.b d0, d7
.Curve2Done:
  mulu.w #160, d0
  movea.l gfx_fb_back.l, a1
  lea 62(a1, d0.w), a1

  moveq.l #0, d0
  bra.s LoopLineTop2.l
ClearLineTop2:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineTop2:
  dbra.w d6, ClearLineTop2.l

  moveq.l #87, d6
CopyLine2:
  movem.w (a0)+, d0-d5
  move.w d0, (a1)
  move.w d1, 8(a1)
  move.w d2, 16(a1)
  move.w d3, 24(a1)
  move.w d4, 32(a1)
  move.w d5, 40(a1)

  lea.l 160(a1), a1
  dbra.w d6, CopyLine2.l

  moveq.l #0, d0
  bra.s LoopLineBottom2.l
ClearLineBottom2:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineBottom2:
  dbra.w d7, ClearLineBottom2.l

  movea.l CurrentBuffer.l, a0
  lea 12*88(a0), a0
  cmpa.l #EndLineBuffer, a0
  blt.s .InBuffer3
  suba.l #12*88*51, a0
.InBuffer3:

  movea.l ReadCurve3.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l WrapCurve3.l, a1
  bne.s .InCurve3
  move.l RandomCurve.l, d2
  rol.l #5, d2
  addi.l #$a3873268, d2
  move.l d2, RandomCurve.l
  btst.l #0, d2
  bne.s .MidCurve3.l
  btst.l #1, d2
  bne.s .BigCurve3.l
  lea.l StartCurve3, a1
  move.l #EndCurve3, WrapCurve3.l
  bra.s .InCurve3.l
.BigCurve3:
  lea.l StartCurve1, a1
  move.l #EndCurve1, WrapCurve3.l
  bra.s .InCurve3.l
.MidCurve3:
  lea.l StartCurve2, a1
  move.l #EndCurve2, WrapCurve3.l
.InCurve3:
  move.l a1, ReadCurve3.l

  moveq.l #0, d1
  move.b PrevPrevCurve3.l, d1
  move.b PrevCurve3.l, PrevPrevCurve3.l
  move.b d0, PrevCurve3.l
  cmp.b d1, d0
  blt.s .Curve3Up.l
.Curve3Down:
; from here, d0 >= d1, going down
  move.l d0, d6
  sub.b d1, d6
  moveq.l #0, d7
  move.b d1, d0
  bra.s .Curve3Done.l
.Curve3Up:
; from here, d0 < d1, going up
  moveq.l #0, d6
  move.l d1, d7
  sub.b d0, d7
.Curve3Done:
  mulu.w #160, d0
  movea.l gfx_fb_back.l, a1
  lea 118(a1, d0.w), a1

  moveq.l #0, d0
  bra.s LoopLineTop3.l
ClearLineTop3:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineTop3:
  dbra.w d6, ClearLineTop3.l

  moveq.l #87, d6
CopyLine3:
  movem.w (a0)+, d0-d5
  move.w d0, (a1)
  move.w d1, 8(a1)
  move.w d2, 16(a1)
  move.w d3, 24(a1)
  move.w d4, 32(a1)
  move.w d5, 40(a1)

  lea.l 160(a1), a1
  dbra.w d6, CopyLine3.l

  moveq.l #0, d0
  bra.s LoopLineBottom3.l
ClearLineBottom3:
  move.w d0, (a1)
  move.w d0, 8(a1)
  move.w d0, 16(a1)
  move.w d0, 24(a1)
  move.w d0, 32(a1)
  move.w d0, 40(a1)

  lea.l 160(a1), a1
LoopLineBottom3:
  dbra.w d7, ClearLineBottom3.l

Skip3D:

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine2:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine2.l
.endif

  bsr.w ScrollDraw.l

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine3:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine3.l
.endif

.if SPARE_TIME_COLOR
  move.w #$770, $ffff8240.w
.endif

  cmp.b #$39, $fffffc02.w
  bne.w MainLoop.l

  move.l #_IrqVblEmpty, VECTOR_VBL.w

  rts

VBL:
.if SPARE_TIME_COLOR
  move.w VmaxPalette.l, $ffff8240.w
.endif
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
  .include "out/inc/curves.inc"

  .bss
  .even
LineBuffer:
  .ds.w 6 * 88 * 51
EndLineBuffer:

ReadCurve1:
  .ds.l 1
ReadCurve2:
  .ds.l 1
ReadCurve3:
  .ds.l 1

WrapCurve1:
  .ds.l 1
WrapCurve2:
  .ds.l 1
WrapCurve3:
  .ds.l 1

RandomCurve:
  .ds.l 1

CurrentBuffer:
  .ds.l 1

XYRead:
  .ds.l 1
MusicPlay:
  .ds.l 1

Display3D:
  .ds.b 1

PrevCurve1:
  .ds.b 1
PrevPrevCurve1:
  .ds.b 1
PrevCurve2:
  .ds.b 1
PrevPrevCurve2:
  .ds.b 1
PrevCurve3:
  .ds.b 1
PrevPrevCurve3:
  .ds.b 1

  .include "intro.s"
  .include "scroll.s"
