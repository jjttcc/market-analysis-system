indexing
	description: "Client socket connections to the MAS server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

deferred class CLIENT_CONNECTION inherit

	NETWORK_PROTOCOL

feature -- Access

	hostname: STRING
			-- Host name of the server

	port_number: INTEGER
			-- Port number of the server

feature -- Status report

	last_communication_succeeded: BOOLEAN
			-- Did the last communication with the server succeed?

	server_response: STRING
			-- Last response from the server

	error_report: STRING
			-- Report on last error if not `last_communication_succeeded'

	connected: BOOLEAN is
			-- Is Current connected to the server?
		do
			Result := socket /= Void and then
				socket.is_open_read and socket.is_open_write
		ensure
			definition: Result = (socket.is_open_read and socket.is_open_write)
		end

	socket_ok: BOOLEAN is
			-- Is the socket "OK"?
		do
			 Result := socket.socket_ok
		end

feature {NONE} -- Initialization

	make (host: STRING; port: INTEGER) is
			-- Set `hostname' and `port_number' to the specified values
			-- and test the connection.  If the test fails (likely because
			-- the address is invalid, the connection times out, or the
			-- server can't be reached), an exception is thrown.
		do
			hostname := host
			port_number := port
			server_response := ""
			-- Cause an exception to be thrown if host/port are invalid:
			create socket.make_client_by_port (port_number, hostname)
			if socket.socket_ok then
				last_communication_succeeded := True
				close
				socket := Void
			else
				error_report := Connection_failed_msg
			end
		ensure
			host_port_set: hostname = host and port_number = port
		rescue
			error_report := Invalid_address_msg
		end

	make_connected (host: STRING; port: INTEGER) is
			-- Set `hostname' and `port_number' to the specified values
			-- and establish a connection to the server.  If the connection
			-- fails (likely because the address is invalid, the connection
			-- times out, or the server can't be reached), an exception
			-- is thrown.
		do
			hostname := host
			port_number := port
			server_response := ""
			-- An exception to be thrown by this call if host/port
			-- are invalid:
			make_socket
			if socket.socket_ok then
				last_communication_succeeded := True
			else
				error_report := Connection_failed_msg
			end
		ensure
			host_port_set: hostname = host and port_number = port
			socket_exists_if_no_error: last_communication_succeeded implies
				socket /= Void
			connected_if_no_error: last_communication_succeeded implies
				connected
		rescue
			error_report := Invalid_address_msg
		end

	make_socket is
		require
			host_port_exist: hostname /= Void and port_number /= Void
		do
			create socket.make_client_by_port (port_number, hostname)
			if socket.socket_ok then
				socket.set_blocking
				socket.set_timeout (Timeout_seconds)
				socket.connect
			end
		ensure
			blocking: connected implies socket.is_blocking and socket.socket_ok
			socket_exists: connected implies socket /= Void
		end

feature {NONE} -- Implementation

	send_request (r: STRING; wait_for_response: BOOLEAN) is
			-- Send request `r' to the server and, if `wait_for_response',
			-- place the server's response into `server_response'.
		require
			r_exists: r /= Void
			socket_exists: socket /= Void
			connected: connected
		local
			s: STRING
		do
			last_communication_succeeded := False
			socket.put_string (r)
			if socket.socket_ok then
				if wait_for_response then
					create s.make (0)
					if socket.ready_for_reading then
						from
							socket.read_character
						until
							end_of_message (socket.last_character)
						loop
							s.extend (socket.last_character)
							socket.read_character
						end
						if not socket.socket_ok then
							error_report := last_socket_error
						else
							process_response (s)
						end
					else
						error_report :=
							"Timed out waiting for server response."
					end
				else
					last_communication_succeeded := True
				end
			else
				last_communication_succeeded := False
				error_report := last_socket_error
			end
		ensure
			still_connected_if_no_error:
				last_communication_succeeded implies connected
			server_response_exists_if_no_error:
				last_communication_succeeded implies server_response /= Void
		end

	send_one_time_request (r: STRING; wait_for_response: BOOLEAN) is
			-- Send `r' to the server as a one-time-per-connection request
			-- and, if `wait_for_response', place the server's response into
			-- `server_response'.
		require
			r_exists: r /= Void
		do
			last_communication_succeeded := False
			make_socket
			if connected then
				send_request (r, wait_for_response)
			else
				error_report := last_socket_error
			end
			close
		ensure
			not_connected: not connected
			server_response_exists_if_no_error:
				last_communication_succeeded implies server_response /= Void
		end

	process_response (s: STRING) is
			-- Process server response `s' - set `server_response' and
			-- `last_communication_succeeded' accordingly.
		require
			s_exists: s /= Void
		do
			-- Default to simply assign `s' to `server_response' and
			-- "succeed" - Redefine if needed.
			server_response := s
			last_communication_succeeded := True
		ensure
			server_response_set: server_response /= Void
		end

	close is
			-- Close the connection.
		do
			if socket /= Void and not socket.is_closed then
				socket.close
			end
		end

	last_socket_error: STRING is
		do
			Result := socket.error
			if Result = Void then
				Result := Connection_failed_msg
			end
		end

feature {NONE} -- Implementation - attributes

	socket: NETWORK_STREAM_SOCKET

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER is
			-- Number of seconds client will wait for server to respond
			-- before reporting a "timed-out" message
		deferred
		end

	end_of_message (c: CHARACTER): BOOLEAN is
			-- Does `c' indicate that the end of the data from the server
			-- has been reached?
		do
			Result := c = eom @ 1
		end

	Connection_failed_msg: STRING is "Connection to the server failed."

	Invalid_address_msg: STRING is "Invalid network address."

invariant

	server_response_exists_if_succeeded:
		last_communication_succeeded implies server_response /= Void
	error_report_exists_on_failure:
		not last_communication_succeeded implies error_report /= Void
	socket_exists_if_connected: connected implies socket /= Void

end
