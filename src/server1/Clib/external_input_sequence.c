/**
	description: "C implementation of EXTERNAL_INPUT_SEQUENCE";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
**/

#include <string.h>
#include "external_input_sequence_plug_in_module.h"

char* buffer = 0;
int buffersize = 0;
int current_index = 0;
int current_field_length_value = 0;
char field_separator = ',';	/* May be made configurable later */
const char record_separator = '\n';
struct input_sequence_plug_in* input_sequence_handle;
int error_occurred = 0;
char* error_msg = "";

static char* fs_char_table = 0;

static char fs_char_table_contents[256];

void initialize_external_input_routines() {
	if (input_sequence_handle == 0) {
		input_sequence_handle = new_input_sequence_plug_in_handle();
	}
}

int is_open() {
	return buffer != 0;
}

void external_dispose() {
printf("starting external_dispose\n");
	close_handle(input_sequence_handle);
	buffer = 0;
	buffersize = 0;
printf("ending external_dispose\n");
}

int current_field_length() {
	return current_field_length_value;
}

char* current_field() {
	int i;
	current_field_length_value = 0;
	for (i = current_index; i < buffersize && buffer[i] != field_separator &&
			buffer[i] != record_separator; ++i) {

		++current_field_length_value;
	}
	return &buffer[current_index];
}

char current_character() {
	return buffer[current_index++];
}

void advance_to_next_field_implementation() {
	while (buffer[current_index] != field_separator &&
			buffer[current_index] != record_separator &&
			current_index < buffersize) {
		++current_index;
	}
	if (current_index < buffersize &&
			buffer[current_index] == field_separator) {
		++current_index;
	}
}

void advance_to_next_record_implementation() {
	while (buffer[current_index] != record_separator &&
			current_index < buffersize) {
		++current_index;
	}
	if (current_index < buffersize &&
			buffer[current_index] == record_separator) {
		++current_index;
	}
}

int field_count_implementation() {
	int result = 0;
	if (buffer != 0 && buffersize > 0) {
		int i;
		result = 1;
		for (i = 0; i < buffersize; ++i) {
			if (buffer[i] = field_separator) {
				++result;
			}
			if (buffer[i] = record_separator) {
				break;
			}
		}
	}

	return result;
}

int readable_implementation() {
	return is_open() && ! after_last_record_implementation();
}

int after_last_record_implementation() {
/**!!!printf("after_last_record_implementation - ci, bufsz: %d, %d\n",
current_index, buffersize);*/
	return current_index == buffersize;
}

static void set_field_separator() {
	field_separator = ',';
	if (buffer != 0 && buffersize > 0) {
		int i;
		for (i = 0; i < buffersize && buffer[i] != record_separator; ++i) {
			if (fs_char_table[buffer[i]]) {
				field_separator = buffer[i];
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
		fs_char_table_contents[fschars[i]] = 1;
	}
	fs_char_table = fs_char_table_contents;
}

void start_implementation(char* symbol, int is_intraday) {
	if (input_sequence_handle == 0) {
		input_sequence_handle = new_input_sequence_plug_in_handle();
	}
	if (fs_char_table == 0) {
		initialize_fs_char_table();
	}
	/**!!!Probably need to check for input_sequence_plug_in being 0 and,
	 * if so, set error status. */
	buffer = tradable_data(input_sequence_handle, symbol,
		is_intraday, &buffersize);
	if (buffer == 0) {
		error_occurred = 1;
		error_msg = last_error(input_sequence_handle);
	}
	current_index = 0;
	set_field_separator();
printf("start_imp - bufsz: %d\n", buffersize);
}

char* available_symbols_buffer;

char* available_symbols() {
	return available_symbols_buffer;
}

int symbol_count_value;

int symbol_count() {
	return symbol_count_value;
}

int external_error() {
	return error_occurred;
}

char* last_external_error() {
printf("ler returning %s\n", error_msg);
	return error_msg;
}

void make_available_symbols() {
printf("starting make_av symb\n");
	error_occurred = 0;
printf("A\n");
	available_symbols_buffer = symbol_list(input_sequence_handle);
printf("B\n");
	if (available_symbols_buffer == 0) {
		error_occurred = 1;
		error_msg = last_error(input_sequence_handle);
	}
}

int intraday_data_available() {
/**!!!Stub */
	return 0;
}
