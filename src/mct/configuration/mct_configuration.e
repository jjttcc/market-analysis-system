indexing
	description: "Configuration of environment/platform-dependent settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		export
			{NONE} all
		redefine
			post_process_settings, use_customized_setting,
			do_customized_setting
		end

	MCT_CONFIGURATION_CONSTANTS
		export
			{NONE} token_from
		end

creation

	make

feature {NONE} -- Initialization

	initialize_settings_table is
		do
			create settings.make (0)
			create start_server_commands.make

			settings.extend ("", Data_directory_specifier)
			settings.extend ("", Bin_directory_specifier)
			settings.extend ("", Valid_port_numbers_specifier)
			settings.extend ("", Hostname_specifier)
			settings.extend ("", Start_server_cmd_specifier)
			settings.extend ("", Start_cl_client_cmd_specifier)
			settings.extend ("", Chart_cmd_specifier)
			settings.extend ("", Termination_cmd_specifier)
		end

feature -- Access

	data_directory: STRING is
		do
			Result := settings @ Data_directory_specifier
		ensure
			not_void: Result /= Void
		end

	bin_directory: STRING is
		do
			Result := settings @ Bin_directory_specifier
		ensure
			not_void: Result /= Void
		end

	valid_portnumbers: LIST [STRING] is
		do
			Result := (settings @ Valid_port_numbers_specifier).split (
				Valid_port_numbers_separator)
		ensure
			not_void: Result /= Void
		end

	hostname: STRING is
		do
			Result := settings @ Hostname_specifier
		ensure
			not_void: Result /= Void
		end

	default_start_server_command: EXTERNAL_COMMAND
			-- Specified default 'start-server' command

	start_server_commands: LINKED_SET [EXTERNAL_COMMAND]
			-- Configured 'start-server' commands

	start_command_line_client_command: EXTERNAL_COMMAND
			-- Command to start the command-line client

	chart_command: EXTERNAL_COMMAND
			-- Command to start the charting client

	termination_command: EXTERNAL_COMMAND
			-- Command to terminate a server

feature -- Status report

	terminate_sessions_on_exit: BOOLEAN
			-- Should all owned MAS sessions be terminated on exit?

feature -- Status setting

	set_terminate_sessions_on_exit (arg: BOOLEAN) is
			-- Set `terminate_sessions_on_exit' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			terminate_sessions_on_exit := arg
		ensure
			terminate_sessions_on_exit_set: terminate_sessions_on_exit = arg
				and terminate_sessions_on_exit /= Void
		end

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_type: STRING is "MAS Control Terminal"

	configuration_file_name: STRING is "mctrc"

	post_process_settings is
		do
			settings.linear_representation.do_all (
				agent replace_configuration_tokens)
			if settings.has (Start_server_cmd_specifier) then
				start_server_commands.extend (create {SESSION_COMMAND}.make (
				Start_server_cmd_specifier,
				settings @ Start_server_cmd_specifier))
			end
			if settings.has (Start_cl_client_cmd_specifier) then
				create {SESSION_COMMAND}
					start_command_line_client_command.make (
						Start_cl_client_cmd_specifier,
						settings @ Start_cl_client_cmd_specifier)
			end
			if settings.has (Chart_cmd_specifier) then
				create {SESSION_COMMAND} chart_command.make (
					Chart_cmd_specifier, settings @ Chart_cmd_specifier)
			end
			if settings.has (Termination_cmd_specifier) then
				create {SESSION_COMMAND} termination_command.make (
					Termination_cmd_specifier,
					settings @ Termination_cmd_specifier)
			end
			if
				default_start_server_command = Void and then
				not start_server_commands.is_empty
			then
				default_start_server_command := start_server_commands.first
			end
		end

	check_results is
		do
			--!!!Stub
		end

	use_customized_setting (key, value: STRING): BOOLEAN is
		do
			if in_begin_block then
				Result := True
			else
				Result := key.is_equal (Begin_tag)
				if Result then
					in_begin_block := True
					if
						value /= Void and then
						value.is_equal (Start_server_cmd_specifier)
					then
						in_start_server_cmd := True
						current_cmd_is_default := False
					end
				end
			end
		end

	do_customized_setting (key, value: STRING) is
		do
			if in_begin_block then
				if key.is_equal (End_tag) then
					in_begin_block := False
					if in_start_server_cmd then
						make_start_server_cmd
					end
				elseif in_start_server_cmd then
					process_start_server_cmd (key, value)
				end
			end
		end

feature {NONE} -- Implementation

	in_begin_block: BOOLEAN
			-- Are we currently within a "begin" block?

	in_start_server_cmd: BOOLEAN
			-- Does the current block define a "start-server" command?

	has_token (s: STRING): BOOLEAN is
			-- Does `s' have a "<...>" token?
		do
			if
				s.has (Token_start_delimiter) and
				s.has (Token_end_delimiter)
			then
				Result :=
					s.substring_index (
						token_from (Data_directory_specifier), 1) > 0 or
					s.substring_index (
						token_from (Bin_directory_specifier), 1) > 0 or
					s.substring_index (token_from (Hostname_specifier), 1) > 0
			end
		end

	replace_configuration_tokens (s: STRING) is
		do
			replace_tokens (s, <<Data_directory_specifier,
				Bin_directory_specifier, Hostname_specifier>>,
				<<data_directory, bin_directory, hostname>>,
				Token_start_delimiter, Token_end_delimiter)
		end

	process_start_server_cmd (key, value: STRING) is
			-- Process a block-definition of a start-server command.
		do
			if key.is_equal (Command_specifier) then
				current_cmd_string := value
			elseif key.is_equal (Command_description_specifier) then
				current_cmd_desc := value
			elseif key.is_equal (Command_name_specifier) then
				current_cmd_name := value
			elseif
				key.is_equal (Mark_specifier) and
				value.is_equal (Default_mark)
			then
				current_cmd_is_default := True
			end
		end

	make_start_server_cmd is
			-- Make a 'start-server' command and add it to `external_commands'.
		local
			c: SESSION_COMMAND
		do
			replace_configuration_tokens (current_cmd_string)
			create c.make (Start_server_cmd_specifier, current_cmd_string)
			c.set_name (current_cmd_name)
			c.set_description (current_cmd_desc)
			if current_cmd_is_default then
				default_start_server_command := c
			end
			start_server_commands.extend (c)
		end

	current_cmd_string, current_cmd_desc, current_cmd_name: STRING

	current_cmd_is_default: BOOLEAN

end
