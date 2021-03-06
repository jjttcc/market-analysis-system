note
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class INPUT_MEDIUM_BASED_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			close_input_medium, pre_initialize_input_medium,
			post_initialize_input_medium, input_medium
		end

	TIMING_SERVICES
		export
			{NONE} all
		end

feature {NONE} -- Implementation

	initialize_input_medium
		deferred
		ensure then
			open_if_no_error: not fatal_error implies
				input_medium.exists and then not input_medium.is_closed
			open_read_if_no_error: not fatal_error implies
				input_medium.is_open_read
		end

feature {NONE} -- Hook routine implementations

	close_input_medium
		do
			if not input_medium.is_closed then
				input_medium.close
			end
			add_timing_data ("Opening, reading, and closing data for " +
				symbol_list.item)
			report_timing
		end

	pre_initialize_input_medium
		do
			start_timer
		end

	post_initialize_input_medium
		do
			input_medium.set_field_separator (tradable_factory.field_separator)
			input_medium.set_record_separator (
				tradable_factory.record_separator)
		end

feature {NONE} -- Implementation - attributes

	input_medium: INPUT_MEDIUM

invariant

end
