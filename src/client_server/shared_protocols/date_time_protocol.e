indexing
	description:
		"Constants specifying date- and time-communication-protocol components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class DATE_TIME_PROTOCOL

feature -- Access

	date_field_separator: STRING is "/"
			-- Default field separator of date fields from input

	time_field_separator: STRING is ":"
			-- Default field separator of time fields from input

	date_time_range_separator: STRING is ";"
			-- Default character used to separate the start-date-time field
			-- from the end-date-time field in a date-time range
			-- specification

	date_time_separator: STRING is ","
			-- Default character used to separate the date field from
			-- the time field

end
