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

  movea.l gfx_fb_front, a0
  addq.l #6, a0

  move.w #$8000, d0
  moveq.l #127, d1
NextLine:
  or.w d0, (a0)
  ror.w d0
  bcc.s ColOk
  addq.l #8, a0
ColOk:
  lea 160(a0), a0
  dbra.w d1, NextLine

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
