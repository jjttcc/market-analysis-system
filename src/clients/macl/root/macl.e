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
		end

	EXCEPTION_SERVICES
		export
			{NONE} all
		end

create

	make

feature -- Feature comment

	abort (msg: STRING; conn: CONNECTION) is
		do
			if msg /= Void then
				print (msg + " - ")
			end
			print ("Exiting ...%N")
			if conn /= Void then
				conn.send_message(Exit_string)
				conn.receive_message()
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

	user_response (): STRING is
			-- Obtain user response, skipping comments (# ...)
		do
			--!!!!Replace with existing reusable code.
--			loop := true
--			while loop:
--				s := stdin.readline()[:-1]
--				if len(s) > 0 and s[0] /= "--" then
--					loop := false
--				end
--			return s
		end

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
			if port = -1 then
				print (usage())
				abort("Missing port number", Void)
			end
			if host = "" then
				host := "localhost";
			end
			create processor.make (Record)
			create connection.make (host, port)
			connection.receive_message()
			from
			until
				connection.termination_requested
			loop
				print (connection.last_message)
				processor.set_server_msg(connection.last_message)
				if processor.error then
					if processor.fatal_error then
						abort("Invalid user input", connection)
					end
				end
				processor.process(user_response())
				connection.send_message(processor.product)
				connection.receive_message()
			end
			connection.close()
			if processor.record then
				print ("Saving recorded input to file " + Recordfile + ".%N")
				create record_file.make_open_write (Recordfile)
				record_file.put_string (processor.input_record)
				record_file.close
			end
		end

	Record: BOOLEAN
			-- Is the session to be recorded?

	Recordfile: STRING
			-- File into which recorded data is to be stored

	connection: CONNECTION

	record_file: PLAIN_TEXT_FILE

	Exit_string: STRING is "x%N"

end
