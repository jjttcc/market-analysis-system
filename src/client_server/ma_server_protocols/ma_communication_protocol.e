indexing

	description:
		"Constants specifying the basic components of the TA server %
		%communication protocol"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

deferred class

	NETWORK_PROTOCOL

feature -- String constants

	Eom: STRING is ""
			-- End of message specifier

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

invariant

	eom_size: eom.count = 1

end -- class NETWORK_PROTOCOL
