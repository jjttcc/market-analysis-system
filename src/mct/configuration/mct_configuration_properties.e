indexing
	description: "Constants and other properties used for processing the %
		%MAS Control Terminal configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

deferred class MCT_CONFIGURATION_PROPERTIES inherit

	CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

	REPORT_BACK_PROTOCOL
		export
			{NONE} all
		end

feature -- Access

	Valid_port_numbers_specifier: STRING is "valid_portnumbers"

	Server_report_port_number_specifier: STRING is "server_report_port_number"

	Hostname_specifier: STRING is "hostname"

	Working_directory_specifier: STRING is "cwdir"

	Environment_variable_specifier: STRING is "environment_variable"

	Environment_variable_append_specifier: STRING is
		"add_to_environment_variable"

	Port_number_specifier: STRING is "portnumber"

	Start_server_cmd_specifier: STRING is "start_server_command"

	Start_cl_client_cmd_specifier: STRING is "start_cl_client_command"

	Chart_cmd_specifier: STRING is "chart_command"

	Termination_cmd_specifier: STRING is "termination_command"

	Browse_docs_cmd_specifier: STRING is "browse_docs_command"

	Browse_intro_cmd_specifier: STRING is "browse_intro_command"

	Browse_faq_cmd_specifier: STRING is "browse_faq_command"

	Command_specifier: STRING is "command"

	Command_description_specifier: STRING is "command_description"

	Command_name_specifier: STRING is "command_name"

	User_definition_specifier: STRING is "define"

	Mark_specifier: STRING is "mark"

	Valid_port_numbers_separator: CHARACTER is ','

	Sub_field_separator: CHARACTER is ':'

	Default_mark: STRING is "default"

	Mct_dir_env_var: STRING is "MCT_DIR"

feature {NONE} -- Implementation - Hook routines

	process_host_name: STRING is
			-- The name of the local host for this process
		do
			Result := (create {HOST_ADDRESS}.make).local_host_name
		end

feature -- Utilities

	token_from (s: STRING): STRING is
			-- Token_start_delimiter + s + Token_end_delimiter
		do
			Result := clone (s)
			Result.prepend_character (Token_start_delimiter)
			Result.append_character (Token_end_delimiter)
		ensure
			result_exists: Result /= Void
			definition: Result.is_equal (Token_start_delimiter.out + s +
				Token_end_delimiter.out)
		end

end
