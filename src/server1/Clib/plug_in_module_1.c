#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include "external_input_sequence_plug_in_module.h"


void initialize_plug_in() {
}

struct input_sequence_plug_in {
	char* symbol_file_name;
	char* data_file_name;
	char errorbuffer[BUFSIZ];
};

void close_handle(struct input_sequence_plug_in* handle) {
printf("starting close_handle: handle %d\n", (int) handle);
	assert(handle != 0);
	free (handle);
printf("ending close_handle\n");
}

struct input_sequence_plug_in* new_input_sequence_plug_in_handle() {
	struct input_sequence_plug_in* result;
	result = malloc(sizeof (struct input_sequence_plug_in));
	result->errorbuffer[BUFSIZ - 1] = '\0';
	result->symbol_file_name = "tickers.txt";
	result->data_file_name = "ibm.txt";
	return result;
}

char* last_error(struct input_sequence_plug_in* handle) {
	assert(handle != 0);
	return handle->errorbuffer;
}

/* Make symbols from src - put them into dest.  count is the size of dest.
 * symbols in src will be separated by newlines (no newline at end) */
void make_symbols(char* dest, char* src, int count) {
	char* end = src + count;
	while (src < end) {
		while (! isspace(*src) && src < end) {
			*dest++ = *src++;
		}
		*dest++ = '\n';
		while (isspace(*src) && src < end) {
			++src;
		}
	}
	*(dest - 1) = '\0';
}

char* symbol_list(struct input_sequence_plug_in* handle) {
	struct stat sfile_status;
	char* buffer = 0;
	char readerror[BUFSIZ];
	char* result = 0;

	assert(handle != 0);
	strcpy(readerror, "Failed to read symbols file ");
	strncat(readerror, handle->symbol_file_name, BUFSIZ - 1);
	readerror[BUFSIZ - 1] = '\0';
	if (stat(handle->symbol_file_name, &sfile_status) != 0) {
		strncpy(handle->errorbuffer, strerror(errno),
			sizeof(handle->errorbuffer) - 1);
	} else {
		result = malloc(sfile_status.st_size + 1);
		buffer = malloc(sfile_status.st_size + 1);
		if (result == 0 || buffer == 0) {
			strncpy(handle->errorbuffer, strerror(errno),
				sizeof(handle->errorbuffer) - 1);
			free(result);
			result = 0;
		} else {
			result[sfile_status.st_size - 1] = '\0';
		}
	}
	if (result != 0) {
		FILE* f = fopen(handle->symbol_file_name, "r");
		if (f == 0) {
			strncpy(handle->errorbuffer, strerror(errno),
					sizeof(handle->errorbuffer) - 1);
		} else {
			if (fread(buffer, 1, sfile_status.st_size, f) !=
					sfile_status.st_size) {
				strncpy(handle->errorbuffer, readerror,
					sizeof(handle->errorbuffer) - 1);
			} else {
				make_symbols(result, buffer,
					sfile_status.st_size);
			}
			fclose(f);
		}
	}
	free (buffer);

	return result;
}

char* tradable_data(struct input_sequence_plug_in* handle,
		char* symbol, int is_intraday, int* size) {
	struct stat sfile_status;
	char readerror[BUFSIZ];
	char* result = 0;

	assert(handle != 0);
	strcpy(readerror, "Failed to read data file ");
	strncat(readerror, handle->data_file_name, BUFSIZ - 1);
	readerror[BUFSIZ - 1] = '\0';
	if (stat(handle->data_file_name, &sfile_status) != 0) {
printf("trdata - stat error\n");
		strncpy(handle->errorbuffer, strerror(errno),
			sizeof(handle->errorbuffer) - 1);
	} else {
printf("trdata - OK\n");
		result = malloc(sfile_status.st_size + 1);
		if (result == 0) {
			strncpy(handle->errorbuffer, strerror(errno),
				sizeof(handle->errorbuffer) - 1);
		}
	}
	if (result != 0) {
		FILE* f = fopen(handle->data_file_name, "r");
printf("trdata result is not 0\n");
		if (f == 0) {
printf("trdata - fopen failed.\n");
			strncpy(handle->errorbuffer, strerror(errno),
					sizeof(handle->errorbuffer) - 1);
		} else {
printf("trdata - fopen succeeded\n");
			if (fread(result, 1, sfile_status.st_size, f) !=
					sfile_status.st_size) {
printf("trdata - fread failed\n");
				strncpy(handle->errorbuffer, readerror,
					sizeof(handle->errorbuffer) - 1);
			} else {
				*size = sfile_status.st_size;
			}
			fclose(f);
		}
	}
/*printf("trdata returning:\n'%s'\n", result);*/

	return result;
}
