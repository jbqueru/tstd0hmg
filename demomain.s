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

  move.w VmaxPalette.l, $ffff8240.w

  lea.l Font.l, a0
  lea.l FontShift.l, a1
  moveq.l #2, d7
.ShiftPixel:
  moveq.l #32, d6
  moveq.l #0, d2
.ShiftRow:
  move.w #429, d5
.ShiftByte:
  move.b (a0), d0
  move.b d0, d1
  andi.b #$ee, d0
  lsr.b #1, d0
  or.b d2, d0
  move.b d0, (a1)
  andi.b #$11, d1
  lsl.b #3, d1
  move.b d1, d2
  lea.l 33(a0), a0
  lea.l 33(a1), a1
  dbra.w d5, .ShiftByte.l
  lea.l -33*430+1(a0), a0
  lea.l -33*430+1(a1), a1
  dbra.w d6, .ShiftRow.l
  lea.l -33(a1), a0
  lea.l 33*430(a0), a1
  dbra.w d7, .ShiftPixel.l

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
  move.l #ScrollBuffers, ReadScroll.l
  move.l #Font, ReadFont1.l
  move.l #Font, ReadFont2.l
  move.l #ScrollText, ReadText.l
  move.b #1, ReadCol1.l
  move.b #1, ReadCol2.l
  move.l #StartCurve1, ReadCurve1.l
  move.l #StartCurve2, ReadCurve2.l
  move.l #StartCurve3, ReadCurve3.l
  move.b #112, PrevCurve1.l
  move.b #112, PrevPrevCurve1.l
  move.b #112, PrevCurve2.l
  move.b #112, PrevPrevCurve2.l
  move.b #112, PrevCurve3.l
  move.b #112, PrevPrevCurve3.l

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

  movea.l ReadCurve1.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l #EndCurve3, a1
  bne.s .InCurve1
  lea.l StartCurve1, a1
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

  lea.l LineBuffer.l, a0

  movea.l ReadCurve2.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l #EndCurve3, a1
  bne.s .InCurve1
  lea.l StartCurve1, a1
.InCurve1:
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

  lea.l LineBuffer.l, a0

  movea.l ReadCurve3.l, a1
  moveq.l #0, d0
  move.b (a1)+, d0
  cmpa.l #EndCurve3, a1
  bne.s .InCurve1
  lea.l StartCurve1, a1
.InCurve1:
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

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine2:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine2.l
.endif

  movea.l ReadScroll.l, a0
  movea.l gfx_fb_back.l, a1
  lea.l 160 * 167(a1), a2
  moveq.l #32, d7
.TextCopyLine:
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
  movem.l (a0)+, d0-d6/a4-a6
  move.l d0, 80(a1)
  move.l d0, 80(a2)
  move.l d1, 88(a1)
  move.l d1, 88(a2)
  move.l d2, 96(a1)
  move.l d2, 96(a2)
  move.l d3, 104(a1)
  move.l d3, 104(a2)
  move.l d4, 112(a1)
  move.l d4, 112(a2)
  move.l d5, 120(a1)
  move.l d5, 120(a2)
  move.l d6, 128(a1)
  move.l d6, 128(a2)
  move.l a4, 136(a1)
  move.l a4, 136(a2)
  move.l a5, 144(a1)
  move.l a5, 144(a2)
  move.l a6, 152(a1)
  move.l a6, 152(a2)
  lea.l 320(a0), a0
  lea.l 160(a1), a1
  lea.l 160(a2), a2
  dbra.w d7, .TextCopyLine.l

  movea.l ReadScroll.l, a0
  movea.l a0, a1
  lea.l 80(a1), a1
  cmpa.l #ScrollBuffers + 320, a1
  blt.s .ReadInBuffer.l
  lea.l -316(a1), a1
.ReadInBuffer:
  move.l a1, ReadScroll.l

  move.l ReadFont1.l, a3
  move.l ReadFont2.l, a4

  lea 76(a0), a0
  lea 76(a1), a1
  movea.l a1, a2
  cmpa.l #ScrollBuffers + 320, a2
  blt.s .WriteInBuffer.l
  lea.l -316(a2), a2
.WriteInBuffer:
  moveq.l #32, d7
.UpdateColumn:
  movem.w (a0), d0-d1
  lsl.w #4, d0
  lsl.w #4, d1
  move.b (a3)+, d2
  move.b d2, d3
  andi.b #$0f, d2
  lsr.b #4, d3
  or.b d2, d0
  or.b d3, d1
  move.b (a4)+, d2
  move.b d2, d3
  andi.b #$0f, d2
  lsr.b #4, d3
  or.b d2, d0
  or.b d3, d1
  movem.w d0-d1, (a1)
  movem.w d0-d1, (a2)
  lea.l 400(a0), a0
  lea.l 400(a1), a1
  lea.l 400(a2), a2
  dbra.w d7, .UpdateColumn.l
  move.l a3, ReadFont1.l
  move.l a4, ReadFont2.l

