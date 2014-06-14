note
	description: "Constant values used for http-based data retrieval"
	author: "Jim Cochrane"
	note1: "@@Note: If the other http classes become used for other types %
		%of data retrieval (socket, etc.), it may be appropriate to rename %
		%this class as something like DATA_RETRIEVAL_CONSTANTS"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	HTTP_CONSTANTS

inherit

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

feature -- Access

	Host_specifier: STRING = "host"
			-- Specifier token for the host component of the http address

	Path_specifier: STRING = "path"
			-- Specifier token for the path component of the http address

	Proxy_address_specifier: STRING = "proxy_address"
			-- Specifier token for the proxy address

	Proxy_port_number_specifier: STRING = "proxy_port_number"
			-- Specifier token for the proxy port number

	Symbol_file_specifier: STRING = "symbol_file"
			-- Specifier token for the file containing symbols of all
			-- tradables to be retrieved

	Post_process_command_specifier: STRING = "post_process_command"
			-- Specifier token for the command to convert retrieved data
			-- into MAS format

	EOD_turnover_time_specifier: STRING = "eod_turnover_time"
			-- Specifier token for the end-of-day turnover time setting

	Output_field_separator_specifier: STRING = "output_field_separator"
			-- Specifier token for the output-field-separator setting

	Ignore_day_of_week_specifier: STRING = "ignore_day_of_week"
			-- Specifier token for "ignore-day_of_week" settings

	data_cache_subdirectory: STRING = "cached_data"
			-- Subdirectory into which cached data files are to be placed

end
