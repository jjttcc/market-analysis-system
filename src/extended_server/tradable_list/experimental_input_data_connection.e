indexing
	description:
		"Experimental/testing implementation of INPUT_DATA_CONNECTION"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class EXPERIMENTAL_INPUT_DATA_CONNECTION inherit

	INPUT_DATA_CONNECTION

create

	make

feature -- Initialization

	make is
		do
			last_communication_succeeded := True
			server_response := ""
		end

feature -- Basic operations

	connect_to_supplier is
			-- Create `socket' and use it to connect to the data supplier
			-- as the first step in querying for new data.
		do
			make_connected (target_socket_hostname, target_socket_port_number)
		end

feature {NONE} -- Implementation

	target_socket_port_number: INTEGER is 39412

	target_socket_hostname: STRING is "localhost"

invariant

end
