/**
	description: "The first implementation of the plug-in module for the%
		%EXTERNAL_INPUT_SEQUENCE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
**/

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
	char* errorbuffer;
	int symbol_file_size;
};

const char* symbol_file_name = "symbols.mas";
const char* data_file_name = "data.mas";

/* Number of times `c' occurs in `s' */
int char_count(const char* s, char c) {
	int result = 0;
	if (s != 0) {
		for (result = 0; *s; ++s) {
			if (*s == c) ++result;
		}
	}
	return result;
}

/* Array of directories extracted from `paths' with separator ':'.
 * The address at `count' holds the number of elements in the result or,
 * if memory allocation fails, -1.
 * Returns 0 if `paths' is "" (empty). */
char** directories(const char* paths, int* count) {
	const char *start, *end;
	const char Separator = ':';
	char** result = 0;
	int sepcount, i;

	assert(paths != 0 && paths[strlen(paths)] == '\0');
	if (paths[0] != '\0') {
		start = paths;
		for (sepcount = 0; *start != '\0'; ++start) {
			if (*start == Separator) {
				++sepcount;
			}
		}
		if (char_count(paths, ':') == strlen(paths)) {
			*count = 1;
		} else {
			*count = sepcount + 1;
		}
		result = malloc(sizeof(char **) * *count);
		if (result == 0) {
			*count = -1;
		} else {
			i = 0;
			start = paths;
			while (1) {
				end = start;
				while (*end != Separator && *end != '\0') {
					++end;
				}
				/* !!Need error checking of malloc results. */
				if (end == start) {
					assert(*end == Separator || *end == '\0');
					result[i] = malloc(2);
					strncpy(result[i], ".", 2);
					if (end[1] == '\0') {
						if (i == *count - 2) {
							*count = i + 1;
							free(result[*count]);
						}
						break;
					}
				} else {
					result[i] = malloc(end - start + 1);
					strncpy(result[i], start, end - start);
					result[i][end - start] = '\0';
				}
				++i;
				if (*end != '\0') {
					start = end + 1;
				} else {
					break;
				}
			}
		}
	} else {
		*count = 0;
	}

	return result;
}

/* A new heap-allocated string with all `count' elements of the array `a'
 * copied to it
 * Precondition: a != 0 && count > 0 */
char* concatenation(const char** a, int count) {
	int i, totalsize;
	int sizes[count];
	char* result = 0;

	assert(a != 0 && count > 0);
	for (i = 0, totalsize = 0; i < count; ++i) {
		sizes[i] = strlen(a[i]);
		totalsize += sizes[i];
	}
	result = malloc(totalsize + 1);
	if (result != 0) {
		i = 0;
		totalsize = 0;
		strcpy(result, a[i]);
		totalsize += sizes[i];
		for (++i; i < count; ++i) {
			strncat(result + totalsize, a[i], sizes[i]);
			totalsize += sizes[i];
		}
		result[totalsize] = '\0';
	}
	return result;
}

/* A new heap-allocated string containing the concatenation of s1 and s2. */
char* concat2strings(const char* s1, const char* s2) {
	const char* slist[2];
	assert(s1 != 0 && s2 != 0);
	slist[0] = s1; slist[1] = s2;
	return concatenation(slist, 2);
}

void close_handle(struct input_sequence_plug_in* handle) {
printf("starting close_handle: handle %d\n", (int) handle);
	assert(handle != 0);
	free(handle->symbol_file_name);
	free(handle->data_file_name);
	free(handle->errorbuffer);
	free(handle);
printf("ending close_handle\n");
}

/* Size of file with path `file_path' via a call to stat.  If the file does
 * not exist or some other error occurs, -1 is returned and errno will
 * remain set from the stat call. */
int file_length(char* file_path) {
	struct stat file_status;
	int result;
	if (stat(file_path, &file_status) != 0) {
		result = -1;
	} else {
		result = file_status.st_size;
	}
	return result;
}

void free_path_array(char** path_array, int count) {
	int i;
	for (i = 0; i < count; ++i) {
		free(path_array[i]);
	}
	free(path_array);
}

/* A heap-allocated clone of the first directory in path_array where the
 * file named `fname' exists.
 * If a valid directory is found, the address at fsize will hold the
 * size of the file; otherwise, 0 is returned. */
