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
ScrollPrecompute:

; ***********************************
; ** Shift font to pixel positions **
; ***********************************
FontShift:
  lea.l Font.l, a0	; source
  lea.l font_shifted.l, a1	; destination
  moveq.l #2, d7	; loop counter over shitfs (3 + original = 4)
.FontShiftPixel:
  moveq.l #FONT_HEIGHT - 1, d6	; loop counter over lines
  moveq.l #0, d2	; buffer for bits passed across columns
.FontShiftRow:
  move.w #FONT_WIDTH - 1, d5	; loop counter over columns
.FontShiftByte:
  move.b (a0), d0	; read one byte
  move.b d0, d1		; make a copy to remember the outgoing bits
  andi.b #$ee, d0	; mask the bits that remain within this byte
  lsr.b #1, d0		; shift 1 bit to the right
  or.b d2, d0		; add the bits that came from the previous byte
  move.b d0, (a1)	; store the byte
  andi.b #$11, d1	; mask the bits for next byte
  lsl.b #3, d1		; shift those bits into place
  move.b d1, d2		; store them for the next iteration
  lea.l FONT_HEIGHT(a0), a0	; move source to next column
  lea.l FONT_HEIGHT(a1), a1	; move destination to next column
  dbra.w d5, .FontShiftByte.l	; iterate to next column
  lea.l -FONT_HEIGHT*FONT_WIDTH+1(a0), a0	; src: rewind columns, next row
  lea.l -FONT_HEIGHT*FONT_WIDTH+1(a1), a1	; dst: rewind columns, next row
  dbra.w d6, .FontShiftRow.l	; iterate to next row
  lea.l -FONT_HEIGHT(a1), a0	; src for next iteration = start of current dst
  lea.l FONT_HEIGHT*FONT_WIDTH(a0), a1	; dst for next iteration = after src
  dbra.w d7, .FontShiftPixel.l	; iterate to next pixel shift

  rts

ScrollInit:
  move.l #ScrollBuffers, ReadScroll.l
  move.l #Font, ReadFont1.l
  move.l #Font, ReadFont2.l
  move.l #ScrollText, ReadText.l
  move.b #1, ReadCol1.l
  move.b #1, ReadCol2.l

  rts

ScrollDraw:
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
  addi.l #font_shifted, d0
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

  rts

  .data
Font:
  .dcb.b 330,0
  .incbin "out/inc/font.bin"

FontWidths:
  .dc.b 16
  .incbin "out/inc/widths.bin"

FontKernings:
  .incbin "out/inc/kerning.bin"


ScrollText:
  .dc.b " "
  .dc.b "ARE YOU READY? "
  .dc.b "     "
  .dc.b "THE MEGABUSTERS ARE BACK WITH A BRAND NEW CRACK! "
  .dc.b "WE ARE BRINGING YOU ANDROID FOR THE ATARI ST!!!?! "
  .dc.b "UNFORTUNATELY YOUR ST IS NOT POWERFUL ENOUGH: "
  .dc.b "YOU NEED AT LEAST A 68040 OR 68060 CPU AT 333MHZ, "
  .dc.b "160MB OF RAM, AND 500MB OF HDD. "
  .dc.b "     "
  .dc.b "GUEST MUSIC BY AD FROM MPS. GRAPHICS BY PANDAFOX FROM "
  .dc.b "THE MEGABUSTERS, CODE BY DJAYBEE FROM THE MEGABUSTERS. "
  .dc.b "     "
  .dc.b "THIS INTRO IS DEDICATED TO THE INNER CHILD IN EACH OF US, "
  .dc.b "THE ONE WHO DOES NOT WANT TO GROW UP, THE ONE WHO PREFERS "
  .dc.b "TO PLAY GAMES WITHOUT A CARE IN THE WORLD, THE ONE WHO "
  .dc.b "STILL CREATES DEMOS FOR A COMPUTER THAT BECAME OBSOLETE "
  .dc.b "DECADES AGO. GIVE YOUR INNER CHILD SOME SPACE TO BREATHE! "
  .dc.b "     "
  .dc.b "ENJOY THE PIXEL-EXACT KERNING ON THE PROPORTIONAL FONT, "
  .dc.b "ALONG WITH THE 3D CUBOCTAHEDRONS. "
  .dc.b "     "
  .dc.b "THIS INTRO WAS RELEASED FOR THE FANTASY CRACKTRO "
  .dc.b "CHALLENGE, MARCH 16TH 2025. MAJOR THANKS TO THE "
  .dc.b "ORGANIZERS FOR MAKING THIS HAPPEN. "
  .dc.b "     "
  .dc.b "THIS INTRO WAS INSPIRED BY THE CRACKTRO THAT VMAX HAD "
  .dc.b "CREATED FOR TIP OFF. "
  .dc.b "IN MEMORIAM, TST D0 FROM VMAX. R.I.P. "
  .dc.b "     "
  .dc.b "GREETINGS TO ALL OUR DEMO FRIENDS, ESPECIALLY MB, HMD, MPS. "
  .dc.b "     "
  .dc.b "GREETINGS ALSO TO DMA-SC, GUNSTICK, GWEM, TROED. "
  .dc.b "     "
  .dc.b "GREETINGS FINALLY TO ALL THE CRACKER GROUPS FROM BACK "
  .dc.b "IN THE DAY, INCLUDING BUT NOT LIMITED TO: "
  .dc.b "AWESOME, BEAT BOY, CORPO, CRAZY COYOTE, DERZETER, "
  .dc.b "ELITE, FANATICS, FRA, FUZION, GOLIATH, HMD, HST, "
  .dc.b "ICE, ICS, IKE, IMPACT, KELVIN, MGL, MJJ PROD, "
  .dc.b "REBELLION, RCS, RED BARONS, ST-CNX, TAGGERS, "
  .dc.b "THE REANIMATORS, TRIPLE H, V8, VMAX. "
  .dc.b "     "
  .dc.b "THIS DEMO IS LICENSED UNDER AGPL V3. YOU MAY ALSO "
  .dc.b "USE THE ASSETS UNDER CC:BY-SA 4.0. "
  .dc.b "     "
  .dc.b "     "
EndScrollText:
  .dc.b " "

AsciiConvert:
  .dc.b 0, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 32, 27, 0
  .dc.b 42, 33, 34, 35, 36, 37, 38, 39, 40, 41, 28, 0, 0, 0, 0, 30
  .dc.b 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
  .dc.b 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26

  .bss
  .even

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

ReadCol1:
  .ds.b 1
ReadCol2:
  .ds.b 1

font_shifted:
  .ds.b 33 * 10 * 43 * 3
