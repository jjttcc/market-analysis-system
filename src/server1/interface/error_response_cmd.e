indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ERROR_RESPONSE_CMD inherit

	REQUEST_COMMAND

feature -- Basic operations

	execute (msg: STRING) is
		do
			-- Simple stub for now:
			print_list (<<Error.out, output_field_separator, msg, eom>>)
		end

end -- class ERROR_RESPONSE_CMD
