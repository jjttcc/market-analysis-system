indexing
	description:
		"Root class for retrieval of tradable data via an HTTP GET command"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

--!!!!Remember to rename the file to match the new name.
class HTTP_DATA_RETRIEVER inherit

	HTTP_DATA_RETRIEVAL

	ARGUMENTS
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make is
		do
			initialize
			initialize_symbols
			execute
		end

	initialize_symbols is
		local
			i: INTEGER
		do
			if argument_count >= 1 then
				create {LINKED_LIST [STRING]} symbols.make
				from i := 1 until i = argument_count + 1 loop
					symbols.extend (argument (i))
					i := i + 1
				end
			else
				symbols := symbols_from_file
			end
		end

feature {NONE} -- Implementation

	timing_needed: BOOLEAN is True

	symbols: LIST [STRING]
			-- The symbols for which data are to be retrieved

--!!!!!Add exception handling
	execute is
			-- For each symbol, s, in `symbols', if data for s needs
			-- to be retrieved, retrieve them.
		do
			from
				symbols.start
			until
				symbols.exhausted
			loop
				parameters.set_symbol (symbols.item)
				if data_retrieval_needed then
					retrieve_data
				end
				symbols.forth
			end
			if timing_needed then print (timing_information) end
		end

end
