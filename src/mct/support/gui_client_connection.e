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
			Result := socket.is_open_read and socket.is_open_write
		ensure
			definition: Result = (socket.is_open_read and socket.is_open_write)
		end

feature -- Basic operations

	close is
			-- Close the connection.
		do
			if not socket.is_closed then
				socket.close
			end
			socket.cleanup
		end

	ping_server is
			-- Build a message to server, receive answer, build
			-- modified message from that answer, and print it.
		require
			connected: connected
		local
			s: STRING
		do
			last_communication_succeeded := False
			socket.put_string (login_request_msg)
			create s.make (0)
			from
				if socket.readable then
					socket.read_character
				end
			until
				socket.last_character = eom @ 1 or not socket.readable
			loop
				s.extend (socket.last_character)
				socket.read_character
			end
			print ("The server returned '" + s + "'.%N")
			process_response (s)
		end

feature {NONE} -- Initialization

	make (hostname: STRING; port: INTEGER) is
			-- Establish communication with server, and exchange messages.
		local
			retried: BOOLEAN
		do
			if not retried then
				create socket.make_client_by_port (port, hostname)
				socket.connect
				if connected then
					last_communication_succeeded := True
					server_response := ""
					socket.set_blocking
				else
					error_report := socket.error
					if error_report = Void then
						error_report := "Connection failed."
					end
				end
			end
		ensure
			connected: last_communication_succeeded implies connected
			blocking: last_communication_succeeded implies socket.is_blocking
		rescue
			socket.cleanup
			retried := True
		end

feature {NONE} -- Implementation

	socket: NETWORK_STREAM_SOCKET

	process_response (s: STRING) is
			-- Process server response `s' - set `server_response' and
			-- `last_communication_succeeded' accordingly.
		local
			su: expanded STRING_UTILITIES
			l: LIST [STRING]
		do
			su.set_target (s)
			l := su.tokens (Message_field_separator)
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

	login_request_msg: STRING is
		once
			Result := Login_request.out + Message_field_separator + "0" +
				Message_field_separator + eom
		end

invariant

	server_response_exists_if_succeeded:
		last_communication_succeeded implies server_response /= Void
	error_report_exists_on_failure:
		not last_communication_succeeded implies error_report /= Void

end
