/**
	description: "C implementation of EXTERNAL_INPUT_SEQUENCE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
**/

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
	char* error_msg;
};

const char record_separator = '\n';

static char* fs_char_table = 0;

static char fs_char_table_contents[256];

//struct input_sequence_plug_in* initialize_external_input_routines() {
struct input_sequence_handle* initialize_external_input_routines() {
	struct input_sequence_handle* result;
	result = malloc(sizeof(struct input_sequence_handle));
	if (result != 0) {
		result->plug_in_handle = new_input_sequence_plug_in_handle();
		result->buffer = 0;
		result->symbols = 0;
		result->buffersize = 0;
		result->current_index = 0;
		result->current_field_length_value = 0;
		result->field_separator = ',';	/* May be made configurable later */
		result->error_occurred = 0;
		result->error_msg = "";
	}
	return result;
}

int is_open_implementation(struct input_sequence_handle* handle) {
	return handle->buffer != 0;
}

void external_dispose(struct input_sequence_handle* handle) {
printf("starting external_dispose\n");
	close_handle(handle->plug_in_handle);
	free(handle->buffer);
	free(handle->symbols);
	free(handle);
printf("ending external_dispose\n");
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
/**!!!printf("after_last_record_implementation - ci, bufsz: %d, %d\n",
handle->current_index, handle->buffersize);*/
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
/**!!!NOTE: Need to document in user documentation that any of the field
 * separators used below can be used in the input and that the FS will
 * be determined automatically, and that it's an error if the field
 * separator in the input is not one of these characters. */
void initialize_fs_char_table() {
	char* fschars = ",\t;\a!@$%^&|";
	int fscount = strlen(fschars);
	int i;
	/* Set all members of fs_char_table_contents whose index is a member
	 * of fschars to true - all other members have been initialized
	 * to false. */
	for (i = 0; i < fscount; ++i) {
		fs_char_table_contents[(int) fschars[i]] = 1;
	}
	fs_char_table = fs_char_table_contents;
}

void start_implementation(struct input_sequence_handle* handle,
		char* symbol, int is_intraday) {
	handle->error_occurred = 1;
	if (fs_char_table == 0) {
		initialize_fs_char_table();
	}
	free(handle->buffer);
	/**!!!Probably need to check for input_sequence_plug_in being 0 and,
	 * if so, set error status. */
	handle->buffer = tradable_data(handle->plug_in_handle, symbol,
		is_intraday, &handle->buffersize);
	if (handle->buffer == 0) {
		handle->error_occurred = 1;
		handle->error_msg = last_error(handle->plug_in_handle);
	}
	handle->current_index = 0;
	set_field_separator(handle);
printf("start_imp - bufsz: %d\n", handle->buffersize);
}

char* available_symbols(struct input_sequence_handle* handle) {
	return handle->symbols;
}

int external_error(struct input_sequence_handle* handle) {
	return handle->error_occurred;
}

char* last_external_error(struct input_sequence_handle* handle) {
printf("ler returning %s\n", handle->error_msg);
	return handle->error_msg;
}

void make_available_symbols(struct input_sequence_handle* handle) {
printf("starting make_av symb\n");
	handle->error_occurred = 0;
printf("A\n");
	if (handle->symbols == 0) {
		handle->symbols = symbol_list(handle->plug_in_handle);
printf("B\n");
	}
	if (handle->symbols == 0) {
		handle->error_occurred = 1;
		handle->error_msg = last_error(handle->plug_in_handle);
	}
}

int intraday_data_available_implementation(
		struct input_sequence_handle* handle) {
/**!!!Stub */
	return 0;
}
