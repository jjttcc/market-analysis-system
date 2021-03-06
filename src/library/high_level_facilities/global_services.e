note
	description: "Access to globally available singletons and other services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	GLOBAL_SERVICES

inherit

	GENERIC_SORTING [TIME_PERIOD_TYPE, INTEGER]
		rename
			duplicates as sorted_duplicates
		export
			{NONE} all
			{ANY} is_sorted_ascending
		end

	PERIOD_TYPE_FACILITIES

feature -- Status report

	debug_state: DEBUG_STATE
			-- Debugging settings
		note
			once_status: global
		once
			create Result.make
		end

feature -- Basic operations

	adjust_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE)
			-- Adjust `dt' to the starting date/time for a composite
			-- tuple list according to `type'.
		do
			if equal (type.name, (period_type_names @ weekly)) then
				set_to_previous_monday (dt)
				check
					is_monday: dt.date.day_of_the_week = 2
				end
			elseif equal (type.name, (period_type_names @ monthly)) then
				dt.date.set_day (1)
			elseif equal (type.name, (period_type_names @ quarterly)) then
				dt.date.set_day (1)
				dt.date.set_month ((dt.month - 1) // 3 * 3 + 1)
			elseif equal (type.name, (period_type_names @ yearly)) then
				dt.date.set_day (1)
				dt.date.set_month (1)
			else
			end
		end

	adjust_intraday_start_time (dt: DATE_TIME; type: TIME_PERIOD_TYPE)
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

	set_to_previous_monday (d: DATE_TIME)
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

	set_to_first_weekday_of_month (d: DATE_TIME)
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

end
