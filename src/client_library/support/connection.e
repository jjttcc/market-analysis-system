indexing
	description: "Socket connection facilities for Market Analysis %
		%command-line clients."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CONNECTION inherit

	NETWORK_PROTOCOL
		export
			{NONE} all
		end

	CLIENT_CONNECTION
		export
			{NONE} send_request
			{ANY} close
		redefine
			end_of_message
		end

create

	make_connected, start_conversation

feature {NONE} -- Initialization

	start_conversation (host: STRING; port: INTEGER) is
			-- Setup initial state and begin the conversation with
			-- the server.
		do
			make_connected (host, port)
			if last_communication_succeeded then
				send_message (Console_flag.out)
			end
		ensure
			response_set_on_success: last_communication_succeeded implies
				server_response /= Void
		end

feature -- Status report

	termination_requested: BOOLEAN

feature -- Basic operations

	send_message (msg: STRING) is
			-- Send `msg' to the server and put the server's response
			-- into `server_response'.
		do
			send_request (msg, True)
		ensure
			response_set_on_success: last_communication_succeeded implies
				server_response /= Void
		end

feature {NONE} -- Implementation

	end_of_message (c: CHARACTER): BOOLEAN is
		do
			Result := c = Eom @ 1 or c = Eot @ 1
			termination_requested := c = Eot @ 1
		end

feature {NONE} -- Implementation - Constants

	Buffersize: INTEGER is 1

	Timeout_seconds: INTEGER is 35

feature {NONE} -- Unused

	Message_date_field_separator: STRING is ""

	Message_time_field_separator: STRING is ""

end
