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
			conn: EXPERIMENTAL_INPUT_SOCKET_CONNECTION
		do
			create conn
			create {INPUT_SOCKET} Result.make_client_by_port (
				target_socket_port_number, target_socket_hostname)
			conn.make_connected_with_socket (Result)
		end

	timeout_seconds: INTEGER is 10

feature {NONE} -- Implementation - constants
--!!!!Temporarily hard-cdoed for testing - needs to be configurable.

	target_socket_port_number: INTEGER is 39412

	target_socket_hostname: STRING is "localhost"

feature {NONE} -- Unused

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

invariant

end
