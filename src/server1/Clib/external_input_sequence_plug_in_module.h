#ifndef	EXTERNAL_INPUT_SEQUENCE_PLUG_IN_MODULE_H
#define	EXTERNAL_INPUT_SEQUENCE_PLUG_IN_MODULE_H

struct input_sequence_plug_in;

/* A new handle for access to the input-sequence-plug-in interface -
 * `paths' is a list of paths, separated by ':', in which to create temporary
 * files; each path must end with the directory separator character
 * (valid for the platform on which the program is running).  The first
 * path in which the needed input files (if any, according to the specific
 * plug-in implementation being used) are found will be used - for the
 * input files and any needed temporary files.  If the initialization fails,
 * 0 is returned.
 * Precondition: paths != 0
*/
struct input_sequence_plug_in* new_input_sequence_plug_in_handle(
	const char* paths);

/* Data for the tradable specified by `symbol' - intraday if `is_intraday',
 * otherwise, daily.  Returns 0 if an error occurs.
 * The format of the data is:
 * [To be specified]
 * `size' holds the size of the returned char array.
 * Precondition: handle != 0 && symbol != 0 && size != 0
 * Note: Caller is responsible for freeing the allocated memory at the
 * returned address.
*/
char* tradable_data(struct input_sequence_plug_in* handle, char* symbol,
	int is_intraday, int* size);

/* List of all symbols for which data is available, separated by newlines -
 * Returns 0 if an error occurs.
 * Precondition: handle != 0
 * Note: Caller is responsible for freeing the allocated memory at the
 * returned address.
*/
char* symbol_list(struct input_sequence_plug_in* handle);

/* Close the specified input sequence handle.
 * Precondition: handle != 0
*/
void close_handle(struct input_sequence_plug_in* handle);

/* Description of last error that occurred
 * Precondition: handle != 0
*/
char* last_error(struct input_sequence_plug_in* handle);

#endif	// EXTERNAL_INPUT_SEQUENCE_PLUG_IN_MODULE_H