; We've consumed 4 pixels from the right character
  subq.b #4, ReadCol2.l

  movea.l ReadText.l, a0
  lea.l AsciiConvert.l, a1
  moveq.l #0, d6

  moveq.l #0, d0
  moveq.l #0, d1
  move.b (a0)+, d0		; ASCII value of left character
  move.b -32(a1, d0.w), d0	; Font index of left character
  subq.b #1, d0			; Remove non-printable characters
  bmi.s .KernDone		; If non-printable, no kerning
  move.b (a0)+, d1		; ASCII value of right character
  move.b -32(a1, d1.w), d1	; Font index of right character
  subq.b #1, d1			; Remove non-printable characters
  bmi.s .KernDone		; If non-printable, no kerning
  mulu.w #42, d0
  add.w d0, d1
  lea.l FontKernings, a0
  move.b (a0, d1.w), d6		; d6 = number of overlapping pixels
.KernDone:

; Check if there's room left to start another character
  moveq.l #3, d7
  add.b d6, d7
  cmp.b ReadCol2.l, d7
  blt.s .InChar2.l

  movea.l ReadText.l, a0
  addq.l #1, a0
  moveq.l #0, d0
  move.b (a0), d0
  cmpa.l #EndScrollText, a0
  bne.s .InText.l
  lea.l ScrollText, a0
.InText:
  move.l a0, ReadText.l
  lea.l AsciiConvert.l, a0
  move.b -32(a0, d0.w), d0
  lea.l FontWidths.l, a0
  moveq.l #0, d1
  move.b ReadCol2.l, d1
  sub.b d6, d1
  andi.b #3, d1
  move.b (a0, d0.w), ReadCol2.l
  add.b d1, ReadCol2.l
  mulu.w #330, d0
  subq.b #1, d1
  bmi.s .Unshifted.l
  mulu.w #430 * 33, d1
  add.l d1, d0
  addi.l #FontShift, d0
  bra.s .ShiftDone.l
.Unshifted:
  addi.l #Font, d0
.ShiftDone:
  move.l d0, ReadFont2.l
.InChar2:

  subq.b #4, ReadCol1.l
  bgt.s .InChar1.l
  move.b ReadCol2.l, ReadCol1.l
  move.l ReadFont2.l, ReadFont1.l

.InChar1:

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

Font:
  .dcb.b 330,0
  .incbin "out/inc/font.bin"

FontWidths:
  .dc.b 16
  .incbin "out/inc/widths.bin"

FontKernings:
  .incbin "out/inc/kerning.bin"

VmaxMusicStart:
  .incbin "AREGDUMP.BIN"
VmaxMusicEnd:
VmaxMusicRestart .equ VmaxMusicStart + 14 * 7 * 64 * 3

  .include "out/inc/3d.inc"
  .include "out/inc/curves.inc"

ScrollText:
  .dc.b " "
  .dc.b "THE MEGABUSTERS ARE BACK WITH A BRAND NEW CRACK! "
  .dc.b "WE ARE BRINGING YOU ANDROID FOR THE ATARI ST. "
  .dc.b "MINIMUM REQUIREMENTS: 68040-68060 CPU AT 320MHZ, "
  .dc.b "160MB OF RAM, 512MB OF HDD.      "
  .dc.b "WHO BUILT THIS INTRO? GUEST MUSIC BY AD, GFX "
  .dc.b "BY PFX, CODE BY DJB. "
  .dc.b "ENJOY!!!!         "
  .dc.b "RELEASED FOR THE FANTASY CRACKTRO CHALLENGE, "
  .dc.b "16 MARCH 2025.       "
  .dc.b "IN MEMORIAM, TST D0 FROM VMAX. R.I.P.       "
EndScrollText:
  .dc.b " "

AsciiConvert:
  .dc.b 0, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 32, 27, 0
  .dc.b 42, 33, 34, 35, 36, 37, 38, 39, 40, 41, 28, 0, 0, 0, 0, 30
  .dc.b 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
  .dc.b 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26

  .bss
  .even
LineBuffer:
  .ds.w 6*88
LineBufferEnd:

ScrollBuffers:
  .ds.l 20 * 5 * 33

ReadText:
  .ds.l 1
ReadScroll:
  .ds.l 1
ReadFont1:
  .ds.l 1
ReadFont2:
  .ds.l 1

ReadCurve1:
  .ds.l 1
ReadCurve2:
  .ds.l 1
ReadCurve3:
  .ds.l 1

XYRead:
  .ds.l 1
MusicPlay:
  .ds.l 1

ReadCol1:
  .ds.b 1
ReadCol2:
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

FontShift:
  .ds.b 33 * 10 * 43 * 3

  .include "intro.s"
