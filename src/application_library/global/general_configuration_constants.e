indexing
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GENERAL_CONFIGURATION_CONSTANTS

feature -- Access

	comment_character: CHARACTER is '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	token_start_delimiter: CHARACTER is '<'
			-- Delimiter indicating the start of a replacable token

	token_end_delimiter: CHARACTER is '>'
			-- Delimiter indicating the end of a replacable token

	eod_start_date_specifier: STRING is "eod_start_date"
			-- Specifier token for the end-of-day-data 'start-date' setting

	eod_end_date_specifier: STRING is "eod_end_date"
			-- Specifier token for the end-of-day-data 'end-date' setting

	intraday_start_date_specifier: STRING is "intraday_start_date"
			-- Specifier token for the intraday-data 'start-date' setting

	intraday_end_date_specifier: STRING is "intraday_end_date"
			-- Specifier token for the intraday-data 'end-date' setting

	january_is_zero_specifier: STRING is "months_start_at_zero"
			-- Specifier token for indicating if months start at zero
			-- instead of 1

end
