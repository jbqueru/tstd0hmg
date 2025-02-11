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

int palettemap[8] = {0, 4, 1, 5, 2, 3, 6, 7};

void main() {
	FILE* inputfile;
	FILE* outputfile;

	inputfile = fopen("VMAX.PI1", "rb");
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
				palettemap[
					(((pi1[byteoffset] >> bitoffset) & 1)) +
					(((pi1[byteoffset + 2] >> bitoffset) & 1) * 2) +
					(((pi1[byteoffset + 4] >> bitoffset) & 1) * 4) +
					(((pi1[byteoffset + 6] >> bitoffset) & 1) * 8)
				];
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
	if (xmin != 5 || xmax != 312 || ymin != 34 || ymax != 160) {
		printf("Unexpected logo size (%d,%d)-(%d,%d) (expected (5,34)-(312,160))\n",
			xmin, ymin, xmax, ymax);
		exit(1);
	}

	for (int i = 0; i < 32000; i++) {
		logo[i] = 0;
	}

	for (int y = 0; y < 127; y++) {
		for (int x = 0; x < 320; x++) {
			unsigned int c = rawpixels[x + 0][y + 34];
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
	fwrite(logo, 1, 120 * 127, outputfile);
	fclose(outputfile);

	unsigned char palette[16];
	for (int i = 0; i < 8; i++) {
		for (int j = 0; j < 8; j++) {
			if (palettemap[j] == i) {
				palette[2 * i] = pi1[2 * (j + 1)];
				palette[2 * i + 1] = pi1[2 * (j + 1) + 1];
			}
		}
	}

	outputfile = fopen("out/inc/vmax_palette.bin", "wb");
	fwrite(palette, 2, 8, outputfile);
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

	for (int y = 0; y < 128; y++) {
		for (int x = 0; x < 256; x++) {
			unsigned int c = rawpixels[x + 32][y + 29];
			if (c & 1) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 128 + 0] |= (0x80 >> (x & 7));
			}
			if (c & 2) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 128 + 2] |= (0x80 >> (x & 7));
			}
			if (c & 4) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 128 + 4] |= (0x80 >> (x & 7));
			}
			if (c & 8) {
				logo[(x / 16) * 8 + (x & 8) / 8 + y * 128 + 6] |= (0x80 >> (x & 7));
			}
		}
	}

	outputfile = fopen("out/inc/mb_bitmap.bin", "wb");
	fwrite(logo, 1, 128 * 128, outputfile);
	fclose(outputfile);

	outputfile = fopen("out/inc/mb_palette.bin", "wb");
	fwrite(pi1 + 2, 2, 16, outputfile);
	fclose(outputfile);

	inputfile = fopen("FNT.PI1", "rb");
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

	int ystart = -1;
	for (int y = 0; y <= 150; y++) {
		int empty = 1;
		if (y != 200) {
			for (int x = 0 ; x < 320; x++) {
				if (rawpixels[x][y]) {
					empty = 0;
					break;
				}
			}
		}
		if (empty) {
			if (ystart != -1) {
				printf("row from %d to %d\n", ystart, y - 1);
				int xstart = -1;
				for (int x = 0; x <= 320; x++) {
					empty = 1;
					if (x != 320) {
						for (int yy = ystart; yy < y; yy++) {
							if (rawpixels[x][yy]) {
								empty = 0;
								break;
							}
						}
					}
					if (empty) {
						if (xstart != -1) {
							printf("character from %d to %d ", xstart, x - 1);
							printf("(width %d adjusted width %d)\n", x - xstart, (x - xstart + 6) & 252);
							xstart = -1;
						}
					} else {
						if (xstart == -1) {
							xstart = x;
						}
					}
				}
				ystart = -1;
			}
		} else {
			if (ystart == -1) {
				ystart = y;
			}
		}
	}
}
