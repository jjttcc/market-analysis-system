indexing
	description: "Poll command that reads a MAS server's startup status report"
	date: "$Date$";
	revision: "$Revision$"

class SERVER_REPORT_READER inherit

	POLL_COMMAND
		redefine
			active_medium
		end

create

	make

feature -- Access

	response: STRING
			-- The response from the server

feature {MEDIUM_POLLER} -- Basic operations

	execute (arg: ANY) is
		local
			socket: NETWORK_STREAM_SOCKET
		do
			response := ""
			active_medium.set_timeout (1)
			active_medium.set_non_blocking
			active_medium.listen (1)
			if active_medium.socket_ok then
				active_medium.accept
				socket := active_medium.accepted
				if socket /= Void and then socket.socket_ok then
					socket.read_stream (Buffer_size)
					if socket.last_string /= Void then
						response := socket.last_string
					end
				else
					if socket /= Void then
						response := socket.error
					else
						response := Connection_failed
					end
				end
				if socket /= Void and then not socket.is_closed then
					socket.close
				end
			else
				--@@An error report is probably needed here.
			end
		ensure
			response_exists: response /= Void
		end

feature {NONE} -- Implementation

	active_medium: NETWORK_STREAM_SOCKET

	Buffer_size: INTEGER is
		once
			Result := (2 ^ 14).floor
		end

	Connection_failed: STRING is "Connection to server failed."

end
