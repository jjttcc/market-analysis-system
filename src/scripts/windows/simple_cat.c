/* Simple concatenation tool - can be used in Windows as the MAS "mailer"
 * program to concatenate buy/sell signals to a file */

#include <stdio.h>

int main(int argc, char** argv) {
	int c;
	while ((c = getchar()) != EOF) {
		putchar(c);
	}
	return 0;
}
