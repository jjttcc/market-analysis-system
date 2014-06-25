note
	description: "Constants used for processing configuration files"
	author: "Jim Cochrane"
	date: "$Date$"
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	GENERAL_CONFIGURATION_CONSTANTS

feature -- Access

	comment_character: CHARACTER = '#'
			-- Character that, when occurring at the beginning of a line,
			-- denotes a comment

	token_start_delimiter: CHARACTER = '<'
			-- Delimiter indicating the start of a replacable token

	token_end_delimiter: CHARACTER = '>'
			-- Delimiter indicating the end of a replacable token

	eod_start_date_specifier: STRING = "eod_start_date"
			-- Specifier token for the end-of-day-data 'start-date' setting

	eod_end_date_specifier: STRING = "eod_end_date"
			-- Specifier token for the end-of-day-data 'end-date' setting

	intraday_start_date_specifier: STRING = "intraday_start_date"
			-- Specifier token for the intraday-data 'start-date' setting

	intraday_end_date_specifier: STRING = "intraday_end_date"
			-- Specifier token for the intraday-data 'end-date' setting

	january_is_zero_specifier: STRING = "months_start_at_zero"
			-- Specifier token for indicating if months start at zero
			-- instead of 1

end
