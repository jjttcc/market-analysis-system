indexing
	description: "Global features needed by the server"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVER

feature -- Access

	sessions: HASH_TABLE [SESSION, INTEGER] is
			-- Registered GUI Client sessions
		once
			!!Result.make(1)
		end

	command_line_options: TA_COMMAND_LINE is
		once
			!!Result.make
		end

end -- GLOBAL_SERVER
