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
		redefine
			initlialized_socket
		end

create

	make

feature -- Initialization

	make is
		do
			last_communication_succeeded := True
			server_response := ""
		end

feature {NONE} -- Hook routine implementations

	connect_to_supplier is
			-- Create `socket' and use it to connect to the data supplier
			-- as the first step in querying for new data.
		do
			make_connected (target_socket_hostname, target_socket_port_number)
		end

	data_request: STRING is
		do
			Result := tradable_list.symbols.item + "%N"
		end

	initlialized_socket (port: INTEGER; host: STRING): like socket is
			-- A new socket initialized with `port' and `host'
		do
			create Result.make_client_by_port (port, host)
		end

feature {NONE} -- Implementation

	target_socket_port_number: INTEGER is 39414

	target_socket_hostname: STRING is "localhost"

invariant

end
