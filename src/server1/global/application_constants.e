indexing
	description: "Global constant values used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	APPLICATION_CONSTANTS

feature -- Input/output constants

	Stock_split_field_separator: STRING is "%T"
			-- Field separator for stock split data

	Stock_split_record_separator: STRING is "%N"
			-- Record separator for stock split data

	Event_history_field_separator: STRING is "%/1/"
			-- Field separator for event history file

	Event_history_record_separator: STRING is "%N"
			-- Record separator for event history file

	End_of_file_character: CHARACTER is ''
			-- Character used to denote an "end-of-file" condition

feature -- Default settings

	Default_stock_split_file_name: STRING is "mas_stock_splits"
			-- Default name for stock-split data file

	Default_database_config_file_name: STRING is "mas_dbrc"
			-- Default name for database configuration file

	Default_http_config_file_name: STRING is "mas_httprc"
			-- Default name for http configuration file

	Default_mailer: STRING is "elm"
			-- Default mailer program

	Default_mailer_subject_flag: STRING is "-s"
			-- Default subject flag for mailer program

end -- APPLICATION_CONSTANTS
