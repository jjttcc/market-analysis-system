indexing
	description: "Access to globally available singletons and other services"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVICES

feature -- Access

	Hourly, Daily, Weekly, Monthly: INTEGER is unique
			-- Indexes for `period_type_names'

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			!!tbl.make (3)
			!!duration.make (0, 0, 0, 1, 0, 0)
			check duration.hour = 1 end
			!!type.make (period_type_names @ Hourly, duration, false)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 1, 0, 0, 0)
			check duration.day = 1 end
			!!type.make (period_type_names @ Daily, duration, false)
			check
				not_in_table2: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 7, 0, 0, 0)
			check duration.day = 7 end
			!!type.make (period_type_names @ Weekly, duration, false)
			check
				not_in_table3: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 1, 0, 0, 0, 0)
			check duration.month = 1 end
			!!type.make (period_type_names @ Monthly, duration, false)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			Result := tbl
		end

	period_type_names: ARRAY [STRING] is
			-- The name of each element of `period_types'
		once
			-- Instructions for adding a new period type name:
			-- Add a new index as part of the unique period type name index
			-- definition above; keep the index definitions in order from
			-- smallest duration to largest.  If the new index is for a
			-- time period that is smaller than any existing one, use it
			-- for the minindex argument for the array creation below; if
			-- the new index is for a larger time period than any existing
			-- one, use it for the maxindex argument.  Add a Result.put call
			-- for the new index and time period name.
			!!Result.make (Hourly, Monthly)
			Result.put ("hourly", Hourly)
			Result.put ("daily", Daily)
			Result.put ("weekly", Weekly)
			Result.put ("monthly", Monthly)
		end

	concatenation (a: ARRAY [ANY]): STRING is
			-- A string containing a concatenation of all elements of `a'
		require
			not_void: a /= Void
		local
			i: INTEGER
		do
			!!Result.make (0)
			from
				i := 1
			until
				i = a.count + 1
			loop
				Result.append ((a @ i).out)
				i := i + 1
			end
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
