indexing
	description: "Constant values used for http-based data retrieval"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	HTTP_CONSTANTS

inherit

	GENERAL_CONFIGURATION_CONSTANTS
		export
			{NONE} all
		end

feature -- Access

	Host_specifier: STRING is "host"
			-- Specifier token for the host component of the http address

	Path_specifier: STRING is "path"
			-- Specifier token for the path component of the http address

	Symbol_file_specifier: STRING is "symbol_file"
			-- Specifier token for the file containing symbols of all
			-- tradables to be retrieved

	Post_process_command_specifier: STRING is "post_process_command"
			-- Specifier token for the command to convert retrieved data
			-- into MAS format

	EOD_turnover_time_specifier: STRING is "eod_turnover_time"
			-- Specifier token for the end-of-day turnover time setting

	Output_field_separator_specifier: STRING is "output_field_separator"
			-- Specifier token for the output-field-separator setting

	Ignore_day_of_week_specifier: STRING is "ignore_day_of_week"
			-- Specifier token for "ignore-day_of_week" settings

end
