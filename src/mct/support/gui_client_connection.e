indexing
	description: "Client socket connection to the server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License to be determined"

class CLIENT_CONNECTION inherit

	GUI_NETWORK_PROTOCOL

creation

	make

feature -- Access

	hostname: STRING
			-- Host name of the server

	port_number: INTEGER
			-- Port number of the server

	indicators: LIST [STRING]
			-- Indicator list received from the server as the result of
			-- an indicator request

feature -- Status report

	last_communication_succeeded: BOOLEAN
			-- Did the last communication with the server succeed?

	server_response: STRING
			-- Last response from the server

	error_report: STRING
			-- Report on last error if not `last_communication_succeeded'

	logged_in: BOOLEAN
			-- Is Current logged in to the server?

feature -- Basic operations

	ping_server is
			-- "Ping" the server by attempting to log in and log back out.
		require
			not_logged_in: not logged_in
		do
			login
			if logged_in then
				logout
			end
		ensure
			not_logged_in: not logged_in
		end

	login is
			-- Log in to the server.
		require
			not_logged_in: not logged_in
		do
			send_request (Login_request_msg, True)
			if last_communication_succeeded then
				if server_response.is_integer then
					session_key := server_response.to_integer
print ("server gave us a session key of: " + session_key.out + ".%N")
				else
					last_communication_succeeded := False
					error_report := "Invalid login response received %
						%from the server: " + server_response
				end
			end
			logged_in := last_communication_succeeded
		ensure
			not_connected: not connected
			logged_in_on_success:
				last_communication_succeeded = logged_in
		end

	logout is
			-- Log out from the server.
		require
			logged_in: logged_in
		do
			send_request (Logout_request_msg, False)
			logged_in := False
		ensure
			not_connected: not connected
			not_logged_in: not logged_in
		end

	request_indicators is
			-- Request list of all available indicators from the server.
		require
			logged_in: logged_in
		local
			su: expanded STRING_UTILITIES
		do
			send_request (All_indicators_request_msg, True)
			if last_communication_succeeded then
				su.set_target (server_response)
				indicators := su.tokens (Message_record_separator)
			end
		ensure
			not_connected: not connected
			indicators_set_on_success:
				last_communication_succeeded implies indicators /= Void
			still_logged_in: logged_in
		end

feature {NONE} -- Initialization

	make (host: STRING; port: INTEGER) is
			-- Set `hostname' and `port_number' to the specified values
			-- and test the connection.  If the test fails (likely because
			-- the address is invalid or can't be reached), an exception
			-- is thrown.
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
				error_report := Connection_creation_failed_msg
			end
		ensure
			host_port_set: hostname = host and port_number = port
		rescue
			error_report := Invalid_address_msg
		end

	make_socket is
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
		local
			s: STRING
		do
			last_communication_succeeded := False
			make_socket
			if connected then
				socket.put_string (r)
				if socket.socket_ok then
					if wait_for_response then
						create s.make (0)
						if socket.ready_for_reading then
							from
								if socket.readable then
									socket.read_character
								end
							until
								not socket.readable or
								socket.last_character = eom @ 1
							loop
								s.extend (socket.last_character)
								socket.read_character
							end
							if not socket.socket_ok then
								error_report := last_socket_error
							else
								print ("The server returned '" + s + "'.%N")
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
			else
				error_report := last_socket_error
			end
			close
		ensure
			not_connected: not connected
		end

	process_response (s: STRING) is
			-- Process server response `s' - set `server_response' and
			-- `last_communication_succeeded' accordingly.
		local
			su: expanded STRING_UTILITIES
			l: LIST [STRING]
		do
			su.set_target (s)
			l := su.tokens (Message_field_separator)
print ("pr - server returned " + l.count.out + " fields:%N'" + s + "'%N")
			process_error (l, s)
			if last_communication_succeeded then
				server_response := l @ 2
			end
		end

	process_error (l: LIST [STRING]; msg: STRING) is
			-- Process any errors in the server response, `l'.  If there
			-- are errors, update `last_communication_succeeded' and
			-- error_report accordingly.  (`msg' is the entire message
			-- string sent by the server.)
		require
			args_exist: l /= Void and msg /= Void
		do
			last_communication_succeeded := False
			if l.is_empty then
				error_report := "Server result was empty."
			elseif not l.i_th (1).is_integer then
				error_report := "Server result was invalid: " + msg + "."
			elseif l.i_th (1).to_integer /= OK then
				error_report := "Server returned error status"
				if l.count > 1 then
					error_report.append (": " + l @ 2)
				end
			else
				last_communication_succeeded := True
			end
		end

	close is
			-- Close the connection.
		require
			socket_exists: socket /= Void
		do
			if not socket.is_closed then
				socket.close
			end
		end

	connected: BOOLEAN is
			-- Is Current connected to the server?
		do
			Result := socket /= Void and then
				socket.is_open_read and socket.is_open_write
		ensure
			definition: Result = (socket.is_open_read and socket.is_open_write)
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

	session_key: INTEGER

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER is 10
			-- Number of seconds client will wait for server to respond
			-- before reporting a "timed-out" message

	Login_request_msg: STRING is
			-- Login request to the server
		once
			Result := Login_request.out + Message_field_separator + "0" +
				Message_field_separator + eom
		end

	Logout_request_msg: STRING is
			-- Logout request to the server
		do
			Result := Logout_request.out + Message_field_separator +
				session_key.out + Message_field_separator + eom
		end

	All_indicators_request_msg: STRING is
			-- "all-indicators" request to the server
		do
			Result := All_indicators_request.out + Message_field_separator +
				session_key.out + Message_field_separator + eom
		end

	Connection_failed_msg: STRING is "Connection to the server failed."

	Connection_creation_failed_msg: STRING is "Creation of connection."

	Invalid_address_msg: STRING is "Invalid network address."

invariant

	server_response_exists_if_succeeded:
		last_communication_succeeded implies server_response /= Void
	error_report_exists_on_failure:
		not last_communication_succeeded implies error_report /= Void
	positive_session_key_if_logged_in: logged_in implies session_key > 0

end
