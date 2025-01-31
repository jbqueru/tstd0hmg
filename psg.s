; Copyright 2024 Jean-Baptiste M. "JBQ" "Djaybee" Queru
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
; ####                             YM2149F PSG                             ####
; ####                                                                     ####
; ####                                                                     ####
; #############################################################################
; #############################################################################

; ###########################
; ###########################
; ##                       ##
; ##   Public interfaces   ##
; ##                       ##
; ###########################
; ###########################


; ########################
; ########################
; ##                    ##
; ##   Implementation   ##
; ##                    ##
; ########################
; ########################

  .text

PsgSetup:
  lea.l _psg_save.l, a0
  moveq.l #13, d7
.Loop:
  move.b d7, PSG_REG.w
  move.b PSG_READ.w, (a0)+
  clr.b PSG_WRITE.w
  dbra.w d7, .Loop.l
  rts

PsgReset:
  lea.l _psg_save.l, a0
  moveq.l #13, d7
.Loop:
  move.b d7, PSG_REG.w
  move.b (a0)+, PSG_WRITE.w
  dbra.w d7, .Loop
  rts

; ###################
; ###################
; ##               ##
; ##   Variables   ##
; ##               ##
; ###################
; ###################

  .bss

_psg_save:
  .ds.b	14
