indexing
	description: "Constant values used for http-based data retrieval"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	HTTP_CONSTANTS

feature -- Access

	Start_date_specifier: STRING is "start_date"

	End_date_specifier: STRING is "end_date"

	Host_specifier: STRING is "host"

	Path_specifier: STRING is "path"

	Symbol_file_specifier: STRING is "symbol_file"

	EOD_result_format_specifier: STRING is "eod_result_format"

	EOD_turnover_time_specifier: STRING is "eod_turnover_time"

end