char* first_valid_directory(char** path_array, int count,
		const char* fname, int* fsize) {
	int i, path_length, flength;
	char path[BUFSIZ];
	char* s;
	char* result = 0;
	flength = strlen(fname);
	for (i = 0; i < count; ++i) {
		s = path_array[i];
		path_length = strlen(s);
		if (path_length + flength < BUFSIZ) {
			strcpy(path, s);
			strncat(path + path_length, fname, flength);
			*fsize = file_length(path);
			if (*fsize >= 0) {
				result = strdup(s);
				break;
			}
		} else {
			/*!!!Warn that `s' is too long. */
		}
	}
	return result;
}

struct input_sequence_plug_in* new_input_sequence_plug_in_handle(
		const char* paths) {
	struct input_sequence_plug_in* result = 0;
	char** path_array;
	int path_count, symfile_size;
	char* dir;
	assert(paths != 0);
	path_array = directories(paths, &path_count);
	dir = first_valid_directory(path_array, path_count, symbol_file_name,
		&symfile_size);
	free_path_array(path_array, path_count);
	if (dir != 0) {
printf("new input...: using dir %s, sym file size is %d\n",
dir, symfile_size);
		result = malloc(sizeof (struct input_sequence_plug_in));
		if (result != 0) {
			result->symbol_file_name = concat2strings(dir, symbol_file_name);
			result->data_file_name = concat2strings(dir, data_file_name);
			result->symbol_file_size = symfile_size;
printf("new input...: set sym fname, data fname, sym fsize to: %s, %s, %d\n",
result->symbol_file_name, result->data_file_name, result->symbol_file_size);
			result->errorbuffer = 0;
			if (result->symbol_file_name == 0 || result->data_file_name == 0) {
				free(result->symbol_file_name);
				free(result->data_file_name);
				free(result);
				result = 0;
			}
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
	char* buffer = 0;
	const char* slist[5];
	char* result = 0;
printf("symbol_list trying to use file name '%s'\n",
handle->symbol_file_name);

	assert(handle != 0);
	free(handle->errorbuffer);
	handle->errorbuffer = 0;
	slist[0] = "Failed to read symbols file ";
	slist[1] = handle->symbol_file_name;
	result = malloc(handle->symbol_file_size + 1);
	buffer = malloc(handle->symbol_file_size + 1);
	if (result == 0 || buffer == 0) {
		slist[0] = strerror(errno);
		handle->errorbuffer = concatenation(slist, 1);
		free(result);
		result = 0;
	} else {
		result[handle->symbol_file_size - 1] = '\0';
	}
	if (result != 0) {
		FILE* f = fopen(handle->symbol_file_name, "r");
		if (f == 0) {
			slist[0] = strerror(errno);
			handle->errorbuffer = concatenation(slist, 1);
		} else {
			if (fread(buffer, 1, handle->symbol_file_size, f) !=
					handle->symbol_file_size) {
				handle->errorbuffer = concatenation(slist, 2);
			} else {
				make_symbols(result, buffer,
					handle->symbol_file_size);
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
	const char* slist[5];
	char* result = 0;

	assert(handle != 0);
	free(handle->errorbuffer);
	handle->errorbuffer = 0;
	slist[0] = "Failed to read data file ";
	slist[1] = handle->data_file_name;
	if (stat(handle->data_file_name, &sfile_status) != 0) {
printf("trdata - stat error\n");
		slist[2] = ": ";
		slist[3] = strerror(errno);
		handle->errorbuffer = concatenation(slist, 4);
	} else {
printf("trdata - OK\n");
		result = malloc(sfile_status.st_size + 1);
		if (result == 0) {
			slist[0] = strerror(errno);
			handle->errorbuffer = concatenation(slist, 1);
		}
	}
	if (result != 0) {
		FILE* f = fopen(handle->data_file_name, "r");
printf("trdata result is not 0\n");
		if (f == 0) {
printf("trdata - fopen failed.\n");
			slist[0] = strerror(errno);
			handle->errorbuffer = concatenation(slist, 1);
		} else {
printf("trdata - fopen succeeded\n");
			if (fread(result, 1, sfile_status.st_size, f) !=
					sfile_status.st_size) {
printf("trdata - fread failed\n");
				handle->errorbuffer = concatenation(slist, 2);
			} else {
				*size = sfile_status.st_size;
			}
			fclose(f);
		}
	}
/*printf("trdata returning:\n'%s'\n", result);*/

	return result;
}
