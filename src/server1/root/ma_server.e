indexing
	description: "Root class for the Market Analysis Server using MAL"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class MA_SERVER inherit

	GLOBAL_SERVER
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	MAS_EXCEPTION
		export
			{NONE} all
		end

	TERMINABLE
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make is
		local
			socket: NETWORK_STREAM_SOCKET
			readcmd: POLL_COMMAND
			factory_builder: FACTORY_BUILDER
			version: expanded PRODUCT_INFO
		do
			if command_line_options.error_occurred then
				print_list (<<"Error occurred during initialization - ",
					"exiting ...%N">>)
				exit (Error_exit_status)
			elseif command_line_options.help then
				command_line_options.usage
			elseif command_line_options.version_request then
				print_list (<<version.name, ", Version ", version.number, ", ",
					version.informal_date, "%N">>)
			else
				register_for_termination (Current)
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
				from
				until
					finished
				loop
					poller.execute (15, 20000)
				end
				exit (0)
			end
		rescue
			-- Let assertion violations be handled by the run-time environment.
			if not assertion_violation then
				handle_exception ("main routine")
				check no_cleanup = false end
				exit (Error_exit_status)
			end
		end

feature {NONE}

	finished: BOOLEAN
			-- Is it time to exit the server?

	poller: MEDIUM_POLLER
			-- Poller for client socket connections

	cleanup is
			-- Close all unclosed sockets.
		do
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
		end

	current_sockets: LIST [SOCKET]

end -- MA_SERVER
