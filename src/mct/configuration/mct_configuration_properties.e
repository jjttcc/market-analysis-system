indexing
	description: "Constants and other properties used for processing the %
		%MAS Control Terminal configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT_CONFIGURATION_PROPERTIES inherit

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

feature -- Constants

	Data_directory_specifier: STRING is "data_dir"

	Bin_directory_specifier: STRING is "bin_dir"

	Doc_directory_specifier: STRING is "doc_dir"

	Valid_port_numbers_specifier: STRING is "valid_portnumbers"

	Hostname_specifier: STRING is "hostname"

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

	Mark_specifier: STRING is "mark"

	Valid_port_numbers_separator: CHARACTER is ','

	Default_mark: STRING is "default"

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
