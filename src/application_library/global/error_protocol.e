indexing
	description: "Protocol and related utilities for reportable errors"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
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

	Generic_error_code: INTEGER is 1

	Database_error_code: INTEGER is 2

	Internal_system_error_code: INTEGER is 3

	Initialization_error_code: INTEGER is 4

	Data_file_does_not_exist_error_code: INTEGER is 5

	Data_cache_directory_creation_failure_error_code: INTEGER is 6

	Database_error: STRING is
		do
			Result := errors @ Database_error_code
		end

	Generic_error: STRING is
		do
			Result := errors @ Generic_error_code
		end

	Internal_system_error: STRING is
		do
			Result := errors @ Internal_system_error_code
		end

	Initialization_error: STRING is
		do
			Result := errors @ Initialization_error_code
		end

	Data_file_does_not_exist_error: STRING is
		do
			Result := errors @ Data_file_does_not_exist_error_code
		end

	Data_cache_directory_creation_failure_error: STRING is
		do
			Result := errors @ Data_cache_directory_creation_failure_error_code
		end

	largest_error_code: INTEGER is
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
		once
			create Result.make (0)
			Result.extend ("Database error", Database_error_code)
			Result.extend ("Undetermined error", Generic_error_code)
			Result.extend ("Internal system error", Internal_system_error_code)
			Result.extend ("System initialization error",
				Initialization_error_code)
			Result.extend (concatenation (<<"Data file for ",
				token_start_delimiter, error_token, token_end_delimiter,
				" does not exist">>), Data_file_does_not_exist_error_code)
			Result.extend ("Failed to create data-cache directory",
				Data_cache_directory_creation_failure_error_code)
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
