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

const double size = 0.565;
const double dist = 8 * size;
const int len = 400;
const int np = 14;
const int ne = 12;

void outputline(FILE* outputfile, int first, int x1, int y1, int x2, int y2);

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

	double xm[np], ym[np], zm[np];
	xm[0] = -1;
	ym[0] = -1;
	zm[0] = -1;
	xm[1] = 1;
	ym[1] = -1;
	zm[1] = -1;
	xm[2] = -1;
	ym[2] = 1;
	zm[2] = -1;
	xm[3] = 1;
	ym[3] = 1;
	zm[3] = -1;
	xm[4] = -1;
	ym[4] = -1;
	zm[4] = 1;
	xm[5] = 1;
	ym[5] = -1;
	zm[5] = 1;
	xm[6] = -1;
	ym[6] = 1;
	zm[6] = 1;
	xm[7] = 1;
	ym[7] = 1;
	zm[7] = 1;

	int e1[ne], e2[ne];
	e1[0] = 0;
	e2[0] = 1;
	e1[1] = 0;
	e2[1] = 2;
	e1[2] = 1;
	e2[2] = 3;
	e1[3] = 2;
	e2[3] = 3;
	e1[4] = 4;
	e2[4] = 5;
	e1[5] = 4;
	e2[5] = 6;
	e1[6] = 5;
	e2[6] = 7;
	e1[7] = 6;
	e2[7] = 7;
	e1[8] = 0;
	e2[8] = 4;
	e1[9] = 1;
	e2[9] = 5;
	e1[10] = 2;
	e2[10] = 6;
	e1[11] = 3;
	e2[11] = 7;

	for (int n = 0 ; n < len ; n++) {
		double xo[np], yo[np], zo[np];
		for (int i = 0; i < np; i++) {
			xo[i] = xm[i] * size;
			yo[i] = ym[i] * size;
			zo[i] = zm[i] * size;
		}

		double x3[np], y3[np], z3[np];
		double xs[np], ys[np];

		for (int i = 0; i < np; i++) {
			double xa, ya, za;
			double xb, yb, zb;
			double xc, yc, zc;
			xa = xo[i] * cos(n * 2 * M_PI / len) - yo[i] * sin(n * 2 * M_PI / len);
			ya = xo[i] * sin(n * 2 * M_PI / len) + yo[i] * cos(n * 2 * M_PI / len);
			za = zo[i];

			yb = ya * cos(2 * n * 2 * M_PI / len) - za * sin(2 * n * 2 * M_PI / len);
			zb = ya * sin(2 * n * 2 * M_PI / len) + za * cos(2 * n * 2 * M_PI / len);
			xb = xa;

			zc = zb * cos(3 * n * 2 * M_PI / len) - xb * sin(3 * n * 2 * M_PI / len);
			xc = zb * sin(3 * n * 2 * M_PI / len) + xb * cos(3 * n * 2 * M_PI / len);
			yc = yb;

			xs[i] = 96 / 2 * (1 + xc * dist / (dist + zc));
			ys[i] = 88 / 2 * (1 + yc * dist / (dist + zc));
		}

		for (int i = 0; i < ne; i++) {
			outputline(outputfile, !i, xs[e1[i]], ys[e1[i]], xs[e2[i]], ys[e2[i]]);
		}
	}

	fprintf(outputfile, "EndAnim:\n");
	fprintf(outputfile, "  .dc.b %%10000000\n");

	fclose(outputfile);
}

void outputline(FILE* outputfile, int first, int x1, int y1, int x2, int y2) {
	if (x1 < 0 || x1 >= 96 || y1 < 0 || y2 >= 88 || x2 < 0 || x2 >= 96 || y2 < 0 || y2 >= 88) {
		fprintf(stderr, "3D graphics don't fit in frame\n");
		exit(1);
	}
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
	if ((x1 == x2) && (y1 == y2)) {
		l = 0;
		d = 0;
		v = 0;
		i = 0;
	} else if ((y2 - y1) < -(x2 - x1)) {
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
	fprintf(outputfile, "; (%d,%d)-(%d,%d)\n", x1, y1, x2, y2);
	fprintf(outputfile, "; f=%d, l=%d, o=%d, v=%d, d=%d, b=%d, i=%d, s=%d\n", first, l, o, v, d, b, i, s);
	fprintf(outputfile, "  .dc.b %d,%d,%d,%d,%d\n",
		first * 128 + l,
		(o / 256) * 64 + v * 32 + d * 16 + b,
		o % 256,
		i,
		s);
}
