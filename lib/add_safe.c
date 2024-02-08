#include "foobar.h"
#include <limits.h>

struct Result add_safe(unsigned int x, unsigned int y)
{
	struct Result value;
	if (x < UINT_MAX - y)
	{
		value.answer = x + y;
		value.invalid = 0;
	}
	else
	{
		value.invalid = 1;
	}
	return value;
}
