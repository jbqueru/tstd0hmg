/*
 * Copyright 2024 Jean-Baptiste M. "JBQ" "Djaybee" Queru
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

unsigned char pi1[32034];

unsigned char rawpixels[320][200];

unsigned char logo[32000];

void main() {
	FILE* inputfile;
	FILE* outputfile;

	inputfile = fopen("VMAX25.PI1", "rb");
	fread(pi1, 1, 32034, inputfile);
	fclose(inputfile);

	for (int y = 0; y < 200; y++) {
		for (int x = 0; x < 320; x++) {
			int byteoffset = 34;
			byteoffset += (x / 16) * 8;
			byteoffset += (x / 8) % 2;
			byteoffset += y * 160;

			int bitoffset = 7 - (x % 8);

			rawpixels[x][y] =
				(((pi1[byteoffset] >> bitoffset) & 1)) +
				(((pi1[byteoffset + 2] >> bitoffset) & 1) * 2) +
				(((pi1[byteoffset + 4] >> bitoffset) & 1) * 4) +
				(((pi1[byteoffset + 6] >> bitoffset) & 1) * 8);
		}
	}

	int xmin = 320;
	int xmax = -1;
	int ymin = 200;
	int ymax = -1;
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 200; y++) {
			if (rawpixels[x][y]) {
				if (x < xmin) xmin = x;
				if (x > xmax) xmax = x;
				if (y < ymin) ymin = y;
				if (y > ymax) ymax = y;
			}
		}
	}
	if (xmin != 3 || xmax != 317 || ymin != 35 || ymax != 165) {
		printf("Unexpected logo size (%d,%d)-(%d,%d) (expected (3,35)-(317,165))\n",
			xmin, ymin, xmax, ymax);
		exit(1);
	}

	for (int i = 0; i < 32000; i++) {
		logo[i] = 0;
	}

	for (int y = 0; y < 131; y++) {
		for (int x = 0; x < 320; x++) {
			unsigned int c = rawpixels[x + 0][y + 35];
			if (c & 1) {
				logo[(x / 16) * 6 + (x & 8) / 8 + y * 120 + 0] |= (0x80 >> (x & 7));
			}
			if (c & 2) {
				logo[(x / 16) * 6 + (x & 8) / 8 + y * 120 + 2] |= (0x80 >> (x & 7));
			}
			if (c & 4) {
				logo[(x / 16) * 6 + (x & 8) / 8 + y * 120 + 4] |= (0x80 >> (x & 7));
			}
		}
	}

	outputfile = fopen("out/inc/vmax_bitmap.bin", "wb");
	fwrite(logo, 1, 120 * 131, outputfile);
	fclose(outputfile);

	outputfile = fopen("out/inc/vmax_palette.bin", "wb");
	fwrite(pi1 + 2, 2, 8, outputfile);
	fclose(outputfile);

	inputfile = fopen("MBVMAX.PI1", "rb");
	fread(pi1, 1, 32034, inputfile);
	fclose(inputfile);

	for (int y = 0; y < 200; y++) {
		for (int x = 0; x < 320; x++) {
			int byteoffset = 34;
			byteoffset += (x / 16) * 8;
			byteoffset += (x / 8) % 2;
			byteoffset += y * 160;

			int bitoffset = 7 - (x % 8);

			rawpixels[x][y] =
				(((pi1[byteoffset] >> bitoffset) & 1)) +
				(((pi1[byteoffset + 2] >> bitoffset) & 1) * 2) +
				(((pi1[byteoffset + 4] >> bitoffset) & 1) * 4) +
				(((pi1[byteoffset + 6] >> bitoffset) & 1) * 8);
		}
	}

	xmin = 320;
	xmax = -1;
	ymin = 200;
	ymax = -1;
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 200; y++) {
			if (rawpixels[x][y]) {
				if (x < xmin) xmin = x;
				if (x > xmax) xmax = x;
				if (y < ymin) ymin = y;
				if (y > ymax) ymax = y;
			}
		}
	}
	if (xmin != 41 || xmax != 278 || ymin != 30 || ymax != 155) {
		printf("Unexpected logo size (%d,%d)-(%d,%d) (expected (41,30)-(278,155))\n",
			xmin, ymin, xmax, ymax);
		exit(1);
	}

	for (int i = 0; i < 32000; i++) {
		logo[i] = 0;
	}

	for (int y = 0; y < 126; y++) {
		for (int x = 0; x < 320; x++) {
			unsigned int c = rawpixels[x + 0][y + 30];
			if (c & 1) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 160 + 0] |= (0x80 >> (x & 7));
			}
			if (c & 2) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 160 + 2] |= (0x80 >> (x & 7));
			}
			if (c & 4) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 160 + 4] |= (0x80 >> (x & 7));
			}
			if (c & 8) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 160 + 6] |= (0x80 >> (x & 7));
			}
		}
	}

	outputfile = fopen("out/inc/mb_bitmap.bin", "wb");
	fwrite(logo, 1, 160 * 126, outputfile);
	fclose(outputfile);

	outputfile = fopen("out/inc/mb_palette.bin", "wb");
	fwrite(pi1 + 2, 2, 16, outputfile);
	fclose(outputfile);

}
