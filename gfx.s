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
; ####                    Handling of graphics hardware                    ####
; ####                                                                     ####
; ####                                                                     ####
; #############################################################################
; #############################################################################

  .text

; ###########################
; ###########################
; ##                       ##
; ##   Public interfaces   ##
; ##                       ##
; ###########################
; ###########################

; GfxSetup:
; * Saves state of graphics hardware
; * Sets up resolution and refresh rate

; GfxReset:
; * Restores state of graphics hardware

; #####################################
; #####################################
; ##                                 ##
; ##   Set up graphics environment   ##
; ##                                 ##
; #####################################
; #####################################

GfxSetup:
; Enable interrupts, we'll need those when waiting for a VBL
  move.w #$2300, sr

; Save framebuffer address registers, compute framebuffer address
  moveq.l #0, d0
  move.b GFX_VBASE_HIGH.w, d0
  move.b d0, _gfx_save_vbase_high.l
  lsl.l #8, d0
  move.b GFX_VBASE_MID.w, d0
  move.b d0,_gfx_save_vbase_mid.l
  lsl.l #8, d0
  move.l d0, gfx_os_fb.l
  move.l d0, gfx_fb_front.l

; Prepare second framebuffer
  move.l #_gfx_fb + 255, d0
  clr.b d0
  move.l d0, gfx_demo_fb.l
  move.l d0, gfx_fb_back.l

; Save other graphics registers
  move.b GFX_SYNC.w, _gfx_save_sync.l
  move.b GFX_MODE.w, _gfx_save_mode.l
  lea.l GFX_PALETTE.w, a0
  lea.l _gfx_save_palette.l, a1
  moveq.l #15, d7
.SavePalette:
  move.w (a0)+, (a1)+
  dbra.w d7, .SavePalette.l

; Wait for a VBL before making visible changes
  lea.l vbl_count.l, a0
  move.w (a0), d0
.WaitVbl:
  cmp.w (a0), d0
  bne.s .WaitVbl.l

; Switch to mode 0, 50 Hz
  move.b #GFX_SYNC_INTERN | GFX_SYNC_50HZ, GFX_SYNC.w
  move.b #GFX_MODE_COLOW, GFX_MODE.w

; Erase palette
  moveq.l #0, d0
  lea.l GFX_PALETTE.w, a0
  moveq.l #15, d7
.ClearPalette:
  move.w d0, (a0)+
  dbra.w d7, .ClearPalette.l

; Erase framebuffer
  moveq.l #0, d0
  movea.l gfx_os_fb.l, a0
  move.w #1999, d7
.ClearScreen:
  move.l d0, (a0)+
  move.l d0, (a0)+
  move.l d0, (a0)+
  move.l d0, (a0)+
  dbra.w d7, .ClearScreen.l

  rts

; ######################################
; ######################################
; ##                                  ##
; ##   Restore graphics environment   ##
; ##                                  ##
; ######################################
; ######################################

GfxReset:
; Wait for a VBL before making visible changes
  lea.l vbl_count.l, a0
  move.w (a0), d0
.WaitVbl1:
  cmp.w (a0), d0
  bne.s .WaitVbl1.l

; Erase palette
  moveq.l #0, d0
  lea.l GFX_PALETTE.w, a0
  moveq.l #15, d7
.ClearPalette:
  move.w d0, (a0)+
  dbra.w d7, .ClearPalette.l

; Erase framebuffer
  moveq.l #0, d0
  movea.l gfx_os_fb.l, a0
  move.w #1999, d7
.ClearScreen:
  move.l d0, (a0)+
  move.l d0, (a0)+
  move.l d0, (a0)+
  move.l d0, (a0)+
  dbra.w d7, .ClearScreen.l

  move.b _gfx_save_vbase_high.l, GFX_VBASE_HIGH.w
  move.b _gfx_save_vbase_mid.l, GFX_VBASE_MID.w

; Wait for a VBL before making visible changes
  lea.l vbl_count.l, a0
  move.w (a0), d0
.WaitVbl2:
  cmp.w (a0), d0
  bne.s .WaitVbl2.l

; Restore palette
  lea.l _gfx_save_palette.l, a0
  lea.l GFX_PALETTE.w, a1
  moveq.l #15, d7
.RestorePalette:
  move.w (a0)+, (a1)+
  dbra.w d7, .RestorePalette.l

; Restore mode / sync
  move.b _gfx_save_sync.l, GFX_SYNC.w
  move.b _gfx_save_mode.l, GFX_MODE.w

  rts

; ###################
; ###################
; ##               ##
; ##   Variables   ##
; ##               ##
; ###################
; ###################

  .bss
  .even
_gfx_save_palette:
  .ds.w 16

gfx_os_fb:
  .ds.l 1
gfx_demo_fb:
  .ds.l 1

gfx_fb_front:
  .ds.l 1
gfx_fb_back:
  .ds.l 1

_gfx_save_vbase_high:
  .ds.b 1
_gfx_save_vbase_mid:
  .ds.b 1
_gfx_save_sync:
  .ds.b 1
_gfx_save_mode:
  .ds.b 1

_gfx_fb:
  .ds.b 32255
