indexing
	description: "Common constants used by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class GLOBAL_CONSTANTS

feature -- Access

	Date_field_separator: STRING is "/"
			-- Default field separator of date fields from input

	Time_field_separator: STRING is ":"
			-- Default field separator of time fields from input

end
