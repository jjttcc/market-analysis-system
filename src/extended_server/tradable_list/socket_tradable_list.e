indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SOCKET_TRADABLE_LIST inherit

	INPUT_MEDIUM_BASED_TRADABLE_LIST
		rename
			make as parent_make
		end

create

	make

feature -- Initialization

	make (the_symbols: LIST [STRING]; factory: TRADABLE_FACTORY) is
		do
			parent_make (the_symbols, factory)
		end

feature {NONE} -- Implementation

	initialized_input_medium: INPUT_SOCKET is
		local
			connection: EXPERIMENTAL_INPUT_DATA_CONNECTION
		do
			create connection.connect_to_supplier
			if not connection.last_communication_succeeded then
				fatal_error := True
--!!!!Where/when should this error be reported?:
print ("Error occurred connecting to data supplier:%N" +
connection.error_report + "%N")
			end
		end

invariant

end
