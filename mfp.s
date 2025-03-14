; Copyright 2024 Jean-Baptiste M. "JBQ" "Djaybee" Queru
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

; #############################################################################
; #############################################################################
; ####                                                                     ####
; ####                                                                     ####
; ####                              MFP 68901                              ####
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

MfpSetup:
  move.b MFP_IMRA.w, _mfp_imra_save.l
  move.b MFP_IMRB.w, _mfp_imrb_save.l
  clr.b MFP_IMRA.w
  clr.b MFP_IMRB.w
  rts

MfpReset:
  move.b _mfp_imra_save.l, MFP_IMRA.w
  move.b _mfp_imrb_save.l, MFP_IMRB.w
  rts

; ###################
; ###################
; ##               ##
; ##   Variables   ##
; ##               ##
; ###################
; ###################

  .bss

_mfp_imra_save:
  .ds.b 1
_mfp_imrb_save:
  .ds.b 1
