#ifndef FOOBAR_H
#define FOOBAR_H

unsigned int magic_number();

struct Result
{
	unsigned char invalid;
	unsigned int answer;	
};

struct Result add_safe(unsigned int x, unsigned int y);

struct Result sub_safe(unsigned int x, unsigned int y);

#endif
