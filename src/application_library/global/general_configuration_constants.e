indexing
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GENERAL_CONFIGURATION_CONSTANTS

feature -- Access

	Comment_character: CHARACTER is '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	token_start_delimiter: CHARACTER is '<'
			-- Delimiter indicating the start of a replacable token

	token_end_delimiter: CHARACTER is '>'
			-- Delimiter indicating the end of a replacable token

	EOD_start_date_specifier: STRING is "eod_start_date"
			-- Specifier token for the end-of-day-data 'start-date' setting

	EOD_end_date_specifier: STRING is "eod_end_date"
			-- Specifier token for the end-of-day-data 'end-date' setting

	Intraday_start_date_specifier: STRING is "intraday_start_date"
			-- Specifier token for the intraday-data 'start-date' setting

	Intraday_end_date_specifier: STRING is "intraday_end_date"
			-- Specifier token for the intraday-data 'end-date' setting

end
