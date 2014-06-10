note
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
			initialized_socket, prepare_for_socket_connection
		end

create

	make

feature -- Initialization

	make (portnum: INTEGER)
		do
			last_communication_succeeded := True
			server_response := ""
			target_socket_port_number := portnum
		end

feature {NONE} -- Hook routine implementations

	connect_to_supplier
			-- Create `socket' and use it to connect to the data supplier
			-- as the first step in querying for new data.
		do
			make_connected (target_socket_hostname, target_socket_port_number)
		end

	initialized_socket (port: INTEGER; host: STRING): like socket
			-- A new socket initialized with `port' and `host'
		do
			create Result.make_client_by_port (port, host)
		end

	prepare_for_socket_connection
		do
--			socket.set_linger_on (2000)
--			socket.set_delay
--			socket.set_timeout (2000)
--			socket.set_non_blocking
		end

feature {NONE} -- Implementation

	target_socket_port_number: INTEGER

	target_socket_hostname: STRING = "localhost"

invariant

end
