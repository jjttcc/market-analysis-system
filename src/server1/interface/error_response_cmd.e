indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class ERROR_RESPONSE_CMD inherit

	REQUEST_COMMAND

feature -- Basic operations

	execute (msg: STRING) is
		do
			-- Simple stub for now:
			print_list (<<Error.out, output_field_separator, msg, eom>>)
		end

end -- class ERROR_RESPONSE_CMD
