indexing
	description: "General facilities relevant to TIME_PERIOD_TYPEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	PERIOD_TYPE_FACILITIES

inherit

	GENERIC_SORTING [TIME_PERIOD_TYPE, INTEGER]
		rename
			duplicates as sorted_duplicates
		export
			{NONE} all
			{ANY} is_sorted_ascending
		end

feature -- Access

	One_minute: INTEGER is 1
			-- 1-minute index for `period_type_names'
	Two_minute: INTEGER is 2
			-- 2-minute index for `period_type_names'
	Five_minute: INTEGER is 3
			-- 5-minute index for `period_type_names'
	Ten_minute: INTEGER is 4
			-- 10-minute index for `period_type_names'
	Fifteen_minute: INTEGER is 5
			-- 15-minute index for `period_type_names'
	Twenty_minute: INTEGER is 6
			-- 20-minute index for `period_type_names'
	Thirty_minute: INTEGER is 7
			-- 30-minute index for `period_type_names'
	Hourly: INTEGER is 8
			-- Hourly index for `period_type_names'
	Daily: INTEGER is 9
			-- Daily index for `period_type_names'
	Weekly: INTEGER is 10
			-- Weekly index for `period_type_names'
	Monthly: INTEGER is 11
			-- Monthly index for `period_type_names'
	Quarterly: INTEGER is 12
			-- Quarterly index for `period_type_names'
	Yearly: INTEGER is 13
			-- Yearly index for `period_type_names'

	period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system, indexed by name
		local
			i: INTEGER
			keys: ARRAY [STRING]
		once
			create Result.make (1)
			from
				keys := nonintraday_period_types.current_keys
				i := 1
			until
				i = keys.count + 1
			loop
				Result.extend (nonintraday_period_types @ (keys @ i), keys @ i)
				i := i + 1
			end
			from
				keys := intraday_period_types.current_keys
				i := 1
			until
				i = keys.count + 1
			loop
				Result.extend (intraday_period_types @ (keys @ i), keys @ i)
				i := i + 1
			end
		end

	nonintraday_period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All time period types used by the system, indexed by name,
			-- whose duration is greater than or equal to a day.
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			create tbl.make (3)
			-- daily
			create duration.make (0, 0, 1, 0, 0, 0)
			check duration.day = 1 end
			create type.make (duration)
			check
				not_in_table2: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			-- weekly
			create duration.make (0, 0, 7, 0, 0, 0)
			check duration.day = 7 end
			create type.make (duration)
			check
				not_in_table3: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			-- monthly
			create duration.make (0, 1, 0, 0, 0, 0)
			check duration.month = 1 end
			create type.make (duration)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			-- quarterly
			create duration.make (0, 3, 0, 0, 0, 0)
			check duration.month = 3 end
			create type.make (duration)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			-- yearly
			create duration.make (1, 0, 0, 0, 0, 0)
			check duration.year = 1 end
			create type.make (duration)
			check
				not_in_table4: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			Result := tbl
		end

	intraday_period_types: HASH_TABLE [TIME_PERIOD_TYPE, STRING] is
			-- All intraday period types used by the system, indexed by name,
			-- whose duration is less than a day.
		local
			type: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			tbl: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
			i: INTEGER
		once
			i := 1
			create tbl.make (3)
			-- 1-minute
			create duration.make (0, 0, 0, 0, 1, 0)
			check duration.minute = 1 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, One_minute)
			-- 2-minute
			create duration.make (0, 0, 0, 0, 2, 0)
			check duration.minute = 2 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Two_minute)
			-- 5-minute
			create duration.make (0, 0, 0, 0, 5, 0)
			check duration.minute = 5 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Five_minute)
			-- 10-minute
			create duration.make (0, 0, 0, 0, 10, 0)
			check duration.minute = 10 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Ten_minute)
			-- 15-minute
			create duration.make (0, 0, 0, 0, 15, 0)
			check duration.minute = 15 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Fifteen_minute)
			-- 20-minute
			create duration.make (0, 0, 0, 0, 20, 0)
			check duration.minute = 20 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Twenty_minute)
			-- 30-minute
			create duration.make (0, 0, 0, 0, 30, 0)
			check duration.minute = 30 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Thirty_minute)
			-- hourly
			create duration.make (0, 0, 0, 1, 0, 0)
			check duration.hour = 1 end
			create type.make (duration)
			check
				not_in_table1: not tbl.has (type.name)
			end
			tbl.extend (type, type.name)
			intraday_period_type_names.force (type.name, Hourly)
			Result := tbl
		end

	period_types_in_order: LIST [TIME_PERIOD_TYPE] is
			-- All time period types sorted in ascending order by
			-- duration such that: (Result @ One_minute) is the
			-- one-minute period type .. (Result @ Yearly) is the
			-- yearly period type
		local
			type_names: ARRAY [STRING]
			i: INTEGER
		once
			create {LINKED_LIST [TIME_PERIOD_TYPE]} Result.make
			type_names := period_type_names
			from
				i := 1
			invariant
				sorted: i > 2 implies Result @ (i - 1) > Result @ (i - 2)
			until
				i = type_names.count + 1
			loop
				Result.extend (period_types @ (type_names @ i))
				i := i + 1
			end
		ensure
			sorted: is_sorted_ascending (Result)
		end

	period_type_names: ARRAY [STRING] is
			-- The name of each element of `period_types' in ascending
			-- order by duration
		local
			tpt: TIME_PERIOD_TYPE
			duration: DATE_TIME_DURATION
			t: HASH_TABLE [TIME_PERIOD_TYPE, STRING]
		once
			-- Force intraday_period_type_names to be created.
			t := intraday_period_types
			create Result.make (1, 1)
			create duration.make (0, 0, 0, 0, 1, 0)
			create tpt.make (duration)
			Result := clone (intraday_period_type_names)
			Result.force (tpt.Daily, Daily)
			Result.force (tpt.Weekly, Weekly)
			Result.force (tpt.Monthly, Monthly)
			Result.force (tpt.Quarterly, Quarterly)
			Result.force (tpt.Yearly, Yearly)
		end

	intraday_period_type_names: ARRAY [STRING] is
		once
			create Result.make (1, 1)
		end

end
