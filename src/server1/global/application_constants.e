indexing
	description: "Global constant values used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

feature -- Configuration file names

	Default_stock_split_file_name: STRING is "mas_stock_splits"
			-- Default name for stock-split data file

	Default_database_config_file_name: STRING is "mas_dbrc"
			-- Default name for database configuration file

feature -- Miscellaneous

	Comment_character: CHARACTER is '#'

end -- APPLICATION_CONSTANTS
