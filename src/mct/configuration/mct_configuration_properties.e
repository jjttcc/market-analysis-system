indexing
	description: "Constants used for processing the MAS Control Terminal %
		%configuration file"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MCT_CONFIGURATION_CONSTANTS inherit

	GENERAL_CONFIGURATION_CONSTANTS

feature -- Constants

	Data_directory_specifier: STRING is "data_dir"

	Bin_directory_specifier: STRING is "bin_dir"

	Valid_port_numbers_specifier: STRING is "valid_portnumbers"

	Hostname_specifier: STRING is "hostname"

	Port_number_specifier: STRING is "portnumber"

	Start_server_cmd_specifier: STRING is "start_server_command"

	Start_cl_client_cmd_specifier: STRING is "start_cl_client_command"

	Chart_cmd_specifier: STRING is "chart_command"

	Termination_cmd_specifier: STRING is "termination_command"

	Valid_port_numbers_separator: CHARACTER is ','

feature -- Utilities

	token_from (s: STRING): STRING is
			-- Token_start_delimiter + s + Token_end_delimiter
		do
			Result := clone (s)
			Result.prepend_character (Token_start_delimiter)
			Result.append_character (Token_end_delimiter)
		end

end
