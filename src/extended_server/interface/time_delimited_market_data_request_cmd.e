indexing
	description:
		"A command that responds to a client request for market data %
		%delimited by a start date-time and an end date-time"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TIME_DELIMITED_MARKET_DATA_REQUEST_CMD inherit

	MARKET_DATA_REQUEST_CMD
		redefine
			expected_field_count, set_print_parameters, parse_remainder
		end

creation

	make

feature {NONE} -- Implementation - essential properties

	start_date_time, end_date_time: DATE_TIME
			-- The start and end date-times for the request

feature {NONE} -- Redefined routines

	parse_remainder (fields: LIST [STRING]) is
		local
			time_tool: expanded DATE_TIME_SERVICES
			split_result: LIST [STRING]
			time: TIME; date: DATE
			date_time_range: STRING
			start_date_time_string, end_date_time_string: STRING
			start_date_string, end_date_string: STRING
			start_time_string, end_time_string: STRING
		do
--!!!!NOTE: This is too ugly - break it down into sub-functions.
			date_time_range := fields @ date_time_spec_index
			if date_time_range /= Void then
				split_result := date_time_range.split (
					date_time_range_separator @ 1)
				if split_result.count > 0 then
					start_date_time_string := split_result @ 1
					if split_result.count > 1 then
						end_date_time_string := split_result @ 2
					end
				end
				if start_date_time_string /= Void then
					split_result := start_date_time_string.split (
						date_time_separator @ 1)
					if split_result.count = 2 then
						start_date_string := split_result @ 1
						start_time_string := split_result @ 2
					end
					if
						start_date_string /= Void and start_time_string /= Void
					then
						date := time_tool.date_from_string (start_date_string,
							date_field_separator)
						time := time_tool.time_from_string (start_time_string,
							time_field_separator)
						if date /= Void and time /= Void then
							create start_date_time.make_by_date_time (date,
								time)
						end
					end
				end
				if end_date_time_string /= Void then
					split_result := end_date_time_string.split (
						date_time_separator @ 1)
					if split_result.count = 2 then
						end_date_string := split_result @ 1
						end_time_string := split_result @ 2
					end
					if
						end_date_string /= Void and end_time_string /= Void
					then
						date := time_tool.date_from_string (end_date_string,
							date_field_separator)
						time := time_tool.time_from_string (end_time_string,
							time_field_separator)
						if date /= Void and time /= Void then
							create end_date_time.make_by_date_time (date, time)
						end
					end
				end
			end
			if not parse_error then
				parse_error := start_date_time = Void
			end
		ensure
			start_date_set_if_no_error:
				not parse_error implies start_date_time /= Void
		end

	expected_field_count: INTEGER is 3

	set_print_parameters is
		do
			print_start_date := start_date_time.date
--			print_start_time := start_date_time.time
--!!!Make sure 'start_date_time.time' is used for "printing" the data.
			if end_date_time.date /= Void then
				print_end_date := end_date_time.date
--				print_end_time := end_time_time.time
			else
				print_end_date := Void
--				print_end_time := Void
			end
		end

feature {NONE} -- Implementation - constants

	date_time_spec_index: INTEGER is 3

end
