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
; ####                    Interrupt and stack management                   ####
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

; IrqStackSetup:
; * Saves state of SR and disables interrupts
; * Save VBL vector and sets up a trivial one
; * Save stack state (USP and SSP) and sets up our stack
; * MUST BE CALLED FROM TOP LEVEL, NOT FROM SUBROUTINE
; * Parameters:
;   - none
; * Returns:
;   - nothing
; * Modifies:
;   - A0
;   - SP (!!)
;   - SR (!!)

; IrqStackReset:
; * Restores VBL vector
; * Restores SR (which potentially restores interrupts)
; * Checks stack overflow
; * Restore stack stack (USP and SSP)
; * MUST BE CALLED FROM TOP LEVEL, NOT FROM SUBROUTINE
; * Parameters:
;   - none
; * Returns:
;   - nothing
; * Modifies:
;   - A0
;   - SP (!!)
;   - USP
;   - SR (!!)

; vbl_count:
; * Short variable (wraparound possible)
; * Incremented at each VBL

; ########################
; ########################
; ##                    ##
; ##   Implementation   ##
; ##                    ##
; ########################
; ########################

  .text

; *********************************
; ** Set up interrupts and stack **
; *********************************
IrqStackSetup:
; Save SR and disable interrupts
  move.w sr, _irq_sr_save.l
  move.w #$2700, sr

; Save VBL handler and set up ours
  clr.w vbl_count.l
  move.l VECTOR_VBL.w, _irq_vbl_save.l
  move.l #_IrqVblEmpty, VECTOR_VBL.w

; Save USP
  move.l usp, a0
  move.l a0, _stack_usp_save.l

; Save SP, set up our stack, return
  move.l (sp)+, a0		; pop the return address from the old stack
  move.l #STACK_GUARD, _stack.l
  move.l sp, _stack_ssp_save.l
  lea.l _stack_end.l, sp
  jmp (a0)			; jump to the return address - replaces rts

; **********************************
; ** Restore interrupts and stack **
; **********************************

IrqStackReset:
; Disable interrupts
  move.w #$2700, sr

; Restore VBL handler
  move.l _irq_vbl_save.l, VECTOR_VBL.w

; Check for stack overflow
  cmpi.l #STACK_GUARD, _stack.l
.StackOverflow:
  bne.s .StackOverflow

; Restore USP
  move.l _stack_usp_save.l, a0
  move.l a0, usp

; Restore SP
  move.l (sp)+, a0		; pop the return address from the old stack
  move.l _stack_ssp_save.l, sp

; Restore SR (most likely re-enables interrupts)
  move.w _irq_sr_save.l, sr
  jmp (a0)			; jump to the return address - replaces rts

; ***********************
; ** Empty VBL handler **
; ***********************

_IrqVblEmpty:
  addq.w #1, vbl_count.l
  rte

; ###################
; ###################
; ##               ##
; ##   Variables   ##
; ##               ##
; ###################
; ###################

  .bss
  .even

vbl_count:
  .ds.w 1

_irq_sr_save:
  .ds.w 1
_irq_vbl_save:
  .ds.l 1

_stack_usp_save:
  .ds.l 1
_stack_ssp_save:
  .ds.l 1

_stack:
  .ds.l STACK_SIZE
_stack_end:
