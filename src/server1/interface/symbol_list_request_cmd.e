indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_LIST_REQUEST_CMD inherit

	REQUEST_COMMAND

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			symbols: LIST [STRING]
		do
			send_ok
			symbols := market_list.symbols
			if not symbols.empty then
				from
					symbols.start
				until
					symbols.islast
				loop
					print (symbols.item)
					print ("%N")
					symbols.forth
				end
				print (symbols.last)
			end
			print (eom)
		end

end -- class MARKET_LIST_REQUEST_CMD
