note
	description: "Socket connection facilities for Market Analysis %
		%command-line clients."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CONNECTION inherit

	CLIENT_CONNECTION
		export
			{ANY} close, send_request
		redefine
			end_of_message
		end

	MA_COMMUNICATION_PROTOCOL

create

	make_connected, start_conversation

feature {NONE} -- Initialization

	start_conversation (host: STRING; port: INTEGER)
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

	timing: BOOLEAN
			-- Is timing of requests/responses on?

feature -- Status setting

	do_debug
			-- Debug
		local
			old_timeout: INTEGER
		do
			print ("rec. buf size: " + socket.receive_buf_size.out + "%N")
			print ("send. buf size: " + socket.send_buf_size.out + "%N")
			print ("route_enabled: " + socket.route_enabled.out + "%N")
			print ("is_blocking: " + socket.is_blocking.out + "%N")
			print ("ok: " + socket.socket_ok.out + "%N")
			print ("expired_socket: " + socket.expired_socket.out + "%N")
			print ("dtable_full: " + socket.dtable_full.out + "%N")
			old_timeout := socket.timeout
			socket.set_timeout (1)
			print ("has_exception_state: " +
				socket.has_exception_state.out + "%N")
			socket.set_timeout (old_timeout)
			print ("is_linger_on: " + socket.is_linger_on.out + "%N")
			print ("is_out_of_band_inline: " +
				socket.is_out_of_band_inline.out + "%N")
			print ("linger_time: " + socket.linger_time.out + "%N")
			print ("no_buffers: " + socket.no_buffers.out + "%N")
			print ("not_connected: " + socket.not_connected.out + "%N")
		end

	set_timing (arg: BOOLEAN)
			-- Set `timing' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			timing := arg
			if timing then
				create timer.make
			else
				timer := Void
			end
		ensure
			timing_set: timing = arg and timing /= Void
		end

feature -- Basic operations

	send_message (msg: STRING)
			-- Send `msg' to the server and put the server's response
			-- into `server_response'.
		require
			socket_ok: socket_ok
		do
			if timing then
				timer.start
			end
			send_request (msg, True)
			if timing then
				print_timing_report
			end
		ensure
			response_set_on_success: last_communication_succeeded implies
				server_response /= Void
		end

	send_termination_request (wait_for_response: BOOLEAN)
			-- Send a request to terminate the server process.
		require
			socket_ok: socket_ok
		do
			if timing then
				timer.start
			end
			send_request (Termination_message, wait_for_response)
			if timing then
				print_timing_report
			end
		ensure
			response_set_on_success: last_communication_succeeded implies
				server_response /= Void
		end

feature {NONE} -- Implementation

	end_of_message (c: CHARACTER): BOOLEAN
		do
			Result := c = Eom @ 1 or c = Eot @ 1
			termination_requested := c = Eot @ 1
		end

	timer: TIMER

	print_timing_report
		do
			print ("Last request/response took " +
				timer.elapsed_time.fine_seconds_count.out + " seconds.%N")
		end

feature {NONE} -- Implementation - Constants

	Buffersize: INTEGER = 1

	Timeout_seconds: INTEGER
		once
			Result := Seconds_in_a_day * 365
		end

	Seconds_in_an_hour: INTEGER
		once
			Result := 60 * 60
		end

	Seconds_in_a_day: INTEGER
		once
			Result := Seconds_in_an_hour * 24
		end

	Termination_message: STRING = "%N"

feature {NONE} -- Unused

	Message_date_field_separator: STRING = ""

	Message_time_field_separator: STRING = ""

invariant

	timer_exists_if_timing: timing = (timer /= Void)

end
