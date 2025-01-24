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
  moveq.l #0, d0
  move.b GFX_VBASE_HIGH.w, d0
  lsl.l #8, d0
  move.b GFX_VBASE_MID.w, d0
  lsl.l #8, d0
  movea.l d0, a0
  lea.l VmaxLogo.l, a1
  move.w #20*133-1, d0
FillScreen:
  move.w (a1)+, (a0)+
  move.w (a1)+, (a0)+
  move.w (a1)+, (a0)+
  addq.l #2, a0
  dbra.w d0, FillScreen

  movem.w VmaxPalette.l, d0-d7
  movem.w d0-d7, $ffff8240.w

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
