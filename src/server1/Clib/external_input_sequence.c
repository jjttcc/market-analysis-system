/**
	description: "C implementation of EXTERNAL_INPUT_SEQUENCE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
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

const char Record_separator = '\n';

const char Path_separator = '';

static char* Fs_char_table = 0;

static char Fs_char_table_contents[256];

static char* Initialization_error_string = 0;

int Init_error = 0;

struct input_sequence_handle* initialize_external_input_routines(EIF_POINTER paths) {
	struct input_sequence_handle* result;
	char error_buffer[BUFSIZ];
	assert(paths != 0);
	Init_error = 0;
	result = malloc(sizeof(struct input_sequence_handle));
	if (result != 0) {
		result->plug_in_handle = new_input_sequence_plug_in_handle(paths,
			error_buffer, sizeof(error_buffer), Path_separator);
		result->buffer = 0;
		result->symbols = 0;
		result->buffersize = 0;
		result->current_index = 0;
		result->current_field_length_value = 0;
		result->field_separator = ',';	/* May be made configurable later */
		result->error_occurred = 0;
		if (result->plug_in_handle == 0) {
			Init_error = 1;
			free(Initialization_error_string);
			Initialization_error_string = strdup(error_buffer);
			free(result);
			result = 0;
		}
	} else {
		Init_error = 1;
	}
	return result;
}

EIF_BOOLEAN is_open_implementation(struct input_sequence_handle* handle) {
	return handle->buffer != 0;
}

void external_dispose(struct input_sequence_handle* handle) {
	if (handle != 0) {
		close_handle(handle->plug_in_handle);
		free(handle->buffer);
		free(handle->symbols);
		free(handle);
	}
	free(Initialization_error_string);
}

EIF_INTEGER current_field_length(struct input_sequence_handle* handle) {
	return handle->current_field_length_value;
}

EIF_POINTER current_field(struct input_sequence_handle* handle) {
	int i;
	handle->current_field_length_value = 0;
	for (i = handle->current_index; i < handle->buffersize &&
			handle->buffer[i] != handle->field_separator &&
			handle->buffer[i] != Record_separator; ++i) {

		++handle->current_field_length_value;
	}
	return &handle->buffer[handle->current_index];
}

EIF_CHARACTER current_character(struct input_sequence_handle* handle) {
	return handle->buffer[handle->current_index++];
}

void advance_to_next_field_implementation(
		struct input_sequence_handle* handle) {
	while (handle->buffer[handle->current_index] != handle->field_separator &&
			handle->buffer[handle->current_index] != Record_separator &&
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
	while (handle->buffer[handle->current_index] != Record_separator &&
			handle->current_index < handle->buffersize) {
		++handle->current_index;
	}
	if (handle->current_index < handle->buffersize &&
			handle->buffer[handle->current_index] == Record_separator) {
		++handle->current_index;
	}
}

EIF_INTEGER field_count_implementation(struct input_sequence_handle* handle) {
	int result = 0;
	if (handle->buffer != 0 && handle->buffersize > 0) {
		int i;
		result = 1;
		for (i = 0; i < handle->buffersize; ++i) {
			if (handle->buffer[i] == handle->field_separator) {
				++result;
			}
			if (handle->buffer[i] == Record_separator) {
				break;
			}
		}
	}

	return result;
}

EIF_BOOLEAN after_last_record_implementation(struct input_sequence_handle* handle) {
	return handle->current_index == handle->buffersize;
}

EIF_BOOLEAN readable_implementation(struct input_sequence_handle* handle) {
	return is_open_implementation(handle) &&
		! after_last_record_implementation(handle);
}

static void set_field_separator(struct input_sequence_handle* handle) {
	handle->field_separator = ',';
	if (handle->buffer != 0 && handle->buffersize > 0) {
		int i;
		for (i = 0; i < handle->buffersize &&
				handle->buffer[i] != Record_separator; ++i) {
			if (Fs_char_table[(int) handle->buffer[i]]) {
				handle->field_separator = handle->buffer[i];
				break;
			}
		}
	}
}

/* Initialize the Fs_char_table_contents and set Fs_char_table to point to
 * it.
*/
void initialize_Fs_char_table() {
	int fscount = strlen(Field_separator_characters);
	int i;
	/* Set all members of Fs_char_table_contents whose index is a member
	 * of Field_separator_characters to true - all other members have
	 * been initialized to false. */
	for (i = 0; i < fscount; ++i) {
		Fs_char_table_contents[(int) Field_separator_characters[i]] = 1;
	}
	Fs_char_table = Fs_char_table_contents;
}

void retrieve_data(struct input_sequence_handle* handle,
		EIF_POINTER symbol, EIF_BOOLEAN is_intraday) {
	handle->error_occurred = 0;
	if (Fs_char_table == 0) {
		initialize_Fs_char_table();
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

EIF_POINTER available_symbols(struct input_sequence_handle* handle) {
	return handle->symbols;
}

EIF_BOOLEAN external_error(struct input_sequence_handle* handle) {
	return handle->error_occurred;
}

EIF_POINTER last_external_error(struct input_sequence_handle* handle) {
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

EIF_BOOLEAN intraday_data_available_implementation(
		struct input_sequence_handle* handle) {
/**!!!Stub - intraday data is to be implemented in a future release. */
	return 0;
}

EIF_BOOLEAN initialization_error() {
	return Init_error;
}

EIF_POINTER initialization_error_reason() {
	char* result;
	if (Initialization_error_string == 0) {
		result = "Memory allocation failed.";
	} else {
		result = Initialization_error_string;
	}
	return result;
}
