indexing
	description: "Market Analysis Command-Line (MACL) client - accesses the %
		%MA server command-line interface via a socket connection."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

class MACL inherit

	COMMAND_LINE_UTILITIES
		rename
			print as output_message
		export
			{NONE} all
		redefine
			output_device
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
				if command_line.timing_on then
					connection.set_timing (True)
				end
			until
				connection.termination_requested or
				not connection.last_communication_succeeded
			loop
				print (connection.server_response)
				processor.process_server_msg (connection.server_response)
				handle_error (processor)
				processor.process_request (user_response)
				connection.send_message (processor.product)
				-- Save the recorded input as it is entered to ensure the
				-- output has been saved if an unrecoverable exception occurs.
				output_current_input_record (processor)
			end
			if not connection.last_communication_succeeded then
				print (connection.error_report + "%N")
			end
			connection.close
			close_output_file (processor)
		rescue
			handle_fatal_exception
		end

	initialize is
		do
			not_verbose_reporting := True
			output_device := io.output
			if command_line.error_occurred then
				print (command_line.error_description)
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
			-- Obtain user response, skipping comments (# ...) and
			-- stripping off leading white space
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
				if command_line.is_debug then
					print ("%Ninput line: " + last_input_line_number.out + "%N")
				end
			end
			Result.left_adjust
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
				output_device.flush
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

	handle_error (processor: COMMAND_PROCESSOR) is
			-- If `processor.error', take appropriate action.
		do
			if processor.error then
				if
					processor.fatal_error or
					(command_line.terminate_on_error and
					command_line.input_from_file)
				then
					abort (Invalid_input_message)
				end
			end
		end

	output_current_input_record (processor: COMMAND_PROCESSOR) is
			-- If `processor.record', output `processor.input_record' to
			-- `command_line.output_file'.
		require
			processor_exists: processor /= Void
		do
			if processor.record then
				command_line.output_file.put_string (processor.input_record)
				command_line.output_file.flush
				processor.input_record.clear_all
			end
		ensure
			input_saved_and_cleared: processor.record implies
				processor.input_record.is_empty
		end

	close_output_file (processor: COMMAND_PROCESSOR) is
			-- If `processor.record', close `command_line.output_file'.
		require
			no_more_output: processor.record implies
				processor.input_record.is_empty
			output_file_open: processor.record implies
				not command_line.output_file.is_closed
		do
			if processor.record then
				print ("Saved recorded input to file " +
					command_line.output_file.name + ".%N")
				command_line.output_file.close
			end
		end

feature {NONE} -- Attribute redefinitions

	output_device: PLAIN_TEXT_FILE

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

	Abnormal_termination_message: STRING is
		"%NUnexpected exception occurred.%N"

	Invalid_input_message: STRING is
		do
			Result := "%NInvalid or incorrect user input on line " +
				last_input_line_number.out + "%N"
		end

end
