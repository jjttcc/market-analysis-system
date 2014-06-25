note
	description: "A request command that responds to an invalid client data %
		%request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class ERROR_RESPONSE_CMD inherit

	MAS_REQUEST_COMMAND

creation

	make

feature -- Basic operations

	do_execute (message: ANY)
		local
			msg: STRING
		do
			msg := message.out
			put (concatenation (<<Error.out, message_component_separator,
				msg, eom>>))
		end

end -- class ERROR_RESPONSE_CMD
