indexing
	description: "An input record sequence that relies on an external C %
		%implementation"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class EXTERNAL_INPUT_SEQUENCE inherit

	INPUT_RECORD_SEQUENCE

	MEMORY
		export
			{NONE} all
		redefine
			dispose
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			external_handle := initialize_external_input_routines
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
		do
			symbol := arg
		ensure
			symbol_set: symbol = arg and symbol /= Void
		end

	set_intraday (arg: BOOLEAN) is
			-- Set intraday to `arg'.
		require
			arg_not_void: arg /= Void
			intraday_rule: arg implies intraday_data_available
		do
print ("arg: "); print (arg); print ("%N")
print ("intra avail: "); print (intraday_data_available); print ("%N")
print ("arg -> intra avail: ");
print (arg implies intraday_data_available); print ("%N")
			intraday := arg
		ensure
			intraday_set: intraday = arg and intraday /= Void
		end

feature -- Cursor movement

	start is
		do
			start_implementation (external_handle, symbol, intraday)
			field_index := 1
			record_index := 1
		end

	advance_to_next_field is
		do
			advance_to_next_field_implementation (external_handle)
			field_index := field_index + 1
		end

	advance_to_next_record is
		do
			advance_to_next_record_implementation (external_handle)
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
					error_string := "Error in reading integer value"
					if external_error (external_handle) then
						error_string := concatenation (<<error_string, ": ",
							string_from_pointer (
								last_external_error(external_handle))>>)
					end
				end
			end
		end

	read_character is
			-- Read the current character in the current field and advance
			-- to the next character.
		do
			last_character := current_character (external_handle)
			-- !!!Error handling?
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
				error_string :=
					"Error in read_string in EXTERNAL_INPUT_SEQUENCE ... !!!"
			end
		ensure then
			last_string_not_void_if_no_error:
				not error_occurred implies last_string /= Void
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
					error_string := "Error in read_double in %
						%EXTERNAL_INPUT_SEQUENCE ... !!!"
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
					error_string := "Error in read_real in %
						%EXTERNAL_INPUT_SEQUENCE ... !!!"
				end
			end
		end

feature {NONE} -- Implementation

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
			i: INTEGER
			su: STRING_UTILITIES
		do
			make_available_symbols (external_handle)
			if external_error (external_handle) then
				error_occurred := true
				error_string := concatenation (<<"Error occurred obtaining %
					%symbol list: ",
					string_from_pointer (
						last_external_error(external_handle))>>)
			else
				create su.make (string_from_pointer (
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
			-- Handle for external input sequence data used by external
			-- routines

feature {NONE} -- Implementation - externals

	is_open_implementation (handle: POINTER): BOOLEAN is
			-- Is the input sequence open for use?
		external
			"C"
		end

	current_field (handle: POINTER): POINTER is
			-- Current field value as a non-null-terminated C string
		external
			"C"
		end

	current_field_length (handle: POINTER): INTEGER is
			-- Length of `current_field'
		external
			"C"
		end

	current_character (handle: POINTER): CHARACTER is
			-- The character at the current "cursor" location - the "cursor"
			-- is advanced to the next character.
		require
			readable: readable
		external
			"C"
		end

	advance_to_next_field_implementation (handle: POINTER) is
		external
			"C"
		end

	advance_to_next_record_implementation (handle: POINTER) is
		external
			"C"
		end

	field_count_implementation (handle: POINTER): INTEGER is
		external
			"C"
		end

	readable_implementation (handle: POINTER): BOOLEAN is
		external
			"C"
		end

	after_last_record_implementation (handle: POINTER): BOOLEAN is
		external
			"C"
		end

	start_implementation (handle: POINTER; sym: STRING; intrad: BOOLEAN) is
		external
			"C"
		end

	make_available_symbols (handle: POINTER) is
			-- Create `available_symbols'.
		external
			"C"
		end

	available_symbols (handle: POINTER): POINTER is
			-- All available symbols, separated by newlines
		external
			"C"
		end

	initialize_external_input_routines: POINTER is
			-- Perform any needed initialization by the external routines
		external
			"C"
		end

	external_error (handle: POINTER): BOOLEAN is
			-- Did an error occur in the last external "C" call?
		external
			"C"
		end

	last_external_error (handle: POINTER): POINTER is
			-- The last error that occurred in an external "C" call
		external
			"C"
		end

	external_dispose (handle: POINTER) is
			-- Perform any needed cleanup operations for garbage collection.
		require
			open: is_open
		external
			"C"
		ensure
			closed: not is_open
		end

	intraday_data_available_implementation (handle: POINTER): BOOLEAN is
			-- Is a source of intraday data available?
		external
			"C"
		end

invariant

	intraday_data_rule: intraday implies intraday_data_available

end -- class EXTERNAL_INPUT_SEQUENCE
