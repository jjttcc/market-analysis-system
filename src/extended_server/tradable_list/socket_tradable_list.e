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

feature {SOCKET_LIST_BUILDER} -- Initialization

	make (the_symbols: LIST [STRING]; factory: TRADABLE_FACTORY;
			conn: INPUT_DATA_CONNECTION) is
		do
			parent_make (the_symbols, factory)
			connection := conn
--!!!!Temporary, for testing - in future it will be passed in.
--create {EXPERIMENTAL_INPUT_DATA_CONNECTION} connection.make
		end

feature {SOCKET_LIST_BUILDER} -- Access

	connection: INPUT_DATA_CONNECTION
			-- The "connection" to the data server

feature {SOCKET_LIST_BUILDER} -- Element change

	set_connection (arg: like connection) is
			-- Set `connection' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			connection := arg
		ensure
			connection_set: connection = arg and connection /= Void
		end

feature {NONE} -- Implementation

	initialize_input_medium is
		do
			connection.request_data (Current)
			if not connection.last_communication_succeeded then
				fatal_error := True
--!!!!Where/when should this error be reported?:
print ("Error occurred connecting to data supplier:%N" +
connection.error_report + "%N")
			end
			input_medium := connection.socket
		end

invariant

end
