indexing
	description: "A TRADABLE_LIST that uses the EXTERNAL_INPUT_SEQUENCE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTERNAL_TRADABLE_LIST inherit

	TRADABLE_LIST
		rename
			make as tl_make
		export
			{NONE} tl_make
		redefine
			setup_input_medium
		end

	EXCEPTIONS
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make (factory: TRADABLE_FACTORY) is
		require
			not_void: factory /= Void
		do
			create input_sequence.make
			if input_sequence.error_occurred then
				fatal_error := true
				log_error (input_sequence.error_string)
				raise (
					"Fatal error occurred initializing external data source")
			else
				tl_make (input_sequence.symbols, factory)
			end
		end

feature -- Status report

	intraday: BOOLEAN
			-- Do the tradables in this list contain intraday data?

	intraday_data_available: BOOLEAN is
			-- Is intraday data available from the external source?
		do
			Result := input_sequence.intraday_data_available
		end

feature -- Status setting

	set_intraday (arg: BOOLEAN) is
			-- Set intraday to `arg'.
		do
			intraday := arg
		ensure
			intraday_set: intraday = arg
		end

feature {NONE} -- Implementation

	input_sequence: EXTERNAL_INPUT_SEQUENCE

	setup_input_medium is
		local
		do
			if intraday then
				input_sequence.set_intraday (true)
			else
				input_sequence.set_intraday (false)
			end
			input_sequence.set_symbol (current_symbol)
			tradable_factory.set_input (input_sequence)
		end

invariant

	input_sequence_set: input_sequence /= Void

end -- class EXTERNAL_TRADABLE_LIST
