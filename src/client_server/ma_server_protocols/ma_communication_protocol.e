indexing

	description:
		"Constants specifying the basic components of the TA server %
		%communication protocol"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class

	NETWORK_PROTOCOL

feature -- String constants

	eom: STRING is ""

	input_field_separator: STRING is "%T"

	output_field_separator: STRING is "%T"

	date_field_separator: STRING is "/"

invariant

	eom_size: eom.count = 1

end -- class NETWORK_PROTOCOL
