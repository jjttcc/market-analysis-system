indexing
	description:
		"A command that responds to a client request for market data %
		%delimited by a start date-time and an end date-time"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TIME_DELIMITED_INDICATOR_DATA_REQUEST_CMD inherit

	INDICATOR_DATA_REQUEST_CMD
		rename
			additional_field_constraints_fulfilled as
			indicator_id_field_constraint_fulfilled,
additional_field_constraints_msg as indicator_id_error_msg
		undefine
			expected_field_count,
			parse_remainder,
			set_print_parameters,
additional_post_parse_constraints_fulfilled
		end

	TIME_DELIMITED_DATA_REQUEST_CMD
		undefine
			send_response_for_tradable
		redefine
			parse_remainder,
			additional_field_constraints_fulfilled
		select
			additional_field_constraints_fulfilled,
			additional_field_constraints_msg
		end

creation

	make

feature {NONE} -- Hook routine implementations

	parse_remainder (fields: LIST [STRING]) is
		do
			parse_indicator_id (fields)
			{TIME_DELIMITED_DATA_REQUEST_CMD} Precursor (fields)
		end

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := indicator_id_field_constraint_fulfilled (fields) and then
				{TIME_DELIMITED_DATA_REQUEST_CMD} Precursor (fields)
		end

	date_time_spec_empty_msg: STRING is "date-time range field is emtpy"

feature {NONE} -- Redefined routines

	expected_field_count: INTEGER is 4

feature {NONE} -- Implementation

	old_remove_date_time_spec_exists (fields: LIST [STRING]): BOOLEAN is
		do
			Result := fields.i_th (date_time_spec_index) /= Void and then
				not fields.i_th (date_time_spec_index).is_empty
		ensure
			true_iff_not_empty: Result = (fields.i_th (date_time_spec_index) /=
				Void and then not fields.i_th (date_time_spec_index).is_empty)
		end

feature {NONE} -- Implementation - constants

	date_time_spec_index: INTEGER is 4

end
