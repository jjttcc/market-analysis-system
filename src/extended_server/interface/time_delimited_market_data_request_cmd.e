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
			expected_field_count, set_print_parameters, parse_remainder,
			additional_field_constraints_fulfilled,
			additional_field_constraints_msg
		end

creation

	make

feature {NONE} -- Hook routine implementations

	parse_remainder (fields: LIST [STRING]) is
		local
			split_result: LIST [STRING]
			time: TIME; date: DATE
			date_time_range: STRING
			start_date_time_string, end_date_time_string: STRING
		do
			parse_error := False
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
					start_date_time := parsed_date_time (start_date_time_string)
				end
				if end_date_time_string /= Void then
					end_date_time := parsed_date_time (end_date_time_string)
				end
			end
			if not parse_error then
				parse_error := start_date_time = Void
			end
		ensure
			start_date_set_if_no_error:
				not parse_error implies start_date_time /= Void
		end

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := fields.i_th (date_time_spec_index) /= Void and then
				not fields.i_th (date_time_spec_index).is_empty
		ensure
			true_iff_not_empty: Result = (fields.i_th (date_time_spec_index) /=
				Void and then not fields.i_th (date_time_spec_index).is_empty)
		end

	additional_field_constraints_msg: STRING is "date-time range field is emtpy"

feature {NONE} -- Implementation - essential properties

	start_date_time, end_date_time: DATE_TIME
			-- The start and end date-times for the request

feature {NONE} -- Redefined routines

	parsed_date_time (date_time_string: STRING): DATE_TIME is
			-- DATE_TIME parsed from `date_time_string' - Void if
			-- `date_time_string' is not in the right format
		local
			time_tool: expanded DATE_TIME_SERVICES
			split_result: LIST [STRING]
			time: TIME; date: DATE
			date_string: STRING
			time_string: STRING
		do
			split_result := date_time_string.split (
				date_time_separator @ 1)
			if split_result.count = 2 then
				date_string := split_result @ 1
				time_string := split_result @ 2
			end
			if
				date_string /= Void and time_string /= Void
			then
				date := time_tool.date_from_string (date_string,
					date_field_separator)
				time := time_tool.time_from_string (time_string,
					time_field_separator)
				if date /= Void and time /= Void then
					create Result.make_by_date_time (date, time)
				end
			end
		end

	expected_field_count: INTEGER is 3

	set_print_parameters is
		do
			print_start_date := start_date_time.date
			print_start_time := start_date_time.time
--!!!Make sure 'start_date_time.time' is used for "printing" the data.
			if end_date_time.date /= Void then
				print_end_date := end_date_time.date
				print_end_time := end_date_time.time
			else
				print_end_date := Void
				print_end_time := Void
			end
		end

feature {NONE} -- Implementation - constants

	date_time_spec_index: INTEGER is 3

end
