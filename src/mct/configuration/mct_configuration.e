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
			post_process_settings
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

	start_server_command: STRING is
		do
			Result := settings @ Start_server_cmd_specifier
		ensure
			not_void: Result /= Void
		end

	start_command_line_client_command: STRING is
		do
			Result := settings @ Start_cl_client_cmd_specifier
		ensure
			not_void: Result /= Void
		end

	chart_command: STRING is
		do
			Result := settings @ Chart_cmd_specifier
		ensure
			not_void: Result /= Void
		end

	termination_command: STRING is
		do
			Result := settings @ Termination_cmd_specifier
		ensure
			not_void: Result /= Void
		end

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

	check_results is
		do
			-- Null routine
		end

	post_process_settings is
		do
			settings.linear_representation.do_all (
				agent replace_configuration_tokens)
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

end
