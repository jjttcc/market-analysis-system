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
		redefine
			initialize_symbols
		end

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
			execute
		end

	initialize_symbols is
		local
			i: INTEGER
		do
			if argument_count >= 1 then
				create symbols.make (argument_count)
				from i := 1 until i = argument_count + 1 loop
					symbols.extend (argument (i))
					i := i + 1
				end
			else
				Precursor
			end
		end

feature {NONE} -- Implementation

	timing_needed: BOOLEAN is True

end
