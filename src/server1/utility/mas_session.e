indexing
	description: "Abstraction for holding session-specific data"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class SESSION inherit

creation

	make

feature {NONE} -- Initialization

	make is
		do
			!!start_dates.make(1)
			!!end_dates.make(1)
		ensure
			dates_not_void: start_dates /= Void and end_dates /= Void
		end

feature -- Access

	start_dates: HASH_TABLE [DATE, STRING]
		-- start dates, one (or 0) per time-period type

	end_dates: HASH_TABLE [DATE, STRING]
		-- end date, one (or 0) per time-period type

end -- class SESSION
