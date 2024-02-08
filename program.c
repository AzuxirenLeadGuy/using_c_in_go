#include "lib/foobar.h"
#include <stdio.h>

int main()
{
	printf("Running C program (this could be compiled with source/shared/static library)...\n\n");
	int x = 2, y = 3;
	struct Result res = add_safe(x, y);
	printf(
		"On adding %d and %d, obtained answer %d with valid %d\n\n", 
		x, y, res.answer, res.invalid);
	res = sub_safe(x, y);
	printf(
		"On subtracting %d and %d, obtained answer %d with valid %d\n\n", 
		x, y, res.answer, res.invalid);
	return 0;
}
