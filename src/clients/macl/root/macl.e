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
pcre: PCRE
		do
create pcre.make --!!! Run reg-exp example, for study.
			initialize
			create processor.make (Record)
			-- Create the connection to  and start the conversation with
			-- the server.
			create connection.start_conversation (host, port)
			if connection.last_communication_succeeded then
				from
				until
					connection.termination_requested
				loop
					print (connection.server_response)
					processor.set_server_msg (connection.server_response)
					if processor.error then
						if processor.fatal_error then
							abort ("Invalid user input", connection)
						end
					end
					processor.process (user_response())
					connection.send_message (processor.product)
				end
			else
				print (connection.error_report + "%N")
			end
			connection.close()
			if processor.record then
				print ("Saving recorded input to file " + Recordfile + ".%N")
				create record_file.make_open_write (Recordfile)
				record_file.put_string (processor.input_record)
				record_file.close
			end
		end

	initialize is
		local
			command_line: expanded MACL_COMMAND_LINE
		do
			input_device := io.input
			output_device := io.output
			recordfile := "mas_session"
			port := command_line.port_number
			if port = -1 then
				print (command_line.usage)
				abort ("Missing port number", Void)
			end
			host := command_line.host_name
			if host.is_empty then
				host := "localhost"
			end
		end

feature {NONE} -- Utilities

	abort (msg: STRING; conn: CONNECTION) is
		do
			if msg /= Void then
				print (msg + " - ")
			end
			print ("Exiting ...%N")
			if conn /= Void then
				conn.send_message (Exit_string)
				print ("Closing ...%N")
				conn.close()
			end
			exit (-1)
		end

	user_response: STRING is
			-- Obtain user response, skipping comments (# ...)
		local
			finished: BOOLEAN
		do
			from
			until
				finished
			loop
				Result := string_selection ("")
				if not Result.is_empty and Result @ 1 /= Comment_character then
					finished := True
				end
			end
		end

feature {NONE} -- Implementation

	record: BOOLEAN
			-- Is the session to be recorded?

	recordfile: STRING
			-- File into which recorded data is to be stored

	connection: CONNECTION

	record_file: PLAIN_TEXT_FILE

	Exit_string: STRING is "x%N"

	Comment_character: CHARACTER is '#'

	host: STRING

	port: INTEGER

	application_name: STRING is "client"

end
