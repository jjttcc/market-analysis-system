indexing
	description:
		"TRADABLE_LISTs that obtain their input data from files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class INPUT_MEDIUM_BASED_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium, close_input_medium
		end

	TIMING_SERVICES
		export
			{NONE} all
		end

feature {NONE} -- Implementation

	setup_input_medium is
		do
			start_timer
			input_medium := initialized_input_medium
print (generating_type + ": input_medium type: " +
input_medium.generating_type + "%N")
			if not fatal_error then
				tradable_factory.set_input (input_medium)
				input_medium.set_field_separator (
					tradable_factory.field_separator)
				input_medium.set_record_separator (
					tradable_factory.record_separator)
			end
		ensure then
			input_medium_open: not fatal_error implies input_medium /= Void
				and then input_medium.exists and then
				not input_medium.is_closed
			input_medium_readable: not fatal_error implies
				input_medium /= Void and then
				input_medium.is_open_read
		end

	close_input_medium is
		do
			if not input_medium.is_closed then
				input_medium.close
			end
			add_timing_data ("Opening, reading, and closing data for " +
				symbol_list.item)
			report_timing
		end

	initialized_input_medium: INPUT_MEDIUM is
			-- An INPUT_MEDIUM, initialized and ready to use
		deferred
		ensure
			result_open: not fatal_error implies Result /= Void and then
				Result.exists and then not Result.is_closed
			result_open_read: Result.is_open_read
		end

feature {NONE} -- Implementation - attributes

	input_medium: INPUT_MEDIUM

invariant

end
