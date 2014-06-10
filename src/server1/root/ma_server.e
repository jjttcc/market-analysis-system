note
	description: "Root class for the Market Analysis Server using MAL"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MA_SERVER inherit

	POLLING_SERVER
		rename
			report_errors as report_back
		redefine
			report_back, current_media, read_command_for, initialize
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Hook routine implementations

-- @@Temporary - make these math classes available in the IDE until
-- operators using them are implemented:
r: RANDOM
f: FIBONACCI
th_ex: THREAD_EXPERIMENTS

	read_command_for (medium: COMPRESSED_SOCKET): POLL_COMMAND
		local
			sock_acc: MAS_SOCKET_ACCEPTOR
		do
			create sock_acc.make (medium, factory_builder)
			create {SOCKET_BASED_POLL_COMMAND} Result.make (sock_acc)
		end

	make_current_media
		do
			create {LINKED_LIST [SOCKET]} current_media.make
			from
				command_line_options.port_numbers.start
			until
				command_line_options.port_numbers.exhausted
			loop
				current_media.extend (
					create {COMPRESSED_SOCKET}.make_server_by_port (
					command_line_options.port_numbers.item))
				command_line_options.port_numbers.forth
			end
		end

	additional_read_commands: LINEAR [POLL_COMMAND]
-- !!!! indexing once_status: global??!!!
		local
			cmds: LINKED_LIST [POLL_COMMAND]
		once
			create cmds.make
			Result := cmds
			if not command_line_options.background then
				cmds.extend (create {MAS_CONSOLE_READER}.make (factory_builder))
			end
		end

	version: MAS_PRODUCT_INFO
		note
			once_status: global
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		once
			Result := gs.global_configuration.product_info
		end

	configuration_error: BOOLEAN
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

	initialize
		local
			gsf: expanded GLOBAL_SERVER_FACILITIES
			d: DATE_TIME
		do
			-- Force the startup time to be created at "start-up'.
			d := gsf.startup_date_time
		end

feature {NONE} -- Implementation

	report_back (errs: STRING)
			-- If command_line_options.report_back, send a status
			-- report back to the startup process.
		local
			connection: SERVER_RESPONSE_CONNECTION
			cl: MAS_COMMAND_LINE
		do
			cl := command_line_options
			if cl.report_back then
				create connection.make_tested (cl.host_name_for_startup_report,
					cl.port_for_startup_report)
				-- If `errs.is_empty', the startup process will assume
				-- that this process started succefully.
				connection.send_one_time_request (errs, False)
				if not connection.last_communication_succeeded then
					log_error (connection.error_report)
				end
			end
		end

	factory_builder: GLOBAL_OBJECT_BUILDER
-- !!!! indexing once_status: global??!!!
		once
			create Result.make
		end

feature {NONE} -- Implementation - Attributes

	current_media: LIST [SOCKET]

end
