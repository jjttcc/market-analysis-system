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
#ifdef UNIX
#include <unistd.h>
#endif
#ifdef BCC
#include <io.h>
#define R_OK 4
#endif
#include "external_input_sequence_plug_in_module.h"


struct input_sequence_plug_in {
	char* working_directory;
	char* symbol_file_name;
	char* data_file_name;
	char* errorbuffer;
	int symbol_file_size;
};

enum {
	Buffer_size = 4096
};

enum {
	Maximum_symbol_length = 30
};

enum Error_type {
	None,
	Memory,
	File_read,
	No_valid_path,
	Working_directory_too_long,
	External_retrieval_script_not_found,
	Shell_not_available
};

const char* Symbol_file_name = "symbols.mas";
const char* data_file_name = "data.mas";
const char* Mas_precmd = "perl ";
const char* Mas_postcmd = "mas_external_retrieve.pl ";

char* Data_retrieval_command = 0;

const char* common_errors[] = {
	"(None)",
	"Memory allocation failed.",
	"Error occurred reading file.",
	"No valid path found for file.",
	"Working directory name is too long.",
	"External retrieval script was not found, is not readable, or is empty.",
	"Shell is not available for executing external commands."
};


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

/* Free (char*) elements 0 to `count' - 1 of `arr'. */
void free_str_array(char** arr, const int count) {
	int i = 0;
	while (i < count) {
		free(arr[i]);
		++i;
	}
}

