indexing
	description: "Market Analysis Command-Line (MACL) client - accesses the %
		%MA server command-line interface via a socket connection."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MACL inherit

	COMMAND_LINE_UTILITIES
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		undefine
			print
		redefine
			application_name
		end

create

	make

feature {NONE} -- Initialization

	make is
		local
			processor: COMMAND_PROCESSOR
		do
			initialize
			create processor.make (command_line.record)
			-- Create the connection to  and start the conversation with
			-- the server.
			from
				create connection.start_conversation (host, port)
			until
				connection.termination_requested or
				not connection.last_communication_succeeded
			loop
print ("A%N")
print ("liln: " + last_input_line_number.out + "%N")
				print (connection.server_response)
if connection.server_response.substring_index (
"Select an object for the SUBTRACTION's left operand:", 1) > 0 then
	print ("Found 'left'.%N")
end
if connection.server_response.substring_index (
"Select an object for the SUBTRACTION's right operand:", 1) > 0 then
	print ("Found 'right'.%N")
end
print ("B%N")
				processor.process_server_msg (connection.server_response)
print ("C%N")
				if processor.error then
print ("D%N")
					if processor.fatal_error then
						abort ("Invalid user input on line " +
							last_input_line_number.out)
					end
				end
print ("E%N")
				processor.process_request (user_response)
print ("F%N")
if last_input_line_number >= 119 then
	print ("last_input_line_number = " + last_input_line_number.out + "%N")
--	debug_socket
end
				connection.send_message (processor.product)
if last_input_line_number >= 119 then
	print ("last_input_line_number = " + last_input_line_number.out + "%N")
--	debug_socket
end
print ("G%N")
			end
			if not connection.last_communication_succeeded then
				print (connection.error_report + "%N")
			end
print ("H%N")
			connection.close
print ("I%N")
			if processor.record then
				print ("Saving recorded input to file " +
					command_line.output_file.name + ".%N")
				command_line.output_file.put_string (processor.input_record)
				command_line.output_file.close
			end
print ("J%N")
		rescue
print ("K%N")
			last_exception_status.set_fatal (True)
print ("L%N")
			exit_and_close_connection
print ("M%N")
			handle_exception ("")
print ("N%N")
		end

	initialize is
		do
			not_verbose_reporting := True
			output_device := io.output
			if command_line.error_occurred then
				print (command_line.usage)
				abort (Void)
			end
			if command_line.input_from_file then
				input_device := command_line.input_file
			else
				input_device := io.input
			end
			port := command_line.port_number
			if port = -1 then
				print (command_line.usage)
				abort ("Missing port number")
			end
			host := command_line.host_name
			if host.is_empty then
				host := "localhost"
			end
		end

feature {NONE} -- Utilities

	abort (msg: STRING) is
		do
			if msg /= Void then
				print (msg + " - ")
			end
			exit_and_close_connection
			exit (-1)
		end

	user_response: STRING is
			-- Obtain user response, skipping comments (# ...)
		local
			finished: BOOLEAN
			console: CONSOLE
		do
			from
			until
				finished
			loop
				if not input_device.readable then
					console ?= input_device
					if console /= Void then
						abort ("End of input reached unexpectedly.")
					else
						print ("End of input reached unexpectedly.%N%
							%Attempting to return control to the console.%N")
						input_device := io.input
					end
				end
				Result := string_selection ("")
				if not Result.is_empty and Result @ 1 /= Comment_character then
					finished := True
				end
				last_input_line_number := last_input_line_number + 1
			end
		ensure
			Result_exists: Result /= Void
		end

	exit_and_close_connection is
			-- Exit and close the connection.
		do
			print ("Exiting ...%N")
			if connection /= Void then
				connection.send_message (Exit_string)
				connection.close
			end
		end

feature {NONE} -- Implementation

	command_line: expanded MACL_COMMAND_LINE

	connection: CONNECTION

	record_file: PLAIN_TEXT_FILE

	Exit_string: STRING is "x%N"

	Comment_character: CHARACTER is '#'

	host: STRING

	port: INTEGER

	last_input_line_number: INTEGER

	application_name: STRING is "client"

debug_socket is
	do
		connection.do_debug
	end

end
