indexing
	description: "Access to globally available singletons and other services"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVICES

feature -- Access

	Hourly: INTEGER is 1
			-- Hourly index for `period_type_names'
	Daily: INTEGER is 2
			-- Daily index for `period_type_names'
	Weekly: INTEGER is 3
			-- Weekly index for `period_type_names'
	Monthly: INTEGER is 4
			-- Monthly index for `period_type_names'
	Yearly: INTEGER is 5
			-- Yearly index for `period_type_names'

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system, indexed by name
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			!!tbl.make (3)
			!!duration.make (0, 0, 0, 1, 0, 0)
			check duration.hour = 1 end
			!!type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 1, 0, 0, 0)
			check duration.day = 1 end
			!!type.make (duration)
			check
				not_in_table2: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 7, 0, 0, 0)
			check duration.day = 7 end
			!!type.make (duration)
			check
				not_in_table3: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 1, 0, 0, 0, 0)
			check duration.month = 1 end
			!!type.make (duration)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (1, 0, 0, 0, 0, 0)
			check duration.year = 1 end
			!!type.make (duration)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			Result := tbl
		end

	period_type_names: ARRAY [STRING] is
			-- The name of each element of `period_types'
		local
			tpt: TIME_PERIOD_TYPE
		once
			!!Result.make (1, 1)
			period_types.start
			tpt := period_types.item_for_iteration
			Result.force (tpt.Hourly, Hourly)
			Result.force (tpt.Daily, Daily)
			Result.force (tpt.Weekly, Weekly)
			Result.force (tpt.Monthly, Monthly)
			Result.force (tpt.Yearly, Yearly)
		end

feature -- Basic operations

	adjust_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE) is
			-- Adjust the starting date/time for a composite tuple list
			-- according to `type'.
		do
			if equal (type.name, (period_type_names @ Weekly)) then
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

end -- class GLOBAL_SERVICES
