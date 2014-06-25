note

	description:
		"Constants specifying the basic components of the MA server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MA_COMMUNICATION_PROTOCOL inherit

	BASIC_COMMUNICATION_PROTOCOL

feature -- String constants

	eom: STRING = ""
			-- End of message specifier

	eot: STRING = ""
			-- End of transmission specifier - for command-line clients

	console_flag: CHARACTER = 'C'
			-- Flag indicating that the client is a console

	compression_on_flag: STRING = "<@z@>"
			-- Flag (at beginning of a message) that indicates that
			-- the message is compressed

	message_date_field_separator: STRING deferred end
			-- Sub-field separator for date fields contained in messages

	message_time_field_separator: STRING deferred end
			-- Sub-field separator for time fields contained in messages

invariant

	eom_size: eom.count = 1

end
