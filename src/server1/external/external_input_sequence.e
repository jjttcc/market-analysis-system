indexing
	description: "An input record sequence that relies on an external C %
		%implementation"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTERNAL_INPUT_SEQUENCE inherit

	INPUT_RECORD_SEQUENCE

	MEMORY
		export
			{NONE} all
		redefine
			dispose
		end

	EXCEPTIONS
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		local
			c_string: ANY
		do
			lock_external
			c_string := working_directories.to_c
			external_handle := initialize_external_input_routines ($c_string)
			if initialization_error then
				last_exception_status.set_fatal (true)
				raise (concatenation (<<"Fatal error occurred initializing ",
					"external data source:%N", string_from_pointer (
					initialization_error_reason)>>))
			end
			unlock_external
			create field.make (0)
			initialize_symbols
		ensure
			field_set: not error_occurred implies field /= Void
			symbols_set: not error_occurred implies symbols /= Void
			handle_set: external_handle /= Void
		end

feature -- Access

	last_double: DOUBLE

	last_real: REAL

	last_integer: INTEGER

	last_character: CHARACTER

	last_string: STRING

	last_date: DATE

	name: STRING is "external input sequence"

	field_index: INTEGER

	record_index: INTEGER

	field_count: INTEGER is
		do
			Result := field_count_implementation (external_handle)
		end

	symbol: STRING
			-- Current symbol for which data is to be obtained

	symbols: LIST [STRING]
			-- The symbol of each tradable available to this input sequence

	intraday_data_available: BOOLEAN is
			-- Is a source of intraday data available?
		do
			Result := intraday_data_available_implementation (external_handle)
		end

feature -- Status report

	last_error_fatal: BOOLEAN

	is_open: BOOLEAN is
			-- Is the input sequence open for use?
		do
			Result := is_open_implementation (external_handle)
		end

	readable: BOOLEAN is
		do
			Result := readable_implementation (external_handle)
		end

	after_last_record: BOOLEAN is
		do
			Result := after_last_record_implementation (external_handle)
		end

	intraday: BOOLEAN
			-- Is the data to be obtained for the current symbol intra-day
			-- data?

feature -- Status setting

	set_symbol (arg: STRING) is
			-- Set symbol to `arg'.
		require
			arg_not_void: arg /= Void
		local
			sym: ANY
		do
			symbol := arg
			sym := symbol.to_c
			retrieve_data (external_handle, $sym, intraday)
			if external_error (external_handle) then
				set_error_message (concatenation  (<<"Error occurred reading %
					%from external data source for ", symbol, ".">>),
					true, false)
			end
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_intraday (arg: BOOLEAN) is
			-- Set intraday to `arg'.
		require
			intraday_rule: arg implies intraday_data_available
		do
			intraday := arg
		ensure
			intraday_set: intraday = arg
		end

