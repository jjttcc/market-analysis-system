indexing
	description: "A command that responds to a GUI client request for all %
		%available market symbols"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class MARKET_LIST_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			symbols: LIST [STRING]
		do
			send_ok
			symbols := tradables.symbols
			if not symbols.empty then
				from
					symbols.start
				until
					symbols.islast
				loop
					print (symbols.item)
					print (Output_record_separator)
					symbols.forth
				end
				print (symbols.last)
			end
			print (eom)
		end

end -- class MARKET_LIST_REQUEST_CMD
