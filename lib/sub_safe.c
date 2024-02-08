#include "foobar.h"

struct Result sub_safe(unsigned int x, unsigned int y)
{
	struct Result value;
	if (x > y)
	{
		value.answer = x - y;
		value.invalid = 0;
	}
	else
	{
		value.invalid = 1;
	}
	return value;
}
