indexing
	description: "Time period types, such as daily, weekly, etc."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TIME_PERIOD_TYPE inherit

creation

	make

feature -- Initialization

	make (nm: STRING; dur: DATE_TIME_DURATION; irreg: BOOLEAN) is
		require
			not_void: nm /= Void and dur /= Void
		do
			name := nm
			irregular := irreg
			duration := dur
		ensure
			not_void: name /= Void and duration /= Void
			set: name = nm and irregular = irreg and duration = dur
		end

feature -- Access

	name: STRING
			-- The name of the type: daily, weekly, or etc.

	irregular: BOOLEAN
			-- Is the duration of the period irregular (e.g., monthly)?

	duration: DATE_TIME_DURATION
			-- Duration of the time period - approximate if irregular = true

feature {NONE} -- Implementation

end -- TIME_PERIOD_TYPE
