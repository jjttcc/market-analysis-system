indexing
	description:
		"Factory that parses an input file and creates a MARKET_EVENT with %
		%the result"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MARKET_EVENT_FACTORY inherit

	FACTORY
		redefine
			product
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
				{ANY}
			event_types_by_key
		end

	EXCEPTIONS
		export {NONE}
			all
		end

feature -- Access

	input_file: FILE is
			-- File containing input data from which to create MARKET_EVENTs
		deferred
		end

	product: MARKET_EVENT

	error_occurred: BOOLEAN
			-- Did an error occur on the last call to execute?

	last_error: STRING
			-- Description of last error that occurred

	field_separator: CHARACTER
			-- Field separator to use in scanning

feature {NONE} -- Implementation

	current_event_type: EVENT_TYPE
			-- Last EVENT_TYPE scanned by `scan_event_type'

	scan_event_type is
			-- Scan the next event ID and set current_event_type to the event
			-- specified by that ID.
		local
			ID: INTEGER
		do
			input_file.read_integer
			ID := input_file.last_integer
			current_event_type := event_types_by_key @ ID
			if current_event_type = Void then
				last_error := concatenation (
					<<"Error occurred inputting event ID:",
					"  ID for non-existent event: ",
					ID, " - from file ",
					input_file.name, " at character ", input_file.index>>)
				error_occurred := true
				raise ("scan_event failed with invalid ID")
			end
		end

	error_init is
			-- Initialize error-handling attributes
		do
			last_error := Void
			error_occurred := false
		end

	skip_field_separator is
			-- Scan the current character - expected to match field_separator.
		do
			input_file.read_character
			if input_file.last_character /= field_separator then
				last_error := concatenation (
					<<"Expected input field separator, '", field_separator,
					"', not encountered while reading ",
						input_file.name, " at character ", input_file.index,
						"%N(Actual character encountered was ",
						input_file.last_character>>)
				error_occurred := true
				raise ("skip_field_separator failed with invalid field %
						%separator")
			end
		end

end -- class MARKET_EVENT_FACTORY
