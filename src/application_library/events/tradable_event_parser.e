note
	description:
		"Abstraction that determines the type of a TRADABLE_EVENT being read %
		%from an input sequence"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_EVENT_PARSER inherit

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

	make (in_file: like input)
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
			-- File containing input data from which to parse TRADABLE_EVENTs

	last_error: STRING
			-- Information on error, if any, that occurred during the last
			-- parse

	error_occurred: BOOLEAN
			-- Did an error occur during the last call to execute?

	field_separator: CHARACTER
			-- Field separator for parsing/scanning

	product: TRADABLE_EVENT_FACTORY

feature -- Status setting

	set_field_separator (arg: CHARACTER)
			-- Set field_separator to `arg'.
		do
			field_separator := arg
		ensure
			field_separator_set: field_separator = arg
		end

feature -- Basic operations

	execute
			-- If an error occurs during parsing, an exception is raised.
		do
			last_error.wipe_out
			error_occurred := False
			read_type
			if type_name.is_equal (atomic_tradable_event) then
				create {ATOMIC_EVENT_FACTORY} product.make (input,
					field_separator)
			elseif type_name.is_equal (tradable_event_pair) then
				create {EVENT_PAIR_FACTORY} product.make (input,
					Current.twin, field_separator)
			else
				set_error
				-- Cannot fulfill the postcondition.
				raise (last_error)
			end
		end

feature {NONE} -- Implementation

	type_name: STRING
			-- Input string specifying type information

	read_type
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

	set_error
		require
			empty: last_error.is_empty
		do
			error_occurred := True
			if type_name.is_empty then
				last_error.append ("Empty type specification in input")
			else
				last_error.append ("Invalid type specification in input: ")
				last_error.append (type_name)
			end
		end

feature {NONE} -- Implementation

	atomic, pair: INTEGER = unique

	atomic_tradable_event: STRING = "ATE"
	--!!!!!!!Check re. dependency - used to be:
	--Atomic_market_event: STRING = "AME"

	tradable_event_pair: STRING = "TEP"
	--!!!!!!!Check re. dependency - used to be:
	-- Market_event_pair: STRING = "MEP"

invariant

	not_void: type_name /= Void and last_error /= Void and input /= Void

end -- class TRADABLE_EVENT_PARSER
