indexing
	description: "Configuration of environment/platform-dependent settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT_CONFIGURATION inherit

	CONFIGURATION_UTILITIES
		rename
			file_reader as config_file,
			new_file_reader as new_config_file
		export
			{NONE} all
		redefine
			post_process_settings, use_customized_setting,
			do_customized_setting, config_file
		end

	MCT_CONFIGURATION_PROPERTIES
		export
			{NONE} token_from, Begin_tag, End_tag
		end

creation

	make

feature {NONE} -- Initialization

	initialize is
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

	save_command_as_default_failed: BOOLEAN is
			-- Did the last call to `save_command_as_default ' fail?
		do
			Result := config_file.mark_as_default_failed
		end

	save_command_as_default_failure_reason: STRING is
			-- Did the last call to `save_command_as_default ' fail?
		do
			Result := config_file.mark_as_default_failure_reason
		end

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

feature -- Basic operations

	save_command_as_default (cmd: EXTERNAL_COMMAND) is
			-- Save `cmd' in the configuration file as a default command.
		do
			config_file.mark_block_as_default (Command_name_specifier,
				cmd.name, cmd.identifier)
		end

feature {NONE} -- Implementation - Hook routine implementations

	key_index: INTEGER is 1

	value_index: INTEGER is 2

	configuration_type: STRING is "MAS Control Terminal"

	post_process_settings is
		do
			settings.linear_representation.do_all (
				agent replace_configuration_tokens)
			if not settings.item (Start_server_cmd_specifier).is_empty then
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
			if config_file.in_block or config_file.at_end_of_block then
				Result := True
			end
		end

	do_customized_setting (key, value: STRING) is
		do
			check
				in_or_at_end_of_block:
					config_file.in_block xor config_file.at_end_of_block
			end
			if config_file.current_block_is_start_server_cmd then
				if config_file.in_block then
					process_start_server_cmd (key, value)
				else
					check
						at_end_and_start_server: config_file.at_end_of_block
						and config_file.current_block_is_start_server_cmd
					end
					make_start_server_cmd
					current_cmd_is_default := False
				end
			end
		end

	new_config_file: CONFIGURATION_FILE is
		do
			create Result.make (Field_separator, Record_separator)
		end

feature {NONE} -- Implementation

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
		require
			in_block: config_file.in_block
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
		require
			at_end_of_block: config_file.at_end_of_block
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

	config_file: CONFIGURATION_FILE

invariant

	default_start_server_command_exists: default_start_server_command /= Void
	start_server_commands_exist: start_server_commands /= Void
	start_command_line_client_command_exists:
		start_command_line_client_command /= Void
	chart_command_exists: chart_command /= Void
	termination_command_exists: termination_command /= Void

end
