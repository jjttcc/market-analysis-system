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
		rename
			print as output_message
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		rename
			print as output_message
		export
			{NONE} all
		undefine
			output_message
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
				print (connection.server_response)
				processor.process_server_msg (connection.server_response)
				if processor.error then
					if
						processor.fatal_error or command_line.input_from_file
					then
						abort (Invalid_input_message)
					else
						print (Invalid_input_message)
					end
				end
				processor.process_request (user_response)
				connection.send_message (processor.product)
			end
			if not connection.last_communication_succeeded then
				print (connection.error_report + "%N")
			end
			connection.close
			if processor.record then
				print ("Saving recorded input to file " +
					command_line.output_file.name + ".%N")
				command_line.output_file.put_string (processor.input_record)
				command_line.output_file.close
			end
		rescue
			handle_fatal_exception
		end

	initialize is
		do
			not_verbose_reporting := True
			output_device := io.output
			if command_line.error_occurred then
				print (command_line.usage)
				abort (Void)
			end
			if command_line.help then
				print (command_line.usage)
				exit (0)
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
			if connection /= Void and connection.socket_ok then
				connection.send_request (Exit_string, False)
				connection.close
			end
		end

	print (a: ANY) is
		do
			if command_line.quiet_mode then
				output_message (".")
			else
				output_message (a)
			end
		end

	handle_fatal_exception is
		local
			retried: BOOLEAN
		do
			if not retried then
				print (Abnormal_termination_message)
				last_exception_status.set_fatal (True)
				exit_and_close_connection
				if command_line.is_debug then
					handle_exception ("")
				end
			end
			exit (1)
		rescue
			retried := True
			retry
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

	Abnormal_termination_message: STRING is "Unexpected exception occurred.%N"

	Invalid_input_message: STRING is
		do
			Result := "Invalid or incorrect user input on line " +
				last_input_line_number.out
		end

end
