indexing

	description:
		"Constants specifying the basic components of the MA server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MA_COMMUNICATION_PROTOCOL inherit

	BASIC_COMMUNICATION_PROTOCOL
		rename
			message_component_separator as message_field_separator
		end

feature -- String constants

	eom: STRING is ""
			-- End of message specifier

	eot: STRING is ""
			-- End of transmission specifier - for command-line clients

	console_flag: CHARACTER is 'C'
			-- Flag indicating that the client is a console

	compression_on_flag: STRING is "<@z@>"
			-- Flag (at beginning of a message) that indicates that
			-- the message is compressed

	message_date_field_separator: STRING is deferred end
			-- Sub-field separator for date fields contained in messages

	message_time_field_separator: STRING is deferred end
			-- Sub-field separator for time fields contained in messages

invariant

	eom_size: eom.count = 1

end
