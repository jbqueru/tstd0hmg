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
const int np = 26;
const int ne = 24;
const int nf = 14;

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
	xm[0] = 1;
	ym[0] = 0;
	zm[0] = -1;

	xm[1] = 0;
	ym[1] = 1;
	zm[1] = -1;

	xm[2] = -1;
	ym[2] = 0;
	zm[2] = -1;

	xm[3] = 0;
	ym[3] = -1;
	zm[3] = -1;

	xm[4] = 1;
	ym[4] = 1;
	zm[4] = 0;

	xm[5] = -1;
	ym[5] = 1;
	zm[5] = 0;

	xm[6] = -1;
	ym[6] = -1;
	zm[6] = 0;

	xm[7] = 1;
	ym[7] = -1;
	zm[7] = 0;

	xm[8] = 1;
	ym[8] = 0;
	zm[8] = 1;

	xm[9] = 0;
	ym[9] = 1;
	zm[9] = 1;

	xm[10] = -1;
	ym[10] = 0;
	zm[10] = 1;

	xm[11] = 0;
	ym[11] = -1;
	zm[11] = 1;

	xm[12] = 0;
	ym[12] = 0;
	zm[12] = -1;

	xm[13] = 1;
	ym[13] = 0;
	zm[13] = 0;

	xm[14] = 0;
	ym[14] = 1;
	zm[14] = 0;

	xm[15] = -1;
	ym[15] = 0;
	zm[15] = 0;

	xm[16] = 0;
	ym[16] = -1;
	zm[16] = 0;

	xm[17] = 0;
	ym[17] = 0;
	zm[17] = 1;

	xm[18] = 1;
	ym[18] = 1;
	zm[18] = -1;

	xm[19] = -1;
	ym[19] = 1;
	zm[19] = -1;

	xm[20] = -1;
	ym[20] = -1;
	zm[20] = -1;

	xm[21] = 1;
	ym[21] = -1;
	zm[21] = -1;

	xm[22] = 1;
	ym[22] = 1;
	zm[22] = 1;

	xm[23] = -1;
	ym[23] = 1;
	zm[23] = 1;

	xm[24] = -1;
	ym[24] = -1;
	zm[24] = 1;

	xm[25] = 1;
	ym[25] = -1;
	zm[25] = 1;

	int e1[ne], e2[ne];
	e1[0] = 0;
	e2[0] = 1;

	e1[1] = 1;
	e2[1] = 2;

	e1[2] = 2;
	e2[2] = 3;

	e1[3] = 3;
	e2[3] = 0;

	e1[4] = 0;
	e2[4] = 4;

	e1[5] = 4;
	e2[5] = 1;

	e1[6] = 1;
	e2[6] = 5;

	e1[7] = 5;
	e2[7] = 2;

	e1[8] = 2;
	e2[8] = 6;

	e1[9] = 6;
	e2[9] = 3;

	e1[10] = 3;
	e2[10] = 7;

	e1[11] = 7;
	e2[11] = 0;

	e1[12] = 8;
	e2[12] = 4;

	e1[13] = 4;
	e2[13] = 9;

	e1[14] = 9;
	e2[14] = 5;

	e1[15] = 5;
	e2[15] = 10;

	e1[16] = 10;
	e2[16] = 6;

	e1[17] = 6;
	e2[17] = 11;

	e1[18] = 11;
	e2[18] = 7;

	e1[19] = 7;
	e2[19] = 8;

	e1[20] = 8;
	e2[20] = 9;

	e1[21] = 9;
	e2[21] = 10;

	e1[22] = 10;
	e2[22] = 11;

	e1[23] = 11;
	e2[23] = 8;

	int face[nf][4];
	face[0][0] = 0;
	face[0][1] = 1;
	face[0][2] = 2;
	face[0][3] = 3;

	face[1][0] = 4;
	face[1][1] = 12;
	face[1][2] = 19;
	face[1][3] = 11;

	face[2][0] = 5;
	face[2][1] = 6;
	face[2][2] = 14;
	face[2][3] = 13;

	face[3][0] = 7;
	face[3][1] = 8;
	face[3][2] = 16;
	face[3][3] = 15;

	face[4][0] = 9;
	face[4][1] = 10;
	face[4][2] = 18;
	face[4][3] = 17;

	face[5][0] = 20;
	face[5][1] = 21;
	face[5][2] = 22;
	face[5][3] = 23;

	face[6][0] = 0;
	face[6][1] = 4;
	face[6][2] = 5;
	face[6][3] = -1;

	face[7][0] = 1;
	face[7][1] = 6;
	face[7][2] = 7;
	face[7][3] = -1;

	face[8][0] = 2;
	face[8][1] = 8;
	face[8][2] = 9;
	face[8][3] = -1;

	face[9][0] = 3;
	face[9][1] = 10;
	face[9][2] = 11;
	face[9][3] = -1;

	face[10][0] = 12;
	face[10][1] = 13;
	face[10][2] = 20;
	face[10][3] = -1;

	face[11][0] = 14;
	face[11][1] = 15;
	face[11][2] = 21;
	face[11][3] = -1;

	face[12][0] = 16;
	face[12][1] = 17;
	face[12][2] = 22;
	face[12][3] = -1;

	face[13][0] = 18;
	face[13][1] = 19;
	face[13][2] = 23;
	face[13][3] = -1;

	int norm[nf];
	norm[0] = 12;
	norm[1] = 13;
	norm[2] = 14;
	norm[3] = 15;
	norm[4] = 16;
	norm[5] = 17;
	norm[6] = 18;
	norm[7] = 19;
	norm[8] = 20;
	norm[9] = 21;
	norm[10] = 22;
	norm[11] = 23;
	norm[12] = 24;
	norm[13] = 25;

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
			xa = xo[i] * cos(n * 2 * M_PI / len) - yo[i] * sin(n * 2 * M_PI / len);
			ya = xo[i] * sin(n * 2 * M_PI / len) + yo[i] * cos(n * 2 * M_PI / len);
			za = zo[i];

			yb = ya * cos(2 * n * 2 * M_PI / len) - za * sin(2 * n * 2 * M_PI / len);
			zb = ya * sin(2 * n * 2 * M_PI / len) + za * cos(2 * n * 2 * M_PI / len);
			xb = xa;

			z3[i] = zb * cos(3 * n * 2 * M_PI / len) - xb * sin(3 * n * 2 * M_PI / len);
			x3[i] = zb * sin(3 * n * 2 * M_PI / len) + xb * cos(3 * n * 2 * M_PI / len);
			y3[i] = yb;

			xs[i] = 96 / 2 * (1 + x3[i] * dist / (dist + z3[i]));
			ys[i] = 88 / 2 * (1 + y3[i] * dist / (dist + z3[i]));
		}

		int vis[ne];
		for (int i = 0; i < ne; i++) {
			vis[i] = 0;
		}
		for (int i = 0; i < nf; i++) {
			double prod =
					x3[norm[i]] * x3[e1[face[i][0]]]
					+
					y3[norm[i]] * y3[e1[face[i][0]]]
					+
					z3[norm[i]] * (dist + z3[e1[face[i][0]]]);
			if (prod < 0) {
				for (int j = 0; j < 4; j++) {
					if (face[i][j] >= 0) {
						vis[face[i][j]] = 1;
					}
				}
			}
		}

		int first = 1;
		for (int i = 0; i < ne; i++) {
			if (vis[i]) {
				outputline(outputfile, first, xs[e1[i]], ys[e1[i]], xs[e2[i]], ys[e2[i]]);
				first = 0;
			}
		}
	}

	fprintf(outputfile, "EndAnim:\n");
	fprintf(outputfile, "  .dc.b %%10000000\n");

	fclose(outputfile);
}

void outputline(FILE* outputfile, int first, int x1, int y1, int x2, int y2) {
	if (x1 < 0 || x1 >= 96 || y1 < 0 || y1 >= 88 || x2 < 0 || x2 >= 96 || y2 < 0 || y2 >= 88) {
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
