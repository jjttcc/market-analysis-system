indexing
	description: "A request command that responds to an invalid client data %
		%request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class ERROR_RESPONSE_CMD inherit

	REQUEST_COMMAND

creation

	make

feature -- Basic operations

	do_execute (msg: STRING) is
		do
			put (concatenation (<<Error.out, output_field_separator,
				msg, eom>>))
		end

end -- class ERROR_RESPONSE_CMD
