indexing
	description: "Access to globally available singletons and other services"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVICES

feature -- Access

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
		once
			!!Result.make (3)
			!!duration.make (0, 0, 0, 1, 0, 0)
			check duration.hour = 1 end
			!!type.make ("hourly", duration, false)
			check
				not_in_table1: not Result.has (type.name)
			end
			Result.extend (type, type.name)
			!!duration.make (0, 0, 1, 0, 0, 0)
			check duration.day = 1 end
			!!type.make ("daily", duration, false)
			check
				not_in_table2: not Result.has (type.name)
			end
			Result.extend (type, type.name)
			!!duration.make (0, 0, 7, 0, 0, 0)
			check duration.day = 7 end
			!!type.make ("weekly", duration, false)
			check
				not_in_table3: not Result.has (type.name)
			end
			Result.extend (type, type.name)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		once
		end

feature -- Basic operations

	adjust_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE) is
			-- Adjust the starting date/time for a composite tuple list
			-- according to `type'.
		do
			if equal (type.name, "weekly") then
				-- !!!When implemented, use the flyweight date_time table.
				set_to_previous_monday (dt)
				check
					is_monday: dt.date.day_of_the_week = 2
				end
			else -- ...
			end
		end

	set_to_previous_monday (d: DATE_TIME) is
			-- If d is not a Monday, set its value to the Monday
			-- preceding its current value.
		require
			d /= Void
		do
			if d.date.day_of_the_week /= 2 then
				d.day_add (- ((d.date.day_of_the_week + 7 - 2) \\ 7))
			end
		ensure
			set_to_monday: d.date.day_of_the_week = 2
		end

end -- GLOBAL_SERVICES
