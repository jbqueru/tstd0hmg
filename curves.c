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
#include <math.h>

void main() {
	FILE* outputfile;

	outputfile = fopen("out/inc/curves.inc", "w");
	fprintf(outputfile,
		"; Copyright 2025 Jean-Baptiste M. \"JBQ\" \"Djaybee\" Queru\n"
		";\n"
		"; This program is free software: you can redistribute it and/or modify\n"
		"; it under the terms of the GNU Affero General Public License as\n"
		"; published by the Free Software Foundation, either version 3 of the\n"
		"; License, or (at your option) any later version.\n"
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
		"; See curves.c for more information \n"
		"\n"
	);

	const int p1 = 61, p2 = 41, p3 = 31;
	const int h = 112;
	const double a = p1;

	fprintf(outputfile, "StartCurve1:\n");
	for (int i = -p1; i < p1; i++) {
		fprintf(outputfile, "  .dc.b %d\n", (int)(h*((i/a)*(i/a)+(1-(p1/a)*(p1/a)))));
	}
	fprintf(outputfile, "EndCurve1:\n");


	fprintf(outputfile, "StartCurve2:\n");
	for (int i = -p2; i < p2; i++) {
		fprintf(outputfile, "  .dc.b %d\n", (int)(h*((i/a)*(i/a)+(1-(p2/a)*(p2/a)))));
	}
	fprintf(outputfile, "EndCurve2:\n");

	fprintf(outputfile, "StartCurve3:\n");
	for (int i = -p3; i < p3; i++) {
		fprintf(outputfile, "  .dc.b %d\n", (int)(h*((i/a)*(i/a)+(1-(p3/a)*(p3/a)))));
	}
	fprintf(outputfile, "EndCurve3:\n");

	fclose(outputfile);
}
