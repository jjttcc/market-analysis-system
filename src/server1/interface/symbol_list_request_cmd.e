note
	description: "A command that responds to a client request for all %
		%available market symbols"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SYMBOL_LIST_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end


creation

	make

feature {NONE} -- Basic operations

	do_execute (message: ANY)
		local
			msg: STRING
			symbols: LIST [STRING]
		do
			msg := message.out
			put_ok
			symbols := tradables.symbols
			if not symbols.is_empty then
				from
					symbols.start
				until
					symbols.islast
				loop
					put (symbols.item)
					put (message_record_separator)
					symbols.forth
				end
				put (symbols.last)
			end
			put (eom)
		end

	error_context (msg: STRING): STRING
		do
			Result := "retrieving symbol list"
		end

end -- class SYMBOL_LIST_REQUEST_CMD
