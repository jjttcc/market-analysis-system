indexing
	description: "MAS database services - UNIX implmentation"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_DB_SERVICES inherit

feature -- Access

	symbols: LIST [STRING] is
			-- All symbols available in the database
		do
			-- (!!!For now, just make an empty list.)
			create {LINKED_LIST[STRING]} Result.make
		end

	market_data (symbol: STRING): LINKED_LIST [DB_RESULT] is
			-- Data for `symbol'
		do
		end

end -- class MAS_DB_SERVICES
