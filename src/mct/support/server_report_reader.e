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
print ("A " + (create {DATE_TIME}.make_now).out + "%N")
active_medium.set_timeout (1)
active_medium.set_non_blocking
			active_medium.listen (1)
			if active_medium.socket_ok then
print (active_medium.socket_would_block.out + "%N")
print (active_medium.readable.out + "%N")
print (active_medium.is_blocking.out + "%N")
print (active_medium.is_linger_on.out + "%N")
print (active_medium.ready_for_reading.out + "%N")
print (active_medium.ready_for_writing.out + "%N")
print (active_medium.socket_in_use.out + "%N")
				active_medium.accept
print ("C " + (create {DATE_TIME}.make_now).out + "%N")
				socket := active_medium.accepted
				if socket /= Void and then socket.socket_ok then
					socket.read_stream (Buffer_size)
print ("F " + (create {DATE_TIME}.make_now).out + "%N")
					if socket.last_string /= Void then
						response := socket.last_string
print ("G (received " + response + " " + (create {DATE_TIME}.make_now).out + "%N")
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
print ("I " + (create {DATE_TIME}.make_now).out + "%N")
				end
			else
print ("oops: " + active_medium.out + "%N")
print ("K " + (create {DATE_TIME}.make_now).out + "%N")
			end
print ("J " + (create {DATE_TIME}.make_now).out + "%N")
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
