indexing
	description: "Root class for the Market Analysis Server using MAL"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MA_SERVER inherit

	SERVER
		rename
			make as server_make
		redefine
			exit, log_errors
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			create errors.make (0)
			server_make
		end

feature {NONE} -- Hook routine implementation

	prepare_for_listening is
		local
			socket: COMPRESSED_SOCKET
			readcmd: POLL_COMMAND
			factory_builder: FACTORY_BUILDER
		do
			create poller.make_read_only
			create factory_builder.make
			create {LINKED_LIST [SOCKET]} current_sockets.make
			-- Make a socket for each port number provided in the
			-- command line, create a STREAM_READER to handle it,
			-- and add it to the poller's list of read commands.
			-- (Allows concurrent processing - in a future version.)
			from
				command_line_options.port_numbers.start
			until
				command_line_options.port_numbers.exhausted
			loop
				create socket.make_server_by_port (
					command_line_options.port_numbers.item)
				create {STREAM_READER} readcmd.make (socket,
					factory_builder)
				poller.put_read_command (readcmd)
				current_sockets.extend (socket)
				command_line_options.port_numbers.forth
			end
			-- If background is not specified, add a reader to respond to
			-- console commands.
			if not command_line_options.background then
				create {CONSOLE_READER} readcmd.make (factory_builder)
				poller.put_read_command (readcmd)
			end
			report_back (errors)
		end

	listen is
			-- Listen for and respond to client requests.
		do
			check
				poller: poller /= Void
			end
			poller.execute (15, 20000)
		end

	version: MAS_PRODUCT_INFO is
		once
			create Result
		end

	cleanup is
			-- Close all unclosed sockets.
		local
			ex_srv: expanded EXCEPTION_SERVICES
		do
			if not ex_srv.last_exception_status.description.is_empty then
				if errors.is_empty then
					errors := ex_srv.last_exception_status.description
				else
					errors := errors + "%N" +
						ex_srv.last_exception_status.description
				end
			end
			if current_sockets /= Void then
				from
					current_sockets.start
				until
					current_sockets.exhausted
				loop
					if not current_sockets.item.is_closed then
						current_sockets.item.close
					end
					current_sockets.forth
				end
			end
			if not errors.is_empty then
				report_back (errors)
			end
		end

	configuration_error: BOOLEAN is
			-- Is there an error in the MAS configuration?  If so,
			-- a description is placed into config_error_description.
		local
			env: expanded APP_ENVIRONMENT
			env_vars: expanded APP_ENVIRONMENT_VARIABLE_NAMES
			d: DIRECTORY
		do
			if
				env.app_directory /= Void and not env.app_directory.is_empty
			then
				create d.make (env.app_directory)
				if not d.exists then
					config_error_description := 
						env_vars.application_directory_name + " setting " +
						"specifies a directory that does not exist or that%N" +
						"is not reachable from the current directory:%N%"" +
						env.app_directory + "%""
					Result := True
				end
			end
		end

	notify (msg: STRING) is
		do
			errors.append (msg + "%N")
		end

	exit (status: INTEGER) is
		do
			if command_line_options.error_occurred then
				errors := errors + command_line_options.error_description
			end
			report_back (errors)
			Precursor (status)
		end

	log_errors (a: ARRAY [STRING]) is
		local
			l: LINEAR [STRING]
		do
			Precursor (a)
			from
				l := a.linear_representation
				l.start
			until
				l.exhausted
			loop
				errors := errors + l.item
				l.forth
			end
		end

feature {NONE} -- Implementation

	report_back (errs: STRING) is
			-- If command_line_options.report_back, send a status
			-- report back to the startup process.
		local
			connection: SERVER_RESPONSE_CONNECTION
			cl: MAS_COMMAND_LINE
		do
			cl := command_line_options
			if cl.report_back then
				create connection.make (cl.host_name_for_startup_report,
					cl.port_for_startup_report)
				-- If `errs.is_empty', the startup process will assume
				-- that this process started succefully.
				connection.send_one_time_request (errs, False)
			end
		end

feature {NONE} -- Implementation - Attributes

	poller: MEDIUM_POLLER
			-- Poller for client socket connections

	current_sockets: LIST [SOCKET]

	errors: STRING
			-- List of error messages to "report back" to the startup process

end
