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
  move.l #VBL, VECTOR_VBL.w
  move.l #VmaxMusicStart, MusicPlay.l

  movea.l gfx_fb_front, a0
  lea 160*34(a0), a0
  lea.l VmaxLogo.l, a1
  move.w #20*133-1, d0
FillScreen:
  move.w (a1)+, (a0)+
  move.w (a1)+, (a0)+
  move.w (a1)+, (a0)+
  addq.l #2, a0
  dbra.w d0, FillScreen

  movem.l VmaxPalette.l, d0-d3
  move.l #$6740674, d4
  move.l d4, d5
  move.l d4, d6
  move.l d4, d7
  movem.l d0-d7, $ffff8240.w

MainLoop:
  lea AnimXY, a6
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

  moveq.l #17, d7
.TimeLine1:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine1.l

  lea.l LineBuffer.l, a0
  movea.l gfx_fb_front.l, a1
  lea.l 56*160+6(a1), a1
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

  moveq.l #17, d7
.TimeLine2:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine2.l

  stop #$2300
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

  cmp.b #$39, $fffffc02.w
  bne.w MainLoop.l

  rts

VBL:
  rte

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
VmaxMusicRestart .equ VmaxMusicStart + 14 * 7 * 64 * 2

AnimXY:
;  .dc.b %flllllll, %ooddbbbb, %oooooooo, %iiiiiiii

;        +----------------------------------------- first line in frame
;        |+++++++---------------------------------- line length - 1
;        ||||||||   ++----------------------------- high 2 bits of offset
;        ||||||||   ||+---------------------------- line direction 0=H 1=V
;        ||||||||   |||+--------------------------- line direction 0=U 1=D
;        ||||||||   ||||++++----------------------- bit number of first pixel
;        ||||||||   ||||||||   ++++++++------------ low 8 bits of offset
;        ||||||||   ||||||||   ||||||||   ++++++++- Bresenham increment
;        ||||||||   ||||||||   ||||||||   ||||||||
  .dc.b %10010000, %01001111, %00001011, %10000000
;           17 px     HU0,0               0.5
  .dc.b %00100000, %01001111, %00001011, %01000000

  .dc.b %00100000, %01011111, %00001011, %01000000
  .dc.b %00100000, %01101111, %00001011, %01000000
  .dc.b %00100000, %01111111, %00001011, %01000000

  EndAnim:
  .dc.b %10000000


  .bss
  .even
LineBuffer:
  .ds.w 6*88

MusicPlay:
  .ds.l 1