feature -- Cursor movement

	start is
		do
			start_implementation (external_handle)
			if external_error (external_handle) then
				set_error_message (concatenation  (<<"Error occurred reading %
					%from external data source for ", symbol, ".">>),
					true, false)
			end
			field_index := 1
			record_index := 1
		end

	advance_to_next_field is
		do
			advance_to_next_field_implementation (external_handle)
			if external_error (external_handle) then
				set_error_message (concatenation  (<<"Error occurred reading %
					%from external data source for ", symbol, ".">>),
					true, false)
			end
			field_index := field_index + 1
		end

	advance_to_next_record is
		do
			advance_to_next_record_implementation (external_handle)
			if external_error (external_handle) then
				set_error_message (concatenation  (<<"Error occurred reading %
					%from external data source for ", symbol, ".">>),
					true, false)
			end
			record_index := record_index + 1
			field_index := 1
		end

	discard_current_record is
		do
			advance_to_next_record
		end

feature -- Input

	read_integer is
		do
			read_string
			if not error_occurred then
				if last_string.is_integer then
					last_integer := last_string.to_integer
				else
					error_occurred := true
					last_error_fatal := true
					error_string := "Error reading integer value"
					if external_error (external_handle) then
						error_string := concatenation (<<error_string, ":%N",
							string_from_pointer (
								last_external_error(external_handle))>>)
					end
					last_exception_status.set_fatal (false)
					raise (error_string)
				end
			end
		end

	read_character is
			-- Read the current character in the current field and advance
			-- to the next character.
		do
			error_occurred := false
			last_character := current_character (external_handle)
			if external_error (external_handle) then
				set_error_message (concatenation  (<<"Error occurred reading %
					%from external data source for ", symbol, ".">>),
					true, false)
			end
		end

	read_string is
			-- Read the current field as a string.
		local
			string: STRING
		do
			error_occurred := false
			last_error_fatal := false
			string := current_field_as_string
			if string /= Void then
				last_string := string
			else
				error_occurred := true
				last_error_fatal := true
				error_string := "Error reading string value"
				if external_error (external_handle) then
					error_string := concatenation (<<error_string, ": ",
						string_from_pointer (
							last_external_error(external_handle))>>)
				end
				last_exception_status.set_fatal (false)
				raise (error_string)
			end
		ensure then
			last_string_not_void_if_no_error:
				not error_occurred implies last_string /= Void
		end

	read_date is
			-- Read the current field as a date.
		do
			-- @@Stub - currently not used.
		end

	read_double is
		do
			read_string
			if not error_occurred then
				if last_string.is_double then
					last_double := last_string.to_double
				else
					error_occurred := true
					last_error_fatal := true
					error_string := "Error reading double value"
					if external_error (external_handle) then
						error_string := concatenation (<<error_string, ": ",
							string_from_pointer (
								last_external_error(external_handle))>>)
					end
					last_exception_status.set_fatal (false)
					raise (error_string)
				end
			end
		end

	read_real is
		do
			read_string
			if not error_occurred then
				if last_string.is_real then
					last_real := last_string.to_real
				else
					error_occurred := true
					last_error_fatal := true
					error_string := "Error reading real value"
					if external_error (external_handle) then
						error_string := concatenation (<<error_string, ": ",
							string_from_pointer (
								last_external_error(external_handle))>>)
					end
					last_exception_status.set_fatal (false)
					raise (error_string)
				end
			end
		end

feature {NONE} -- Implementation

	path_separator: STRING is ""

	working_directories: STRING is
			-- The working directories for external data retrieval, each
			-- ending with `directory_separator' and separated by
			-- `path_separator'.  The following directories are included
			-- in the listed order if the directory exists and is writable:
			-- The `app_directory' and the current directory.
		local
			dir: DIRECTORY
			env: expanded APP_ENVIRONMENT_VARIABLE_NAMES
		do
			if app_directory /= Void then
				create dir.make (app_directory)
				if dir.exists and dir.is_writable then
					Result := clone (app_directory)
					Result.extend (directory_separator)
				end
			end
			create dir.make (current_working_directory)
			if dir.is_writable then
				if Result = Void then
					Result := clone (current_working_directory)
				else
					Result.append (concatenation(<<path_separator,
						clone (current_working_directory)>>))
				end
				Result.extend (directory_separator)
			end
			if Result = Void then
				if app_directory = Void then
					last_exception_status.set_fatal (true)
					raise (concatenation (<<"Current directory (",
						current_working_directory, ") is not writable and ",
						env.application_directory_name, " is not set - %
						%external data source retrieval cannot be used.">>))
				else
					last_exception_status.set_fatal (true)
					raise (concatenation (<<"Neither the current directory ",
						"(", current_working_directory, ") nor the MAS %
						%application directory (", app_directory,
						") is writable - external data source %
						%retrieval cannot be used.">>))
				end
			end
		ensure
			not_void: Result /= Void
		end

	lock_external is
			-- When multi-threading is in place, this will lock the use
			-- of the external routines to prevent race conditions.
		do
		end

	unlock_external is
			-- When multi-threading is in place, this will unlock the use
			-- of the external routines.
		do
		end

	dispose is
		do
			external_dispose (external_handle)
			Precursor
		end

	current_field_as_string: STRING is
			-- A string created from `current_field'
		do
			field.from_c_substring (current_field (external_handle), 1,
				current_field_length (external_handle))
			Result := field
		end

	initialize_symbols is
		local
			su: expanded STRING_UTILITIES
		do
			make_available_symbols (external_handle)
			if external_error (external_handle) then
				set_error_message ("Error occurred obtaining symbol list",
					true, true)
			else
				su.set_target (string_from_pointer (
					available_symbols (external_handle)))
				symbols := su.tokens ("%N")
			end
		end

	string_from_pointer (p: POINTER): STRING is
		do
			create Result.make (0)
			Result.from_c (p)
		end

	field: STRING

	external_handle: POINTER
			-- Handle for external input sequence data used by
			-- external routines

	set_error_message (msg: STRING; exc: BOOLEAN; fatal: BOOLEAN) is
			-- Set `error_string' from current error message from
			-- external module, prepended with `msg'.  If `exc',
			-- raise an exception with the resulting message.
		require
			msg_valid: msg /= Void
		local
			s: STRING
		do
			error_occurred := true
			last_error_fatal := true
			s := string_from_pointer (last_external_error (external_handle))
			if not msg.is_empty then
				if not s.is_empty then
					error_string := concatenation (<<msg, ":%N", s>>)
				else
					error_string := msg
				end
			else
				error_string := s
			end
			if exc then
				last_exception_status.set_fatal (fatal)
				last_exception_status.set_description (error_string)
				raise (error_string)
			end
		ensure
			error: error_occurred and last_error_fatal
			valid: error_string /= Void
		end

feature {NONE} -- Implementation - externals

	is_open_implementation (handle: POINTER): BOOLEAN is
			-- Is the input sequence open for use?
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	current_field (handle: POINTER): POINTER is
			-- Current field value as a non-null-terminated C string
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	current_field_length (handle: POINTER): INTEGER is
			-- Length of `current_field'
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	current_character (handle: POINTER): CHARACTER is
			-- The character at the current "cursor" location - the "cursor"
			-- is advanced to the next character.
		require
			readable: readable
			handle_valid: handle /= Void
		external
			"C"
		end

	advance_to_next_field_implementation (handle: POINTER) is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	advance_to_next_record_implementation (handle: POINTER) is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	field_count_implementation (handle: POINTER): INTEGER is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	readable_implementation (handle: POINTER): BOOLEAN is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	after_last_record_implementation (handle: POINTER): BOOLEAN is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	retrieve_data (handle: POINTER; sym: POINTER; intrad: BOOLEAN) is
		require
			args_valid: handle /= Void and sym /= Void
		external
			"C"
		end

	start_implementation (handle: POINTER) is
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	make_available_symbols (handle: POINTER) is
			-- Create `available_symbols'.
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	available_symbols (handle: POINTER): POINTER is
			-- All available symbols, separated by newlines
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	initialize_external_input_routines (working_dirs: POINTER): POINTER is
			-- Perform any needed initialization by the external routines
			-- and return a handle for use by the other external routines.
			-- If the initialization failed, `initialization_error' will
			-- be true and `initialization_error_reason' will contain the
			-- reason for the failure; otherwise, `initialization_error'
			-- will be false.
		require
			working_dir_not_void: working_dirs /= Void
			-- working_dir_valid: The last character of `working_dir' is
			-- directory_separator.
		external
			"C"
		end

	external_error (handle: POINTER): BOOLEAN is
			-- Did an error occur in the last external "C" call?
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	last_external_error (handle: POINTER): POINTER is
			-- The last error that occurred in an external "C" call
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	external_dispose (handle: POINTER) is
			-- Perform any needed cleanup operations for garbage collection.
		require
			open: is_open
			handle_valid: handle /= Void
		external
			"C"
		ensure
			closed: not is_open
		end

	intraday_data_available_implementation (handle: POINTER): BOOLEAN is
			-- Is a source of intraday data available?
		require
			handle_valid: handle /= Void
		external
			"C"
		end

	initialization_error: BOOLEAN is
			-- Did an error occur in `initialize_external_input_routines'?
		external
			"C"
		end

	initialization_error_reason: POINTER is
			-- Reason for the last `initialization_error'?
		external
			"C"
		end

invariant

	intraday_data_rule: intraday implies intraday_data_available

end -- class EXTERNAL_INPUT_SEQUENCE
