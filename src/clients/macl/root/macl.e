indexing
	description: "Market Analysis Command-Line (MACL) client - accesses the %
		%MA server command-line interface via a socket connection."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MACL inherit

	COMMAND_LINE
		rename
			make as cl_make
		export
			{NONE} all
		undefine
			print
		end

	COMMAND_LINE_UTILITIES
		export
			{NONE} all
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		undefine
			print
		end

create

	make

feature {NONE} -- Initialization

	make is
		local
			i: INTEGER
			host: STRING
			port: INTEGER
			processor: COMMAND_PROCESSOR
		do
--!!!!Call cl_make?

--!!!Replace cl argument parsing with reusable code:
--			if len(argv) < 2 then
--				usage()
--				exit(-1)
--			end
			host := ""
			port := -1
			input_device := io.input
			output_device := io.output
--			argcount := len(argv)
			i := 1
--			while i < argcount:
--				if argv[i][:2] = "-h" then
--					if i + 1 < argcount then
--						i := i + 1
--						host := argv[i]
--					else
--						usage(); exit(-1)
--					end
--				elseif argv[i][:2] = "-r":
--					Record := true
--					if i + 1 < argcount and argv[i+1][:1] /= "-" then
--						i := i + 1
--						Recordfile := argv[i]
--					else
--						abort("Output file for record option was not %
--							%specified.", 0)
--					end
--				elseif argv[i][:2] = "-i":
--					if i + 1 < argcount and argv[i+1][:1] /= "-" then
--						i := i + 1
--						try:
--							input_file := open(argv[i], "r", 000)
--						except:
--							abort("Attempt to open input file " + argv[i] +
--								" failed", 0)
--						stdin := input_file
--					else
--						abort("Output file for record option was not %
--							%specified.", 0)
--					end
--				else
--					try:
--						port := eval(argv[i])
--					except:
--						usage(); exit(-1)
--				end
--				i := i + 1

--!!!tmp test:
port := 2003
			if port = -1 then
				print (usage())
				abort ("Missing port number", Void)
			end
			if host.is_empty then
				host := "localhost"
			end
			create processor.make (Record)
			-- Create the connection to  and start the conversation with
			-- the server.
			create connection.start_conversation (host, port)
--!!!remove:			connection.receive_message()
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
--!!!					processor.process (user_response())
					connection.send_message (processor.product)
	--!!!remove:			connection.receive_message()
				end
			else
				print (connection.error_report + "%N")
			end
			connection.close()
			if processor.record then
				print ("Saving recorded input to file " + Recordfile + ".%N")
--				create record_file.make_open_write (Recordfile)
				record_file.put_string (processor.input_record)
				record_file.close
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
--!!!remove:				conn.receive_message()
				print ("Closing ...%N")
				conn.close()
			end
			exit (-1)
		end

	dummy_init is
		do
--!!!Appears to not be needed:			Buffersize := 1
			Record := false
			Recordfile := "mas_session"
		end

	usage: STRING is
		do
			Result := "Usage: " + command_name + " [options] port_number" +
				"%NOptions:%N" +
				"   -h <hostname>   Connect to server on host <hostname>%N" +
				"   -r <file>       Record user input and save to <file>%N" +
				"   -i <file>       Obtain input from <file> instead of %
				%the console%N"
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

	Record: BOOLEAN
			-- Is the session to be recorded?

	Recordfile: STRING
			-- File into which recorded data is to be stored

	connection: CONNECTION

	record_file: PLAIN_TEXT_FILE

	Exit_string: STRING is "x%N"

	Comment_character: CHARACTER is '#'

end
