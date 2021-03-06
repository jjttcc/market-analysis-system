note
	description:
		"Basic abstraction for a value (or tuple of values) for a tradable %
		%(e.g., stock or derivative) that has an associated date/time."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class

	TRADABLE_TUPLE

feature -- Access

	date_time: DATE_TIME
			-- The start date and time of the tuple

	end_date: DATE
			-- The date of the last component if the tuple is associated
			-- with a trading period size larger than a day - otherwise
			-- (daily or intraday trading period size), date_time.date
		do
			Result := date_time.date
		end

	value: DOUBLE
			-- Main value of the tuple
		deferred
		end

	is_intraday: BOOLEAN
			-- Is this tuple associated with an intraday trading period?
			-- Assumption: There will never be an intraday tuple with
			-- a time of midnight.
		do
			Result := not date_time.time.is_equal (midnight)
		ensure
			Result = not date_time.time.is_equal (midnight)
		end

	midnight: TIME
		note
			once_status: global
		once
			create Result.make (0, 0, 0)
		end

feature -- Status report

	has_additional_queries: BOOLEAN
			-- Does the run-time type of Current have additional query
			-- features besides the ones in the ancestor, TRADABLE_TUPLE?
		do
		end

feature {FACTORY, VALUE_SETTER} -- Status setting

	set_date_time (t: DATE_TIME)
			-- Set date_time to `t'.
		require
			not_void: t /= Void
		do
			date_time := t
		ensure
			set: date_time = t and date_time /= Void
		end

invariant

	non_intraday_time_is_midnight:
		date_time /= Void and not is_intraday implies
			date_time.time.is_equal (midnight)

end -- class TRADABLE_TUPLE
