#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include "external_input_sequence_plug_in_module.h"


struct input_sequence_plug_in {
	char* symbol_file_name;
	char* data_file_name;
	char errorbuffer[BUFSIZ];
};

const char* symbol_file_name = "symbols.mas";
const char* data_file_name = "data.mas";

void close_handle(struct input_sequence_plug_in* handle) {
printf("starting close_handle: handle %d\n", (int) handle);
	assert(handle != 0);
	free(handle->symbol_file_name);
	free(handle->data_file_name);
	free(handle);
printf("ending close_handle\n");
}

/* A new heap-allocated string with s2 appended to s1 */
char* concatenated_string(const char* s1, const char* s2) {
	int s1_length = strlen(s1);
	int s2_length = strlen(s2);
	char* result = malloc(s1_length + s2_length + 1);
	strncpy(result, s1, s1_length + 1);
	strncat(result, s2, s2_length);
printf("length of result, s1, s2, s1 + s2: %d, %d, %d, %d\n",
strlen(result), strlen(s1), strlen(s2), strlen(s1) + strlen(s2));
printf("result: '%s'\nresult end, result end-1, res end -2:%d, %c, %c\n",
result, result[s1_length + s2_length],
result[s1_length + s2_length - 1],
result[s1_length + s2_length - 2]);

	assert(strlen(result) == strlen(s1) + strlen(s2));
	assert(result[s1_length + s2_length] == '\0');
	return result;
}

struct input_sequence_plug_in* new_input_sequence_plug_in_handle(
		const char* dir) {
	struct input_sequence_plug_in* result;
	assert(dir != 0);
	result = malloc(sizeof (struct input_sequence_plug_in));
	if (result != 0) {
		result->errorbuffer[BUFSIZ - 1] = '\0';
		result->symbol_file_name = concatenated_string(dir, symbol_file_name);
		result->data_file_name = concatenated_string(dir, data_file_name);
		if (result->symbol_file_name == 0 || result->data_file_name == 0) {
			free(result->symbol_file_name);
			free(result->data_file_name);
			free(result);
			result = 0;
		}
	}
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
		strncpy(handle->errorbuffer, readerror,
			sizeof(handle->errorbuffer) - 1);
		strncat(handle->errorbuffer, ": ", 2);
		strncat(handle->errorbuffer, strerror(errno),
			sizeof(handle->errorbuffer) - strlen(readerror) - 1);
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
