/*
 * Copyright 2025 Jean-Baptiste M. "JBQ" "Djaybee" Queru
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * As an added restriction, if you make the program available for
 * third parties to use on hardware you own (or co-own, lease, rent,
 * or otherwise control,) such as public gaming cabinets (whether or
 * not in a gaming arcade, whether or not coin-operated or otherwise
 * for a fee,) the conditions of section 13 will apply even if no
 * network is involved.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

// SPDX-License-Identifier: AGPL-3.0-or-later

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void main() {
	FILE* outputfile;

	outputfile = fopen("out/inc/3d.inc", "w");
	fprintf(outputfile,
		"; Copyright 2025 Jean-Baptiste M. \"JBQ\" \"Djaybee\" Queru\n"
		";\n"
		"; This program is free software: you can redistribute it and/or modify\n"
		"; it under the terms of the GNU Affero General Public License as\n"
		"; published by the Free Software Foundation, either version 3 of the\n"
		"; License, or (at your option) any later version.\n"
		";\n"
		"; As an added restriction, if you make the program available for\n"
		"; third parties to use on hardware you own (or co-own, lease, rent,\n"
		"; or otherwise control,) such as public gaming cabinets (whether or\n"
		"; not in a gaming arcade, whether or not coin-operated or otherwise\n"
		"; for a fee,) the conditions of section 13 will apply even if no\n"
		"; network is involved.\n"
		";\n"
		"; This program is distributed in the hope that it will be useful,\n"
		"; but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
		"; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n"
		"; GNU Affero General Public License for more details.\n"
		";\n"
		"; You should have received a copy of the GNU Affero General Public License\n"
		"; along with this program. If not, see <https://www.gnu.org/licenses/>.\n"
		";\n"
		"; SPDX-License-Identifier: AGPL-3.0-or-later\n"
		"\n"
		"; THIS IS A GENERATED FILE.\n"
		"; For AGPLv3, this is Object Code, not Source Code.\n"
		"; DO NOT EDIT, DO NO SUBMIT.\n"
		"\n"
		"; See generate_3d.c for more information \n"
		"\n"
	);

	fprintf(outputfile, "AnimXY:\n");

	fprintf(outputfile,
		";        +----------------------------------------------------"
			" first line in frame\n"
		";        |+++++++---------------------------------------------"
			" line length - 1\n"
		";        ||||||||   ++----------------------------------------"
			" high 2 bits of offset\n"
		";        ||||||||   ||+---------------------------------------"
			" line direction 0=H 1=V\n"
		";        ||||||||   |||+--------------------------------------"
			" line direction 0=U 1=D\n"
		";        ||||||||   ||||++++----------------------------------"
			" bit number of first pixel\n"
		";        ||||||||   ||||||||   ++++++++-----------------------"
			" low 8 bits of offset\n"
		";        ||||||||   ||||||||   ||||||||   ++++++++------------"
			" Bresenham increment\n"
		";        ||||||||   ||||||||   ||||||||   ||||||||   ++++++++-"
			" Bresenham initial offset\n"
		";        ||||||||   ||||||||   ||||||||   ||||||||   ||||||||\n"
		"; .dc.b %%flllllll, %%oovdbbbb, %%oooooooo, %%iiiiiiii, %%ssssssss\n"
	);

	for (int n = 0; n < 364; n++) {
		int x1, y1;
		if (n < 95) {
			x1 = n;
			y1 = 0;
		} else if (n < 182) {
			x1 = 95;
			y1 = n - 95;
		} else if (n < 277) {
			x1 = 277 - n;
			y1 = 87;
		} else {
			x1 = 0;
			y1 = 364 - n;
		}
		int x2, y2;
		x2 = 40;
		y2 = 20;
		if (x1 > x2) {
			int t;
			t = x1;
			x1 = x2;
			x2 = t;
			t = y1;
			y1 = y2;
			y2 = t;
		}
		int l, o, d, v, b, i, s;
		o = y1 * 6 + x1 / 16;
		b = 15 - (x1 % 16);
		i = 0;
		s = 128;
		if ((y2 - y1) < -(x2 - x1)) {
			l = y1 - y2;
			d = 0;
			v = 1;
			i = 256 * (x1 - x2) / (y2 - y1);
		} else if (y2 <= y1) {
			l = x2 - x1;
			d = 0;
			v = 0;
			i = 256 * (y1 - y2) / (x2 - x1);
		} else if ((y2 - y1) <= (x2 - x1)) {
			l = x2 - x1;
			d = 1;
			v = 0;
			i = 256 * (y2 - y1) / (x2 - x1);
		} else {
			l = y2 - y1;
			d = 1;
			v = 1;
			i = 256 * (x2 - x1) / (y2 - y1);
		}
		if (i > 255) {
			i = 255;
		}
		fprintf(outputfile, "\n\n  .dc.b 95+128, %%00011111, 12, 0, 127\n");
		fprintf(outputfile, "  .dc.b 95, %%01011111, 254, 0, 127\n");
		fprintf(outputfile, "  .dc.b 87, %%00111101, 0, 0, 127\n");
		fprintf(outputfile, "  .dc.b 87, %%00110010, 5, 0, 127\n");
		fprintf(outputfile, "  .dc.b 95, %%00011111, 0, 234, 127\n\n");
		fprintf(outputfile, "; (%d,%d)-(%d,%d)\n", x1, y1, x2, y2);
		fprintf(outputfile, "; l=%d, o=%d, v=%d, d=%d, b=%d, i=%d, s=%d\n", l, o, v, d, b, i, s);
		fprintf(outputfile, "  .dc.b %d,%d,%d,%d,%d\n",
		       l,
		       (o / 256) * 64 + v * 32 + d * 16 + b,
		       o % 256,
		       i,
		       s);
	}

	fprintf(outputfile, "EndAnim:\n");
	fprintf(outputfile, "  .dc.b %%10000000\n");

	fclose(outputfile);
}
