indexing

	description:
		"Constants specifying the basic components of the MA server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	NETWORK_PROTOCOL

feature -- String constants

	Eom: STRING is ""
			-- End of message specifier

	Eot: STRING is ""
			-- End of transmission specifier - for command-line clients

	Console_flag: CHARACTER is 'C'
			-- Flag indicating that the client is a console

	Compression_on_flag: STRING is "<@z@>"
			-- Flag (at beginning of a message) that indicates that
			-- the message is compressed

	Message_field_separator: STRING is "%T"
			-- Field separator for messages sent and received by the server

	Message_record_separator: STRING is "%N"
			-- Record separator for messages sent and received by the server

	message_date_field_separator: STRING is deferred end
			-- Sub-field separator for date fields contained in messages

	message_time_field_separator: STRING is deferred end
			-- Sub-field separator for time fields contained in messages

invariant

	eom_size: eom.count = 1

end -- class NETWORK_PROTOCOL
