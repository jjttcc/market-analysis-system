indexing
	description:
		"A command that responds to a client request for data %
		%delimited by a start date-time and an end date-time"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

deferred class TIME_DELIMITED_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		undefine
			error_context
		redefine
			set_print_parameters, parse_remainder,
			additional_field_constraints_fulfilled,
			additional_post_parse_constraints_fulfilled,
			additional_field_constraints_msg, ignore_tradable_cache
		end

feature {NONE} -- Hook routine implementations

--!!!!:
	parse_remainder (fields: LIST [STRING]) is
		local
			split_result: LIST [STRING]
			date_time_range: STRING
			start_date_time_string, end_date_time_string: STRING
		do
			parse_error := False
			start_date_time := Void
			end_date_time := Void
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
				if
					start_date_time_string /= Void and
					not start_date_time_string.is_empty
				then
					start_date_time := parsed_date_time (start_date_time_string)
				else
if start_date_time_string = Void then print ("PR - sdts is Void" + "%N") end
if start_date_time_string.is_empty then print ("PR - sdts is EMPTY" + "%N") end
					create start_date_time.make_by_date (
						session.start_dates @ trading_period_type.name)
				end
				if end_date_time_string /= Void then
					end_date_time := parsed_date_time (end_date_time_string)
				end
			end
if start_date_time /= Void then
print ("PR - SDT: " + start_date_time.out + "%N")
end
			if not parse_error then
				parse_error := start_date_time = Void
			end
			if parse_error then
				last_field_parsing_error := invalid_date_spec
				if date_time_range /= Void then
					last_field_parsing_error := last_field_parsing_error +
						": " + date_time_range
				end
			end
		end

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := fields.i_th (date_time_spec_index) /= Void and then
				not fields.i_th (date_time_spec_index).is_empty
		ensure then
			false_if_date_spec_empty:
				(fields.i_th (date_time_spec_index) = Void or else
				fields.i_th (date_time_spec_index).is_empty) implies not Result
		end

	additional_post_parse_constraints_fulfilled: BOOLEAN is
			-- Are the additional constraints required after calling
			-- `parse_remainder', if not `parse_error', fulfilled?
		do
			Result := start_date_time /= Void
		ensure then
			true_iff_start_date_time_exists: Result = (start_date_time /= Void)
		end

	additional_field_constraints_msg: STRING is
		once
			Result := empty_date_range_msg
		end

	ignore_tradable_cache: BOOLEAN is True

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

	set_print_parameters is
		do
			print_end_date := Void
			print_end_time := Void
			check
				expected_parse_remainder_result: not parse_error and then
					start_date_time /= Void
			end
			print_start_date := start_date_time.date
			print_start_time := start_date_time.time
			if end_date_time /= Void then
				print_end_date := end_date_time.date
				print_end_time := end_date_time.time
			end
		end

feature {NONE} -- Hook routines

	date_time_spec_index: INTEGER is
		deferred
		end

feature {NONE} -- Implementation - constants

		empty_date_range_msg: STRING is "date-time range field is emtpy"

		invalid_date_spec: STRING is "invalid date-time specification: "

end
