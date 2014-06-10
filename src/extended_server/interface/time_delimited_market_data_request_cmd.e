note
	description:
		"A command that responds to a client request for market data %
		%delimited by a start date-time and an end date-time"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class TIME_DELIMITED_MARKET_DATA_REQUEST_CMD inherit

	MARKET_DATA_REQUEST_CMD
		undefine
			set_print_parameters, parse_remainder,
			additional_field_constraints_fulfilled,
			additional_post_parse_constraints_fulfilled,
			additional_field_constraints_msg, ignore_tradable_cache
		redefine
			expected_field_count, update_retrieved_tradable
		end

	TIME_DELIMITED_DATA_REQUEST_CMD
		undefine
			create_and_send_response, update_retrieved_tradable
		end

creation

	make

feature {NONE} -- Hook routine implementations

	update_retrieved_tradable: BOOLEAN = True

feature {NONE} -- Redefined routines

	expected_field_count: INTEGER = 3

feature {NONE} -- Implementation - constants

	date_time_spec_index: INTEGER = 3

end
