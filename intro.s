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

IntroLoop:

  cmpi.w #24, vbl_count.l
  bgt.w IntroInDone.l

  lea.l IntroLogo.l, a0
  movea.l gfx_fb_back, a1
  lea.l 16 + 30 * 160(a1), a1

  moveq.l #8, d7
  sub.w vbl_count.l, d7

  moveq.l #15, d6
.CopySlice:
  move.w d7, d0
  bpl.s .SkipPos.l
  moveq.l #0, d0
.SkipPos:
  cmpi.w #8, d0
  ble.s .SkipSmall.l
  moveq.l #8, d0
.SkipSmall:

  move.w d0, d5
  bra.s .SkipLineLoop.l
.SkipLine:
  moveq.l #0, d1
  .rept 32
  move.l d1, (a1)+
  .endr
  lea.l 32(a1), a1
.SkipLineLoop:
  dbra.w d5, .SkipLine.l

  moveq.l #8, d5
  sub.w d0, d5
  bra.s .CopyLineLoop.l
.CopyLine:
  .rept 32
  move.l (a0)+, (a1)+
  .endr
  lea.l 32(a1), a1
.CopyLineLoop:
  dbra.w d5, .CopyLine.l

  move.w d0, d5
  lsl.w #7, d5
  adda.w d5, a0

  addq.w #1, d7

  dbra.w d6, .CopySlice.l

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine.l
.endif

IntroInDone:

  cmp.w #INTRO_DURATION - 40, vbl_count.l
  blt.w IntroOutNotYet.l

  lea.l IntroLogo.l, a0
  movea.l gfx_fb_back, a1
  lea.l 16 + 30 * 160(a1), a1

  move.w #INTRO_DURATION - 16, d7
  sub.w vbl_count.l, d7

  moveq.l #15, d6
.CopySlice:
  move.w d7, d0
  bpl.s .SkipPos.l
  moveq.l #0, d0
.SkipPos:
  cmpi.w #8, d0
  ble.s .SkipSmall.l
  moveq.l #8, d0
.SkipSmall:

  moveq.l #8, d5
  sub.w d0, d5
  lsl.w #7, d5
  adda.w d5, a0

  move.w d0, d5
  bra.s .CopyLineLoop.l
.CopyLine:
  .rept 32
  move.l (a0)+, (a1)+
  .endr
  lea.l 32(a1), a1
.CopyLineLoop:
  dbra.w d5, .CopyLine.l

  moveq.l #8, d5
  sub.w d0, d5
  bra.s .SkipLineLoop.l
.SkipLine:
  moveq.l #0, d1
  .rept 32
  move.l d1, (a1)+
  .endr
  lea.l 32(a1), a1
.SkipLineLoop:
  dbra.w d5, .SkipLine.l

  addq.w #1, d7
  dbra.w d6, .CopySlice.l

.if ANIM_TIMING_BARS
  moveq.l #17, d7
.TimeLine:
  not.w $ffff8240.w
  dbra.w d7, .TimeLine.l
.endif


IntroOutNotYet:



  move.l gfx_fb_front.l, d0
  move.l gfx_fb_back.l, gfx_fb_front.l
  move.l d0, gfx_fb_back.l
  lsr.w #8, d0
  move.b d0, GFX_VBASE_MID.w
  swap d0
  move.b d0, GFX_VBASE_HIGH.w

  stop #$2300
  cmp.b #$39, $fffffc02.w
  bne.s .KeepGoing.l
  moveq.l #1, d0
  rts
.KeepGoing:
  cmp.w #INTRO_DURATION, vbl_count.l
  bne.w IntroLoop.l

  moveq.l #0, d0
  rts

  .data
  .even
IntroLogo:
  .incbin "out/inc/mb_bitmap.bin"
IntroPalette:
  .incbin "out/inc/mb_palette.bin"
