/**
	description: "C implementation of EXTERNAL_INPUT_SEQUENCE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
**/

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <eif_cecil.h>
#include "external_input_sequence_plug_in_module.h"

struct input_sequence_handle {
	char* buffer;
	char* symbols;
	int buffersize;
	int current_index;
	int current_field_length_value;
	char field_separator;
	struct input_sequence_plug_in* plug_in_handle;
	int error_occurred;
};

const char record_separator = '\n';

static char* fs_char_table = 0;

static char fs_char_table_contents[256];

static char* initialization_error_string = 0;

int init_error = 0;

struct input_sequence_handle* initialize_external_input_routines(char* paths) {
	struct input_sequence_handle* result;
	char error_buffer[BUFSIZ];
	assert(paths != 0);
	init_error = 0;
	result = malloc(sizeof(struct input_sequence_handle));
	if (result != 0) {
		result->plug_in_handle = new_input_sequence_plug_in_handle(paths,
			error_buffer, sizeof(error_buffer));
		result->buffer = 0;
		result->symbols = 0;
		result->buffersize = 0;
		result->current_index = 0;
		result->current_field_length_value = 0;
		result->field_separator = ',';	/* May be made configurable later */
		result->error_occurred = 0;
		if (result->plug_in_handle == 0) {
			init_error = 1;
			free(initialization_error_string);
			initialization_error_string = strdup(error_buffer);
			free(result);
			result = 0;
		}
	} else {
		init_error = 1;
	}
	return result;
}

int is_open_implementation(struct input_sequence_handle* handle) {
	return handle->buffer != 0;
}

void external_dispose(struct input_sequence_handle* handle) {
	if (handle != 0) {
		close_handle(handle->plug_in_handle);
		free(handle->buffer);
		free(handle->symbols);
		free(handle);
	}
	free(initialization_error_string);
}

int current_field_length(struct input_sequence_handle* handle) {
	return handle->current_field_length_value;
}

char* current_field(struct input_sequence_handle* handle) {
	int i;
	handle->current_field_length_value = 0;
	for (i = handle->current_index; i < handle->buffersize &&
			handle->buffer[i] != handle->field_separator &&
			handle->buffer[i] != record_separator; ++i) {

		++handle->current_field_length_value;
	}
	return &handle->buffer[handle->current_index];
}

char current_character(struct input_sequence_handle* handle) {
	return handle->buffer[handle->current_index++];
}

void advance_to_next_field_implementation(
		struct input_sequence_handle* handle) {
	while (handle->buffer[handle->current_index] != handle->field_separator &&
			handle->buffer[handle->current_index] != record_separator &&
			handle->current_index < handle->buffersize) {
		++handle->current_index;
	}
	if (handle->current_index < handle->buffersize &&
			handle->buffer[handle->current_index] == handle->field_separator) {
		++handle->current_index;
	}
}

void advance_to_next_record_implementation(
		struct input_sequence_handle* handle) {
	while (handle->buffer[handle->current_index] != record_separator &&
			handle->current_index < handle->buffersize) {
		++handle->current_index;
	}
	if (handle->current_index < handle->buffersize &&
			handle->buffer[handle->current_index] == record_separator) {
		++handle->current_index;
	}
}

int field_count_implementation(struct input_sequence_handle* handle) {
	int result = 0;
	if (handle->buffer != 0 && handle->buffersize > 0) {
		int i;
		result = 1;
		for (i = 0; i < handle->buffersize; ++i) {
			if (handle->buffer[i] == handle->field_separator) {
				++result;
			}
			if (handle->buffer[i] == record_separator) {
				break;
			}
		}
	}

	return result;
}

int after_last_record_implementation(struct input_sequence_handle* handle) {
	return handle->current_index == handle->buffersize;
}

int readable_implementation(struct input_sequence_handle* handle) {
	return is_open_implementation(handle) &&
		! after_last_record_implementation(handle);
}

static void set_field_separator(struct input_sequence_handle* handle) {
	handle->field_separator = ',';
	if (handle->buffer != 0 && handle->buffersize > 0) {
		int i;
		for (i = 0; i < handle->buffersize &&
				handle->buffer[i] != record_separator; ++i) {
			if (fs_char_table[(int) handle->buffer[i]]) {
				handle->field_separator = handle->buffer[i];
				break;
			}
		}
	}
}

/* Initialize the fs_char_table_contents and set fs_char_table to point to
 * it.
*/
void initialize_fs_char_table() {
	int fscount = strlen(Field_separator_characters);
	int i;
	/* Set all members of fs_char_table_contents whose index is a member
	 * of Field_separator_characters to true - all other members have
	 * been initialized to false. */
	for (i = 0; i < fscount; ++i) {
		fs_char_table_contents[(int) Field_separator_characters[i]] = 1;
	}
	fs_char_table = fs_char_table_contents;
}

void retrieve_data(struct input_sequence_handle* handle,
		char* symbol, int is_intraday) {
	handle->error_occurred = 0;
	if (fs_char_table == 0) {
		initialize_fs_char_table();
	}
	free(handle->buffer);
	handle->buffer = tradable_data(handle->plug_in_handle, symbol,
		is_intraday, &handle->buffersize);
	if (handle->buffer == 0) {
		handle->error_occurred = 1;
	}
	handle->current_index = 0;
	set_field_separator(handle);
}

void start_implementation(struct input_sequence_handle* handle) {
	handle->current_index = 0;
}

char* available_symbols(struct input_sequence_handle* handle) {
	return handle->symbols;
}

int external_error(struct input_sequence_handle* handle) {
	return handle->error_occurred;
}

char* last_external_error(struct input_sequence_handle* handle) {
	char* result;
	result = last_error(handle->plug_in_handle);
	if (result == 0) result = "";
	return result;
}

void make_available_symbols(struct input_sequence_handle* handle) {
	handle->error_occurred = 0;
	if (handle->symbols == 0) {
		handle->symbols = symbol_list(handle->plug_in_handle);
	}
	if (handle->symbols == 0) {
		handle->error_occurred = 1;
	}
}

int intraday_data_available_implementation(
		struct input_sequence_handle* handle) {
/**!!!Stub - intraday data is to be implemented in a future release. */
	return 0;
}

int initialization_error() {
	return init_error;
}

char* initialization_error_reason() {
	char* result;
	if (initialization_error_string == 0) {
		result = "Memory allocation failed.";
	} else {
		result = initialization_error_string;
	}
	return result;
}
