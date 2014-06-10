note
	description: "A TRADABLE_LIST that uses the EXTERNAL_INPUT_SEQUENCE"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXTERNAL_TRADABLE_LIST inherit

	TRADABLE_LIST
		rename
			make as tl_make
		export
			{NONE} tl_make
		redefine
			input_medium
		end

	EXCEPTIONS
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make (factory: TRADABLE_FACTORY)
		require
			not_void: factory /= Void
		do
			create input_medium.make
			if input_medium.error_occurred then
				fatal_error := True
				log_error (input_medium.error_string)
				raise (
					"Fatal error occurred initializing external data source")
			else
				tl_make (input_medium.symbols, factory)
			end
		end

feature -- Status report

	intraday_data_available: BOOLEAN
			-- Is intraday data available from the external source?
		do
			Result := input_medium.intraday_data_available
		end

feature {NONE} -- Implementation

	input_medium: EXTERNAL_INPUT_SEQUENCE

	initialize_input_medium
		local
		do
			if intraday then
				input_medium.set_intraday (True)
			else
				input_medium.set_intraday (False)
			end
			input_medium.set_symbol (current_symbol)
		end

invariant

	input_medium_set: input_medium /= Void

end -- class EXTERNAL_TRADABLE_LIST
