indexing
	description:
		"Factory that parses an input sequence and creates an %
		%ATOMIC_MARKET_EVENT with the result"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

	make (infile: like input; fs: like field_separator) is
		require
			args_not_void: infile /= Void
			event_types_setup: event_types /= Void and event_types.count > 0
		do
			input := infile
			field_separator := fs
		ensure
			set: input = infile and field_separator = fs
		end

feature -- Access

	product: ATOMIC_MARKET_EVENT

feature -- Status setting

	set_field_separator (arg: like field_separator) is
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
			-- Scan input and create an ATOMIC_MARKET_EVENT from it.
			-- If a fatal error is encountered while scanning, an exception
			-- is thrown and error_occurred is set to True.
		local
			date_time: DATE_TIME
			st: expanded SIGNAL_TYPES
		do
			error_init
			scan_event_type
			skip_field_separator
			scan_date
			scan_time
			create date_time.make_by_date_time (last_date, last_time)
			skip_field_separator
			scan_symbol
			create product.make (current_event_type.name, last_symbol,
				date_time, current_event_type, st.Buy_signal)
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
					input.name, " at character ", input.index,
					" - invalid input value: ", input.last_integer>>)
				error_occurred := True
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
			input.read_integer
			last_date := date_scanner.date_from_number (input.last_integer)
			if last_date = Void then
				last_error := concatenation (
					<<"Error occurred inputting date from file ",
					input.name, " at character ", input.index,
					" - invalid input value: ", input.last_integer>>)
				error_occurred := True
				raise ("scan_date failed")
			end
		end

	scan_time is
			-- Scan the time and set `last_time' to it - with the expected
			-- format: h:m:s.
		local
			hour, minute, second: INTEGER
		do
			input.read_integer
			hour := input.last_integer
			input.read_character
			if input.last_character /= ':' then
				last_error := concatenation (
					<<"Error occurred inputting time from file ",
					input.name, " at character ", input.index,
					" - invalid field separator for time: ",
					input.last_character>>)
				error_occurred := True
				raise ("scan_time failed with invalid input")
			else
				input.read_integer
				minute := input.last_integer
				input.read_character
				if input.last_character /= ':' then
					last_error := concatenation (
						<<"Error occurred inputting time from file ",
						input.name, " at character ", input.index,
						" - invalid field separator for time: ",
						input.last_character>>)
					error_occurred := True
					raise ("scan_time failed with invalid input")
				else
					input.read_integer
					second := input.last_integer
				end
			end
			if
				date_scanner.hour_valid (hour) and
				date_scanner.minute_valid (minute) and
				date_scanner.second_valid (second)
			then
				create last_time.make (hour, minute, second)
			else
				last_error := concatenation (
					<<"Error occurred inputting time from file ",
					input.name, " at character ", input.index,
					" - invalid time: ", hour, ":", minute, ":", second>>)
				error_occurred := True
				raise ("scan_time failed with invalid input")
			end
		end

	scan_field is
			-- Scan the current field and place the result into `last_string'.
		do
			if last_string = Void then
				create last_string.make (12)
			end
			last_string.wipe_out
			from
				input.read_character
			until
				input.last_character = field_separator or
				input.last_character = '%N'
			loop
				last_string.extend (input.last_character)
				input.read_character
			end
			input.back
		end

	last_string: STRING
			-- Implementation variable made into an attribute for efficiency

end -- class ATOMIC_EVENT_FACTORY
