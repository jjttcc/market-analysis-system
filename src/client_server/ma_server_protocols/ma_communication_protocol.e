indexing

	description:
		"Constants specifying the basic components of the MA server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class

	NETWORK_PROTOCOL

feature -- String constants

	Eom: STRING is ""
			-- End of message specifier

	Eot: STRING is ""
			-- End of transmission specifier - for command-line clients

	Compression_on_flag: STRING is "<@z@>"
			-- Flag (at beginning of a message) that indicates that
			-- the message is compressed

	Input_field_separator: STRING is "%T"
			-- Field separator for input received by the server

	Output_field_separator: STRING is "%T"
			-- Field separator for output produced by the server

	Output_record_separator: STRING is "%N"
			-- Record separator for output produced by the server

	output_date_field_separator: STRING is deferred end
			-- Field separator for date output produced by the server

	date_field_separator: STRING is "/"
			-- Internal field separator for dates

	output_time_field_separator: STRING is deferred end
			-- Field separator for time output produced by the server

	time_field_separator: STRING is ":"
			-- Internal field separator for times

invariant

	eom_size: eom.count = 1

end -- class NETWORK_PROTOCOL
