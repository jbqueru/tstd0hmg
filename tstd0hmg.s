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
  moveq.l #-1, d4
  move.l d4, d5
  move.l d4, d6
  move.l d4, d7
  movem.l d0-d7, $ffff8240.w

  lea.l LineBuffer.l, a0

  move.w #$8000, d0
  moveq.l #79, d1
  moveq.l #127, d7
  moveq.l #48, d6
NextLine:
  or.w d0, (a0)
  add.b d6, d7
  bcc.s ColOk.l
  ror.w d0
  bcc.s ColOk.l
  addq.l #2, a0
ColOk:
  lea 12(a0), a0
  dbra.w d1, NextLine

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

WaitKey:
  cmp.b #$39, $fffffc02.w
  bne.s WaitKey.l

  rts

; ##############################################33
  .data
  .even
VmaxLogo:
  .incbin "out/inc/vmax_bitmap.bin"
VmaxPalette:
  .incbin "out/inc/vmax_palette.bin"


  .bss
  .even
LineBuffer:
  .ds.w 6*88
