indexing
	description: "Root class for the Market Analysis Server using MAL"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MA_SERVER inherit

	SERVER

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Hook routines

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
					config_error_description := concatenation (<<
						env_vars.application_directory_name, " setting ",
						"specifies a directory that does not exist or that ",
						"is not reachable from the current directory">>)
					Result := True
				end
			end
		end

feature {NONE}

	poller: MEDIUM_POLLER
			-- Poller for client socket connections

	current_sockets: LIST [SOCKET]

end
