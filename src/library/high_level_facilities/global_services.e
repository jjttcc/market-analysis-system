indexing
	description: "Access to globally available singletons and other services"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class

	GLOBAL_SERVICES

feature -- Access

	period_types: TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			!!tbl.make (3)
			!!duration.make (0, 0, 0, 1, 0, 0)
			check duration.hour = 1 end
			!!type.make ("hourly", duration, false)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 1, 0, 0, 0)
			check duration.day = 1 end
			!!type.make ("daily", duration, false)
			check
				not_in_table2: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			!!duration.make (0, 0, 7, 0, 0, 0)
			check duration.day = 7 end
			!!type.make ("weekly", duration, false)
			check
				not_in_table3: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			Result := tbl
		end

	--!!!Probably, event type stuff should go into a separate class.
	--!!!GS may use that class to make them globally available.
	--event_types: TABLE [EVENT_TYPE, INTEGER] is
	event_types: ARRAY [EVENT_TYPE] is
			-- All event types known to the system
		once
			!ARRAY [EVENT_TYPE]!Result.make (1, 0)
		end

	create_event_type (name: STRING) is
			-- Create a new EVENT_TYPE with name `name' and add it to
			-- the `event_types' table.
			--!!!More design work needed here re. event type management.
		local
			et: EVENT_TYPE
			i: INTEGER
		do
			i := last_event_ID.item + 1
			last_event_ID.set_item (i)
			!!et.make (name, last_event_ID.item)
			event_types.force (et, last_event_ID.item)
		end

	last_event_type: EVENT_TYPE is
			-- Last created event type
		do
			if last_event_ID.item > 0 then
				Result := event_types @ last_event_ID.item
			end
		end

	last_event_ID: INTEGER_REF is
			-- !!!Temporary hack
		once
			!!Result
			Result.set_item (0)
		end

	function_library: LIST [MARKET_FUNCTION] is
			-- All defined market functions
		once
			!LINKED_LIST [MARKET_FUNCTION]!Result.make
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
			if equal (type.name, "weekly") then
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
