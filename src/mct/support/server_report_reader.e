indexing
	description: "Poll command that reads a MAS server's startup status report"
	date: "$Date$";
	revision: "$Revision$"

class SERVER_REPORT_READER inherit

	POLL_COMMAND
		redefine
			active_medium
		end

	GENERAL_UTILITIES
		export
			{NONE} all
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
			response_received: BOOLEAN
			i: INTEGER
		do
			response := ""
print ("A (" + (create {DATE_TIME}.make_now).out + "%N")
			active_medium.set_non_blocking
			active_medium.set_timeout (1)
			active_medium.listen (1)
			if active_medium.socket_ok then
				from i := 1 until response_received or i > Max_tries loop
print ("E (i: " + i.out + ", " + (create {DATE_TIME}.make_now).out + "%N")
					active_medium.accept
					socket := active_medium.accepted
					if socket /= Void and then socket.socket_ok then
print ("H (" + (create {DATE_TIME}.make_now).out + "%N")
						socket.read_stream (Buffer_size)
						if socket.last_string /= Void then
							response := socket.last_string
						end
						response_received := True
					else
print ("I (" + (create {DATE_TIME}.make_now).out + "%N")
						if socket /= Void then
							response := socket.error
							response_received := True
						end
					end
					if socket /= Void and then not socket.is_closed then
						socket.close
					end
					i := i + 1
					if not response_received then
						microsleep (0, Sleep_interval_in_microseconds)
					end
				end
				if not response_received then
					check
						max_tries_reached: i = Max_tries + 1
					end
					response := Timeout_error
				end
			else
				if
					active_medium.error /= Void and then
					not active_medium.error.is_empty
				then
					response := active_medium.error
				else
					response := Connection_failed
				end
			end
print ("J (" + (create {DATE_TIME}.make_now).out + "%N")
		ensure
			response_exists: response /= Void
		end

feature {NONE} -- Implementation

	active_medium: NETWORK_STREAM_SOCKET

	Buffer_size: INTEGER is
		once
			Result := (2 ^ 14).floor
		end

	Timeout_error: STRING is "Timed out waiting for the server to start."

	Connection_failed: STRING is "Connection to server failed."

	Max_tries: INTEGER is 20

	Sleep_interval_in_microseconds: INTEGER is 410000

end