/* Initialize any uninitialized global variables.  Return a value other
 * than None if an error occurred.
 * Precondition: working_directory[strlen(working_directory) - 1] is the
 *    directory separator character.
 * Postcondition: strlen(Data_retrieval_command) < Buffer_size
*/
enum Error_type initialize(char* working_directory) {
	int file_length(char* file_path);
	enum Error_type result = 0;
	char cmdpath[Buffer_size];
	if (Data_retrieval_command == 0) {
		if (system(0) == 0) {
			result = Shell_not_available;
		} else {
			int size = strlen(working_directory) + strlen(Mas_precmd) +
				strlen(Mas_postcmd) + 1;
			if (size > Buffer_size) {
				result = Working_directory_too_long;
			} else {
				/* The working directory is not expected to change during a
				 * process run, so this global variable will keep the same
				 * value from initialization until process termination. */
				Data_retrieval_command = malloc(size);
				if (Data_retrieval_command == 0) {
					result = Memory;
				} else {
					char* s;
					int length;
					strcpy(Data_retrieval_command, Mas_precmd);
					strcat(Data_retrieval_command, working_directory);
					strcat(Data_retrieval_command, Mas_postcmd);
					strcpy(cmdpath, Data_retrieval_command +
						strlen(Mas_precmd));
					s = strstr(cmdpath, " ");
					if (s != 0) *s = '\0';
					length = file_length(cmdpath);
					if (length == -1 || length == 0 ||
							access(cmdpath, R_OK) != 0) {
						result = External_retrieval_script_not_found;
					}
				}
			}
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
	int sepcount, i, onedot = 0;

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
			onedot = 1;
		} else {
			*count = sepcount + 1;
		}
		result = malloc(sizeof(char **) * *count);
		if (result == 0) {
			/* malloc failed. */
			*count = -1;
		} else if (onedot) {
			result[0] = malloc(2);
			if (result[0] == 0) {
				/* malloc failed. */
				*count = -1;
				free(result);
				result = 0;
			} else {
				strncpy(result[0], ".", 2);
			}
		} else {
			i = 0;
			start = paths;
			while (1) {
				end = start;
				while (*end != Separator && *end != '\0') {
					++end;
				}
				if (end == start) {
					assert(*end == Separator || *end == '\0');
					result[i] = malloc(2);
					if (result[i] == 0) {
						/* malloc failed. */
						*count = -1;
						free_str_array(result, i);
						free(result);
						result = 0;
						break;
					}
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
					if (result[i] == 0) {
						/* malloc failed. */
						*count = -1;
						free_str_array(result, i);
						free(result);
						result = 0;
						break;
					}
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
char* concatenation(const char** a, const int count) {
	int i, totalsize;
	enum {Arrsz = 20};
	int sizes_buffer[Arrsz];
	int* sizes;
	char* result = 0;

	if (count > Arrsz) {
		/* sizes_buffer is too small, so use the heap. */
		sizes = malloc(count * sizeof(int));
	} else {
		sizes = sizes_buffer;
	}
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
	if (count > Arrsz) {
		free(sizes);
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
	assert(handle != 0);
	free(handle->working_directory);
	free(handle->symbol_file_name);
	free(handle->data_file_name);
	free(handle->errorbuffer);
	free(handle);
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
 * size of the file; otherwise, 0 is returned and *error_type is set
 * to No_valid_path.  If a memory error occurs, *error_type is set
 * to Memory. */
char* first_valid_directory(char** path_array, int count,
		const char* fname, int* fsize, enum Error_type* error_type) {
	int i, path_length, flength;
	char path[Buffer_size];
	char* s;
	char* result = 0;
	*error_type = None;
	flength = strlen(fname);
	for (i = 0; i < count; ++i) {
		s = path_array[i];
		path_length = strlen(s);
		if (path_length + flength < Buffer_size) {
			strcpy(path, s);
			strncat(path + path_length, fname, flength);
			*fsize = file_length(path);
			if (*fsize >= 0) {
				if (access(path, R_OK) == 0) {
					result = strdup(s);
					if (result == 0) {
						*error_type = Memory;
					}
					break;
				} else {
					printf("Warning: file %s is not readable.\n", path);
				}
			}
		} else {
			printf("Warning: path %s too long for internal buffer.\n", s);
		}
	}
	if (result == 0 && *error_type == None) {
		*error_type = No_valid_path;
	}
	return result;
}

struct input_sequence_plug_in* new_input_sequence_plug_in_handle(
		const char* paths, char* error_buffer, int buffer_size) {
	struct input_sequence_plug_in* result = 0;
	char** path_array;
	int path_count, symfile_size;
	char* dir = 0;
	enum Error_type error = None;
	assert(paths != 0);
	path_array = directories(paths, &path_count);
	if (path_count != -1) {
		dir = first_valid_directory(path_array, path_count,
			Symbol_file_name, &symfile_size, &error);
		free_path_array(path_array, path_count);
	} else {
		error = Memory;
	}
	if (dir != 0) {
		result = malloc(sizeof (struct input_sequence_plug_in));
		if (result != 0) {
			result->symbol_file_name = concat2strings(dir, Symbol_file_name);
			result->data_file_name = concat2strings(dir, data_file_name);
			result->working_directory = dir;
			result->symbol_file_size = symfile_size;
			result->errorbuffer = 0;
			if (result->symbol_file_name == 0 || result->data_file_name == 0) {
				free(result->working_directory);
				free(result->symbol_file_name);
				free(result->data_file_name);
				free(result);
				result = 0;
			}
		} else {
			error = Memory;
		}
	}
	if (error == None) {
		error = initialize(result->working_directory);
	}
	if (error != None) {
		strncpy(error_buffer, common_errors[error], buffer_size);
		if (error == No_valid_path) {
			int msgsize = strlen(common_errors[error]) + 2;
			msgsize += strlen(Symbol_file_name);
			if (buffer_size >= msgsize) {
				strcat(error_buffer, ": ");
				strcat(error_buffer, Symbol_file_name);
			}
		}
		error_buffer[buffer_size - 1] = '\0';
		result = 0;
	}

	return result;
}

/* Obtain the data for `symbol' and put it into handle->data_file_name.
 * If is_intraday, obtain intraday data, else obtain daily data.
 * If an error occurs, put a description of the error into errorbuffer
 * and return a non-zero value.  If no error occurs, return 0.
 * Precondition: Data_retrieval_command != 0 &&
 *    strlen(Data_retrieval_command) > 0 &&
 *    strlen(Data_retrieval_command) < Buffer_size &&
 *    strlen(handle->working_directory) < Buffer_size &&
 *    strlen(handle->data_file_name) < Buffer_size
*/
int obtain_data(struct input_sequence_plug_in* handle,
		char* symbol, int is_intraday) {
	char cmd[Buffer_size * 3 + 512];
	int cmdresult;

/*!!!Add use of is_intraday.*/
	assert(Data_retrieval_command != 0 && strlen(Data_retrieval_command) > 0 &&
		strlen(Data_retrieval_command) < Buffer_size &&
		strlen(handle->working_directory) < Buffer_size &&
		strlen(handle->data_file_name) < Buffer_size);
	if (strlen(symbol) > Maximum_symbol_length) {
		free(handle->errorbuffer);
		handle->errorbuffer = concat2strings("Symbol name is too long: ",
			symbol);
		cmdresult = -1;
	} else {
		strcpy(cmd, Data_retrieval_command);
		assert(Data_retrieval_command[strlen(Data_retrieval_command) - 1] ==
			' ');
		assert(strlen(Data_retrieval_command) + strlen("-i ") +
			strlen(handle->working_directory) + strlen(" ") +
			strlen(handle->data_file_name) + strlen(" ") +
			strlen(symbol) < sizeof(cmd));
		if (is_intraday) {
			strcat(cmd, "-i ");
		}
		strcat(cmd, handle->working_directory);
		strcat(cmd, " ");
		strcat(cmd, handle->data_file_name);
		strcat(cmd, " ");
		strcat(cmd, symbol);
/*printf("executing %s (currend dir: %s)\n", cmd, getcwd(0, 0)); */
		cmdresult = system(cmd);
/*printf("result: %d (currend dir: %s)\n", cmdresult, getcwd(0, 0)); */
	}

	return cmdresult;
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
	const char* slist[5];
	char* result = 0;
	int file_size;

	assert(handle != 0);
	free(handle->errorbuffer);
	handle->errorbuffer = 0;
	slist[0] = "Failed to read data file ";
	slist[1] = handle->data_file_name;
	if (obtain_data(handle, symbol, is_intraday) == 0) {
		file_size = file_length(handle->data_file_name);
		if (file_size == -1) {
			slist[2] = ": ";
			slist[3] = strerror(errno);
			handle->errorbuffer = concatenation(slist, 4);
		} else if (access(handle->data_file_name, R_OK) != 0) {
			slist[2] = ": ";
			slist[3] = strerror(errno);
			handle->errorbuffer = concatenation(slist, 4);
		} else {
			result = malloc(file_size + 1);
			if (result == 0) {
				slist[0] = strerror(errno);
				handle->errorbuffer = concatenation(slist, 1);
			}
		}
		if (result != 0) {
			FILE* f = fopen(handle->data_file_name, "r");
			if (f == 0) {
				slist[0] = strerror(errno);
				handle->errorbuffer = concatenation(slist, 1);
			} else {
				if (fread(result, 1, file_size, f) != file_size) {
					handle->errorbuffer = concatenation(slist, 2);
				} else {
					*size = file_size;
				}
				fclose(f);
			}
		}
	}

	return result;
}
