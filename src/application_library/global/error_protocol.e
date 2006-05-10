indexing
	description: "Protocol and related utilities for reportable errors"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	ERROR_PROTOCOL

inherit

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Access

	generic_error_code: INTEGER is 1

	database_error_code: INTEGER is 2

	internal_system_error_code: INTEGER is 3

	initialization_error_code: INTEGER is 4

	data_file_does_not_exist_error_code: INTEGER is 5

	data_cache_directory_creation_failure_error_code: INTEGER is 6

	database_error: STRING is
		do
			Result := errors @ database_error_code
		end

	generic_error: STRING is
		do
			Result := errors @ generic_error_code
		end

	internal_system_error: STRING is
		do
			Result := errors @ internal_system_error_code
		end

	initialization_error: STRING is
		do
			Result := errors @ initialization_error_code
		end

	data_file_does_not_exist_error: STRING is
		do
			Result := errors @ data_file_does_not_exist_error_code
		end

	data_cache_directory_creation_failure_error: STRING is
		do
			Result := errors @ data_cache_directory_creation_failure_error_code
		end

	largest_error_code: INTEGER is
		indexing
			once_status: global
		local
			keys: ARRAY [INTEGER]
			i: INTEGER
		once
			Result := -1
			keys := errors.current_keys
			from i := 1 until i = keys.count + 1 loop
				if keys @ i > Result then Result := keys @ i end
				i := i + 1
			end
		end

feature -- Access

	errors: HASH_TABLE [STRING, INTEGER] is
			-- All error descriptions
		indexing
			once_status: global
		once
			create Result.make (0)
			Result.extend ("Database error", database_error_code)
			Result.extend ("Undetermined error", generic_error_code)
			Result.extend ("Internal system error", internal_system_error_code)
			Result.extend ("System initialization error",
				initialization_error_code)
			Result.extend (concatenation (<<"Data file for ",
				token_start_delimiter, error_token, token_end_delimiter,
				" does not exist">>), data_file_does_not_exist_error_code)
			Result.extend ("Failed to create data-cache directory",
				data_cache_directory_creation_failure_error_code)
		end

feature -- Constants

	error_token: STRING is "?"
			-- Token to be replaced in configurable error messages

feature -- Basic operations

	log_error_with_token (emsg, new: STRING) is
			-- Log `emsg' with the delimited `error_token' replaced by `new'.
		local
			gu: expanded GENERAL_UTILITIES
		do
			gu.replace_token_all (emsg, error_token, new,
				token_start_delimiter, token_end_delimiter)
			gu.log_error (emsg + ".%N")
		end

end
