indexing
	description:
		"Abstraction that determines the type of a MARKET_EVENT being read %
		%from an input sequence"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_EVENT_PARSER inherit

	FACTORY
		redefine
			product
		end

	EXCEPTIONS
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make (in_file: like input) is
		require
			not_void: in_file /= Void
		do
			create type_name.make (3)
			create last_error.make (0)
			input := in_file
		ensure
			set: input = in_file
		end

feature -- Access

	input: ITERABLE_INPUT_SEQUENCE
			-- File containing input data from which to parse MARKET_EVENTs

	last_error: STRING
			-- Information on error, if any, that occurred during the last
			-- parse

	error_occurred: BOOLEAN
			-- Did an error occur during the last call to execute?

	field_separator: CHARACTER
			-- Field separator for parsing/scanning

	product: MARKET_EVENT_FACTORY

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
			-- If an error occurs during parsing, an exception is raised.
		do
			last_error.wipe_out
			error_occurred := false
			read_type
			if type_name.is_equal (Atomic_market_event) then
				create {ATOMIC_EVENT_FACTORY} product.make (input,
					field_separator)
			elseif type_name.is_equal (Market_event_pair) then
				create {EVENT_PAIR_FACTORY} product.make (input,
					clone (Current), field_separator)
			else
				set_error
				-- Cannot fulfill the postcondition.
				raise (last_error)
			end
		end

feature {NONE} -- Implementation

	type_name: STRING
			-- Input string specifying type information

	read_type is
			-- Read the current characters in the input (which specify type).
		do
			type_name.wipe_out
			from
				input.read_character
			until
				input.last_character = field_separator or
				input.after
			loop
				type_name.extend (input.last_character)
				input.read_character
			end
		end

	set_error is
		require
			empty: last_error.empty
		do
			error_occurred := true
			if type_name.empty then
				last_error.append ("Empty type specification in input")
			else
				last_error.append ("Invalid type specification in input: ")
				last_error.append (type_name)
			end
		end

feature {NONE} -- Implementation

	Atomic, Pair: INTEGER is unique

	Atomic_market_event: STRING is "AME"

	Market_event_pair: STRING is "MEP"

invariant

	not_void: type_name /= Void and last_error /= Void and input /= Void

end -- class MARKET_EVENT_PARSER
