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

const int numchars = 42;
const int charheight = 33;
const int charwidth = 40;

unsigned int charx[42];
unsigned int chary[42];

unsigned char widths[42];
unsigned char kern[42 * 42];

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
		fprintf(stderr, "Unexpected logo size (%d,%d)-(%d,%d) "
				"(expected (5,34)-(312,160))\n",
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
		fprintf(stderr, "Unexpected logo size (%d,%d)-(%d,%d) "
				"(expected (41,30)-(278,155))\n",
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

			rawpixels[x][y] = palettemap[
					(((pi1[byteoffset] >> bitoffset) & 1)) +
					(((pi1[byteoffset + 2] >> bitoffset) & 1) * 2) +
					(((pi1[byteoffset + 4] >> bitoffset) & 1) * 4) +
					(((pi1[byteoffset + 6] >> bitoffset) & 1) * 8)];
		}
	}

	for (int i = 0; i < 32000; i++) {
		logo[i] = 0;
	}

	int ystart = -1;
	int foundchars = 0;
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
				if (y - ystart > charheight) {
					fprintf(stderr, "characters too tall "
							"(found %d expected %d)\n",
							y - ystart, charheight);
					exit(1);
				}
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
//							printf("character %d at %d,%d ", foundchars, xstart, y - charheight);
//							printf("(width %d adjusted width %d)\n", x - xstart, (x - xstart + 6) & 252);
							if (((x - xstart + 6) & 252) > charwidth) {
								fprintf(stderr, "character at %d, %d too wide "
										"found %d max %d\n",
										x, y, (x - xstart + 6) & 252, charwidth);
								exit(1);
							}
							widths[foundchars] = x - xstart + 1;
							charx[foundchars] = xstart;
							chary[foundchars] = y - charheight;
							for (int xc = 0; xc < x - xstart; xc++) {
								for (int yc = 0; yc < charheight; yc++) {
									unsigned char c = rawpixels[xstart + xc][y - charheight + yc];
									if (c & 1) {
										logo[foundchars * charwidth * charheight / 4 + yc + xc / 4 * charheight] |= 0x80 >> (xc & 3);
									}
									if (c & 2) {
										logo[foundchars * charwidth * charheight / 4 + yc + xc / 4 * charheight] |= 0x08 >> (xc & 3);
									}
								}
							}
							foundchars++;
							if (foundchars > numchars) {
								fprintf(stderr, "found too many characters, found %d expected %d\n", foundchars, numchars);
								exit(1);
							}
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

//	printf("found %d characters\n", foundchars);

	for (int char1 = 0; char1 < foundchars; char1++) {
		for (int char2 = 0; char2 < foundchars; char2++) {
			kern[42 * char1 + char2] = 255;
			for (int y = 0; y < charheight; y++) {
				int xl, xr;
				for (xl = 0; xl < widths[char1] - 6; xl++) {
					if (rawpixels[charx[char1] + widths[char1] - 2 - xl][y + chary[char1]]) break;
					if (y > 0 && rawpixels[charx[char1] + widths[char1] - 2 - xl][y - 1 + chary[char1]]) break;
					if (y < charheight - 1 && rawpixels[charx[char1] + widths[char1] - 2 - xl][y + 1 + chary[char1]]) break;
				}
//				printf("L char %d, y = %d, x = %d\n", char1, y, xl);
				for (xr = 0; xr < widths[char2] - 6; xr++) {
					if (rawpixels[charx[char2] + xr][y + chary[char2]]) break;
				}
//				printf("R char %d, y = %d, x = %d\n", char2, y, xr);
				if (xl + xr < kern[42 * char1 + char2]) {
					kern[42 * char1 + char2] = xl + xr;
				}
			}
//			printf("kern %d-%d: %d\n", char1, char2, kern[42 * char1 + char2]);
		}
	}

	outputfile = fopen("out/inc/font.bin", "wb");
	fwrite(logo, 1, foundchars * charwidth * charheight / 4, outputfile);
	fclose(outputfile);

	outputfile = fopen("out/inc/widths.bin", "wb");
	fwrite(widths, 1, foundchars, outputfile);
	fclose(outputfile);

	outputfile = fopen("out/inc/kerning.bin", "wb");
	fwrite(kern, 1, foundchars * foundchars, outputfile);
	fclose(outputfile);

}
