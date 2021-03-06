note
	description:
		"Constants specifying date- and time-communication-protocol components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	DATE_TIME_PROTOCOL

feature -- Access

	date_field_separator: STRING = "/"
			-- Default field separator of date fields from input

	time_field_separator: STRING = ":"
			-- Default field separator of time fields from input

	date_time_range_separator: STRING = ";"
			-- Default character used to separate the start-date-time field
			-- from the end-date-time field in a date-time range
			-- specification

	date_time_separator: STRING = ","
			-- Default character used to separate the date field from
			-- the time field in a date-time range specification

feature -- Basic operations

	date_time_range (start_time, end_time: DATE_TIME): STRING
			-- The date/time-range component of a client data request
		local
			date_tool: expanded DATE_TIME_SERVICES
		do
			Result := ""
			if start_time /= Void then
				Result.append (date_tool.formatted_date (
					start_time.date, 'y', 'm', 'd', date_field_separator))
				Result.append (date_time_separator)
				Result.append (date_tool.formatted_time (
					start_time.time, 'y', 'm', 'd', time_field_separator))
			end
			if end_time /= Void then
				Result.append (date_time_range_separator)
				Result.append (date_tool.formatted_date (
					end_time.date, 'y', 'm', 'd', date_field_separator))
				Result.append (date_time_separator)
				Result.append (date_tool.formatted_time (
					end_time.time, 'y', 'm', 'd', time_field_separator))
			end
		ensure
			exists: Result /= Void
		end

end
