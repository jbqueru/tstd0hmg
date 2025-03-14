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
; ####                        Modifiable parameters                        ####
; ####                                                                     ####
; ####                                                                     ####
; #############################################################################
; #############################################################################

DEBUG		.equ	0

STACK_SIZE	.equ	256		; in long words
STACK_GUARD	.equ	$60C0FFEE

ANIM_COLOR	.equ	$777

FONT_HEIGHT .equ    33
FONT_WIDTH  .equ    430

.if DEBUG
INTRO_DURATION	.equ	80
START_3D	.equ	140
ANIM_TIMING_BARS .equ	1
SPARE_TIME_COLOR .equ   1
.else
INTRO_DURATION	.equ	448
START_3D	.equ	508
ANIM_TIMING_BARS .equ	0
SPARE_TIME_COLOR .equ   0
.endif
