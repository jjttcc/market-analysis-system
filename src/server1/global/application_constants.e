indexing
	description: "Global constant values used by the application"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	APPLICATION_CONSTANTS

feature -- Access

	stock_split_field_separator: STRING is "%T"
			-- Field separator for stock split data

	event_history_field_separator: STRING is "%/1/"
			-- Field separator for event history file

	event_history_record_separator: STRING is "%N"
			-- Record separator for event history file

end -- APPLICATION_CONSTANTS
