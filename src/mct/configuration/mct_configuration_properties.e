note
	description: "Constants and other properties used for processing the %
		%MAS Control Terminal configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	Valid_port_numbers_specifier: STRING = "valid_portnumbers"

	Server_report_port_number_specifier: STRING = "server_report_port_number"

	Hostname_specifier: STRING = "hostname"

	Local_hostname: STRING = "localhost"

	Start_session_specifier: STRING = "start_session_on_startup"

	Start_charts_specifier: STRING = "start_charts_on_startup"

	Working_directory_specifier: STRING = "cwdir"

	Environment_variable_specifier: STRING = "environment_variable"

	Environment_variable_append_specifier: STRING
		"add_to_environment_variable"

	Port_number_specifier: STRING = "portnumber"

	Start_server_cmd_specifier: STRING = "start_server_command"

	Start_cl_client_cmd_specifier: STRING = "start_cl_client_command"

	Chart_cmd_specifier: STRING = "chart_command"

	Termination_cmd_specifier: STRING = "termination_command"

	Built_in_termination_cmd_specifier: STRING = "terminate_server"

	Browse_docs_cmd_specifier: STRING = "browse_docs_command"

	Browse_intro_cmd_specifier: STRING = "browse_intro_command"

	Browse_faq_cmd_specifier: STRING = "browse_faq_command"

	Command_specifier: STRING = "command"

	Command_description_specifier: STRING = "command_description"

	Command_name_specifier: STRING = "command_name"

	User_definition_specifier: STRING = "define"

	Mark_specifier: STRING = "mark"

	Valid_port_numbers_separator: CHARACTER = ','

	Sub_field_separator: CHARACTER = ':'

	Default_mark: STRING = "default"

	Mct_dir_env_var: STRING = "MCT_DIR"

feature {NONE} -- Implementation - Hook routines

	process_host_name: STRING
			-- The name of the local host for this process
		do
			Result := (create {HOST_ADDRESS}.make).local_host_name
			if Result = Void or else Result.is_empty then
				Result := Local_hostname
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Utilities

	token_from (s: STRING): STRING
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
