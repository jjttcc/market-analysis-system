indexing
	description: "Global features needed by the server"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVER

feature -- Access

	sessions: TABLE [SESSION, INTEGER] is
			-- Registered GUI Client sessions
		once
			!HASH_TABLE [SESSION, INTEGER]!Result.make(1)
		end

end -- GLOBAL_SERVER
x
