indexing
	description: "An abstraction for a derivative instrument, which has %
		%an open interest field, such as futures contracts for a commodity %
		%or options contracts for a stock or stock index";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class DERIVATIVE_INSTRUMENT inherit

	TRADABLE [OPEN_INTEREST_TUPLE]
		redefine
			symbol, make_ctf, short_description, finish_loading
		end

creation

	make

feature {NONE} -- Initialization

	make (sym: STRING; info: DERIVATIVE_DATA) is
		require
			not_void: sym /= Void
			symbol_not_empty: not sym.empty
		do
			symbol := sym
			tradable_initialize
			information := info
		ensure
			symbol_set: symbol = sym
			info_set: information = info
		end

feature -- Access

	symbol: STRING

	name: STRING is
		do
			if cached_name = Void then
				if information /= Void then
					information.set_symbol (symbol)
					cached_name := information.name
				else
					cached_name := symbol
				end
			end
			Result := cached_name
		end

	short_description: STRING is "Derivative instrument"

feature -- Status report

	has_open_interest: BOOLEAN is true

feature -- Basic operations

	finish_loading is
		do
--!!!Remove (default to ancestor version) if no other work is needed.
			Precursor
		end

feature {NONE} -- Implementation

	make_ctf: COMPOSITE_TUPLE_FACTORY is
		once
			create {COMPOSITE_OI_TUPLE_FACTORY} Result
		end

	information: DERIVATIVE_DATA

	cached_name: STRING

invariant


end -- class DERIVATIVE_INSTRUMENT
