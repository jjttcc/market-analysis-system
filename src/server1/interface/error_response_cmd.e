indexing
	description: "A request command that responds to an invalid client data %
		%request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ERROR_RESPONSE_CMD inherit

	MAS_REQUEST_COMMAND

creation

	make

feature -- Basic operations

	do_execute (msg: STRING) is
		do
			put (concatenation (<<Error.out, message_field_separator,
				msg, eom>>))
		end

end -- class ERROR_RESPONSE_CMD
