indexing

	description:
		"Basic constants and queries specifying communication protocol %
		%components that are used by more than one application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	BASIC_COMMUNICATION_PROTOCOL

feature -- String constants

	message_component_separator: STRING is "%T"
			-- Character used to separate top-level message components

	message_record_separator: STRING is "%N"
			-- Character used to separate "records" or "lines" within
			-- a message component

	message_date_field_separator: STRING is deferred end
			-- Sub-field separator for date fields contained in messages

	message_time_field_separator: STRING is deferred end
			-- Sub-field separator for time fields contained in messages

invariant

end
