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

; #############################################################################
; #############################################################################
; ####                                                                     ####
; ####                                                                     ####
; ####                                Intro                                ####
; ####                                                                     ####
; ####                                                                     ####
; #############################################################################
; #############################################################################

  .text
Intro:
  stop #$2300
  movem.l IntroPalette.l, d0-d7
  movem.l d0-d7, GFX_PALETTE.w

  lea.l IntroLogo.l, a0
  movea.l gfx_fb_front, a1
  movea.l gfx_fb_back, a2
  lea.l 16 + 30 * 160(a1), a1
  lea.l 16 + 30 * 160(a2), a2
  moveq.l #127, d7
.CopyLogo:
  movem.l (a0)+, d0-d6/a6
  movem.l d0-d6/a6, (a1)
  movem.l d0-d6/a6, (a2)
  movem.l (a0)+, d0-d6/a6
  movem.l d0-d6/a6, 32(a1)
  movem.l d0-d6/a6, 32(a2)
  movem.l (a0)+, d0-d6/a6
  movem.l d0-d6/a6, 64(a1)
  movem.l d0-d6/a6, 64(a2)
  movem.l (a0)+, d0-d6/a6
  movem.l d0-d6/a6, 96(a1)
  movem.l d0-d6/a6, 96(a2)
  lea.l 160(a1), a1
  lea.l 160(a2), a2
  dbra.w d7, .CopyLogo.l

  move.w #INTRO_DURATION, d7
.Wait:
  stop #$2300
  cmp.b #$39, $fffffc02.w
  bne.s .KeepGoing.l
  moveq.l #1, d0
  rts
.KeepGoing:
  dbra.w d7, .Wait.l

  moveq.l #0, d0
  rts

  .data
  .even
IntroLogo:
  .incbin "out/inc/mb_bitmap.bin"
IntroPalette:
  .incbin "out/inc/mb_palette.bin"
