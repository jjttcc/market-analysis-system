indexing
	description: "Abstraction for holding session-specific data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class SESSION inherit

creation

	make

feature {NONE} -- Initialization

	make is
		do
			create start_dates.make(1)
			create end_dates.make(1)
		ensure
			dates_not_void: start_dates /= Void and end_dates /= Void
		end

feature -- Access

	start_dates: HASH_TABLE [DATE, STRING]
		-- start dates, one (or 0) per time-period type

	end_dates: HASH_TABLE [DATE, STRING]
		-- end date, one (or 0) per time-period type

end -- class SESSION
