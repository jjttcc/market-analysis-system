indexing
	description:
		"Factory that parses an input file and creates an %
		%ATOMIC_MARKET_EVENT with the result"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ATOMIC_EVENT_FACTORY inherit

	MARKET_EVENT_FACTORY
		export
			{ANY} event_types
		redefine
			product
		end

creation

	make

feature -- Initialization

	make (infile: like input_file; fs: like field_separator) is
		require
			args_not_void: infile /= Void
			infile_readable: infile.exists and infile.is_open_read
			event_types_setup: event_types /= Void and event_types.count > 0
		do
			input_file := infile
			field_separator := fs
		ensure
			set: input_file = infile and field_separator = fs
		end

feature -- Access

	input_file: FILE
			-- File containing input data from which to create MARKET_EVENTs

	product: ATOMIC_MARKET_EVENT

feature -- Status setting

	set_field_separator (arg: CHARACTER) is
			-- Set field_separator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg and
									field_separator /= Void
		end

feature -- Basic operations

	execute is
			-- Scan input_file and create an ATOMIC_MARKET_EVENT from it.
			-- If a fatal error is encountered while scanning, an exception
			-- is thrown and error_occurred is set to true.
		local
			date_time: DATE_TIME
		do
			error_init
			scan_event_type
			skip_field_separator
			scan_date
			scan_time
			!!date_time.make_by_date_time (last_date, last_time)
			skip_field_separator
			scan_symbol
			!!product.make (current_event_type.name, last_symbol, date_time,
							current_event_type)
		end

feature {NONE} -- Implementation

	scan_symbol is
		do
			scan_field
			last_symbol := last_string
			if last_symbol = Void then
				last_error := concatenation (
					<<"Error occurred inputting market symbol field:",
					"  Empty field - from file ",
					input_file.name, " at character ", input_file.index,
					" - invalid input value: ", input_file.last_integer>>)
				error_occurred := true
				raise ("scan_symbol failed with empty field")
			end
		end

	last_symbol: STRING

	date_scanner: expanded DATE_TIME_SERVICES

	last_date: DATE
			-- Last date scanned (represented as number)

	last_time: TIME
			-- Last time scanned (represented as string)

	scan_date is
			-- Scan the date and set `last_date' to it.
		do
			input_file.read_integer
			last_date := date_scanner.date_from_number (input_file.last_integer)
			if last_date = Void then
				last_error := concatenation (
					<<"Error occurred inputting date from file ",
					input_file.name, " at character ", input_file.index,
					" - invalid input value: ", input_file.last_integer>>)
				error_occurred := true
				raise ("scan_date failed")
			end
		end

	scan_time is
			-- Scan the time and set `last_time' to it.
		do
			scan_field
			if not last_string.has ('.') then
				-- The string-time conversion routine requires the format
				-- "00:00:00.000", so append the missing part.
				last_string.append (".000")
			end
			last_time := date_scanner.time_from_string (last_string)
			if last_time = Void then
				last_error := concatenation (
					<<"Error occurred inputting time from file ",
					input_file.name, " at character ", input_file.index,
					" - invalid input value: ", last_string>>)
				error_occurred := true
				raise ("scan_time failed with invalid input")
			end
		end

	scan_field is
			-- Scan the current field and place the result into `last_string'.
		do
			if last_string = Void then
				!!last_string.make (12)
			end
			last_string.wipe_out
			from
				input_file.read_character
			until
				input_file.last_character = field_separator or
				input_file.last_character = '%N'
			loop
				last_string.extend (input_file.last_character)
				input_file.read_character
			end
			input_file.back
		end

	last_string: STRING
			-- Implementation variable made into an attribute for efficiency

end -- class ATOMIC_EVENT_FACTORY
