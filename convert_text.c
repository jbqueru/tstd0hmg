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

// ****************************************************************************
// ****************************************************************************
// ****                                                                    ****
// ****                                                                    ****
// ****            Convert text from ASCII to custom font order            ****
// ****                                                                    ****
// ****                                                                    ****
// ****************************************************************************
// ****************************************************************************

// Our font doesn't include all ASCII characters.
// A classic approach would have been to convert from ASCII order to font
//     order at run-time. However, since we're in a modern environment where
//     build scripts are practical, we can do it at compile time.

// The order of the characters in the font: map from font order to ASCII
char const *const font = " ABCDEFGHIJKLMNOPQRSTUVWXYZ.:!?,-1234567890";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
	char map[128] = {0}; // Map from ASCII to font index
	FILE* file;
	size_t numchars;
	char* text;

	// Build a reverse map, from ASCII to font order
	for (size_t i = 0; i < strlen(font); i++) {
		map[(int)font[i]] = i;
		if (font[i] >= 'A' && font[i] <= 'Z') {
			// Map lowercase letters to uppercase glyphs
			map[font[i] + 32] = i;
		}
	}

	// Open input file
	file = fopen("text.txt", "rb");
	if (!file) {
		fprintf(stderr, "couldn't open input file\n");
		exit(1);
	}

	// Determine size of input file
	if (fseek(file, 0, SEEK_END)) {
		fprintf(stderr, "couldn't seek to end of input file\n");
		exit(1);
	}
	numchars = ftell(file);
	if (fseek(file, 0, SEEK_SET)) {
		fprintf(stderr, "couldn't seek to beginning of input file\n");
		exit(1);
	}

	// Allocate buffer accordingly
	text = calloc(numchars, 1);
	if (!text) {
		fprintf(stderr, "couldn't allocate buffer for text\n");
		exit(1);
	}

	// Read and close input file
	if (fread(text, 1, numchars, file) != numchars) {
		fprintf(stderr, "couldn't read entire file\n");
		exit(1);
	}
	if (fclose(file)) {
		fprintf(stderr, "couldn't close input file\n");
		exit(1);
	}

	// Convert from ASCII to font order
	for (size_t i = 0; i < numchars; i++) {
		unsigned char c = (unsigned char)text[i];
		if (c != '\n' && (c < 32 || c > 127)) {
			fprintf(stderr, "text contains non-ASCII character\n");
			exit(1);
		}
		if (c != '\n' && c != ' ' && !map[c]) {
			fprintf(stderr, "text contains character missing from font\n");
			exit(1);
		}
		text[i] = map[c];
	}

	// Write output file
	file = fopen("out/inc/text.bin", "wb");
	if (!file) {
		fprintf(stderr, "couldn't open output file\n");
		exit(1);
	}
	if (fwrite(text, 1, numchars, file) != numchars) {
		fprintf(stderr, "couldn't write to output file\n");
		exit(1);
	}
	if (fclose(file)) {
		fprintf(stderr, "couldn't close output file\n");
		exit(1);
	}

	return 0;
}
