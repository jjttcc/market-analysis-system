indexing
	description: "Access to globally available singletons and other services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class

	GLOBAL_SERVICES

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
			until
				i = type_names.count + 1
			loop
				Result.extend (period_types @ (type_names @ i))
				i := i + 1
			end
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

feature -- Status report

	valid_stock_processor (f: MARKET_PROCESSOR): BOOLEAN is
			-- Is `f' a valid processor for a STOCK instance - that is,
			-- are all of its `operators' valid for a STOCK?
		local
			cmds: LIST [COMMAND]
			oi: OPEN_INTEREST
		do
			cmds := f.operators
			Result := True
			from cmds.start until not Result or cmds.exhausted loop
				oi ?= cmds.item
				-- Currently, the only invalid operator for a STOCK is
				-- open interest.
				if oi /= Void then
					Result := False
				end
				cmds.forth
			end
		end

	is_debugging_on: BOOLEAN_REF is
			-- Is debugging mode on?
		once
			-- Initialize to False - Clients can reset to True.
			create Result
		ensure
			no: not Result.item
		end

feature -- Basic operations

	adjust_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE) is
			-- Adjust `dt' to the starting date/time for a composite
			-- tuple list according to `type'.
		do
			if equal (type.name, (period_type_names @ Weekly)) then
				set_to_previous_monday (dt)
				check
					is_monday: dt.date.day_of_the_week = 2
				end
			elseif equal (type.name, (period_type_names @ Monthly)) then
				dt.date.set_day (1)
			elseif equal (type.name, (period_type_names @ Quarterly)) then
				dt.date.set_day (1)
				dt.date.set_month ((dt.month - 1) // 3 * 3 + 1)
			elseif equal (type.name, (period_type_names @ Yearly)) then
				dt.date.set_day (1)
				dt.date.set_month (1)
			else
			end
		end

	adjust_intraday_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE) is
			-- Adjust `dt' to the starting date/time for an intraday
			-- composite tuple list according to `type'.
		require
			intraday: type.intraday
			no_seconds: type.duration.second = 0
		local
			time_duration: TIME_DURATION
			time: TIME
			new_time_in_seconds: INTEGER
			hour, minute: INTEGER
		do
			time_duration := type.duration.time
			time := dt.time
			check
				duration_less_than_day:
					time_duration.seconds_count < time_duration.seconds_in_day
			end
			new_time_in_seconds := time.seconds -
				(time.seconds \\ time_duration.seconds_count)
			hour := new_time_in_seconds // time.seconds_in_hour
			minute := new_time_in_seconds \\ time.seconds_in_hour //
				time.seconds_in_minute
			dt.make (dt.year, dt.month, dt.day, hour, minute, 0)
		end

	set_to_previous_monday (d: DATE_TIME) is
			-- If `d' is not a Monday, set its value to the Monday
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

	set_to_first_weekday_of_month (d: DATE_TIME) is
			-- Set `d' to the first weekday of `d's month.
		require
			d_not_void: d /= Void
		do
			d.date.set_day (1)
			if d.date.day_of_the_week = 1 or d.date.day_of_the_week = 7 then
				if d.date.day_of_the_week = 1 then
					d.date.day_add(1)
				elseif d.date.day_of_the_week = 7 then
					d.date.day_add(2)
				end
			end
		ensure
			weekday: d.date.day_of_the_week > 1 and d.date.day_of_the_week < 7
		end

end -- class GLOBAL_SERVICES
