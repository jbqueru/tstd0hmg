/*
 * Copyright 2025 Jean-Baptiste M. "JBQ" "Djaybee" Queru
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
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

#define MAX_TEXT 2000

unsigned char intext[MAX_TEXT] = {0};
unsigned char outtext[MAX_TEXT] = {0};

unsigned char font[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.:!?,-1234567890";

unsigned char map[128] = {0};

void main() {
	FILE* inputfile;
	FILE* outputfile;
	int numchars;

	for (int i = 0; i < sizeof font; i++) {
		map[font[i]] = i + 1;
		if (font[i] >= 'A' && font[i] <= 'Z') {
			map[font[i] + 32] = i + 1;
		}
	}

	inputfile = fopen("text.txt", "rb");
	if (!inputfile) {
		fprintf(stderr, "couldn't open input file\n");
		exit(1);
	}
	numchars = fread(intext, 1, MAX_TEXT, inputfile);
	if (!numchars) {
		fprintf(stderr, "couldn't read from input file\n");
		exit(1);
	}
	if (fclose(inputfile)) {
		fprintf(stderr, "couldn't close input file\n");
		exit(1);
	}

	for (int i = 0; i < numchars; i++) {
		outtext[i] = map[intext[i]];
	}

	outputfile = fopen("out/inc/text.bin", "wb");
	if (!outputfile) {
		fprintf(stderr, "couldn't open output file\n");
		exit(1);
	}
	if (fwrite(outtext, 1, numchars, outputfile) != numchars) {
		fprintf(stderr, "couldn't write to output file\n");
		exit(1);
	}
	if (fclose(outputfile)) {
		fprintf(stderr, "couldn't close output file\n");
		exit(1);
	}

	exit(0);
}
