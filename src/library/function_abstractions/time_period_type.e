note
	description: "Time period types, such as daily, weekly, etc."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TIME_PERIOD_TYPE inherit

	TIME_PERIOD_TYPE_CONSTANTS
		undefine
			is_equal
		end

	PART_COMPARABLE
		redefine
			is_equal
		end

create

	make

feature {NONE} -- Initialization

	make (dur: DATE_TIME_DURATION)
		require
			not_void: dur /= Void
			no_seconds: dur.second = 0
			not_hours_and_minutes: not (dur.hour /= 0 and dur.minute /= 0)
			year_only: dur.year /= 0 implies dur.month = 0 and dur.day = 0
			month_only: dur.month /= 0 implies dur.year = 0 and dur.day = 0
			day_only: dur.day /= 0 implies dur.year = 0 and dur.month = 0
			days_definite: dur.day /= 0 implies dur.definite
			years_not_definite: dur.year /= 0 implies not dur.definite
			months_not_definite: dur.month /= 0 implies not dur.definite
			nodate_definite: dur.year = 0 and dur.month = 0 and
				dur.day = 0 implies dur.definite
			day_month_or_year_no_time: dur.month /= 0 or dur.year /= 0 or
				dur.day /= 0 implies dur.hour = 0 and dur.minute = 0
			year_month_day_hour_or_minute: dur.year /= 0 or dur.month /= 0 or
				dur.day /= 0 or dur.hour /= 0 or dur.minute /=0
			positive_if_definite: dur.definite implies dur > dur.zero
		do
			duration := dur
			irregular := not duration.definite
			set_name
		ensure
			not_void: name /= Void and duration /= Void
			set: duration = dur
		end

feature -- Access

	name: STRING
			-- The name of the type: daily, weekly, or etc.

	irregular: BOOLEAN
			-- Is the duration of the period irregular (e.g., monthly)?

	duration: DATE_TIME_DURATION
			-- Duration of the time period - approximate if irregular = True

	intraday: BOOLEAN
			-- Is this an intraday time-period type?
		do
			Result := duration.year = 0 and duration.month = 0 and
				duration.day = 0
		end

feature -- Status report

	is_valid: BOOLEAN
			-- Is Current a valid period type?
		do
			Result := not equal (name, invalid_name)
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
		do
			Result := other.name.is_equal (name)
		end

	infix "<" (other: like Current): BOOLEAN
		do
			if duration.definite and other.duration.definite then
				Result := duration < other.duration
			else
				if intraday xor other.intraday then
					Result := intraday
				else
					if duration.year = other.duration.year then
						if duration.month = other.duration.month then
							Result := duration.day < other.duration.day
						else
							Result := duration.month < other.duration.month
						end
					else
						Result := duration.year < other.duration.year
					end
				end
			end
		end

feature {NONE} -- Implementation

	set_name
			-- Set `name' according to the value of duration.
		require
			duration /= Void
		do
			create name.make (0)
			if duration.day /= 0 then
				if duration.day = 1 then
					name.append (daily_name)
				elseif duration.day = 7 then
					name.append (weekly_name)
				else
					name.append (duration.day.out)
					name.append ("-day")
				end
			elseif duration.month /= 0 then
				if duration.month = 1 then
					name.append (monthly_name)
				elseif
					duration.month = 3 and duration.day = 0 and
					duration.year = 0
				then
					name.append (quarterly_name)
				else
					name.append (duration.month.out)
					name.append ("-month")
				end
			elseif duration.year /= 0 then
				if duration.year = 1 then
					name.append (yearly_name)
				else
					name.append (duration.year.out)
					name.append ("-year")
				end
			elseif duration.hour /= 0 then
				if duration.hour = 1 then
					name.append (hourly_name)
				else
					name.append (duration.hour.out)
					name.append ("-hour")
				end
			elseif duration.minute /= 0 then
				name.append (duration.minute.out)
				name.append ("-minute")
			else
				name.append (invalid_name)
			end
		end

invariant

	duration_exists: duration /= Void
	name_exists: name /= Void
	irregular_not_definite: irregular = not duration.definite
	no_seconds: duration.second = 0
	not_hours_and_minutes: not (duration.hour /= 0 and duration.minute /= 0)
	year_only: duration.year /= 0 implies
		duration.month = 0 and duration.day = 0
	month_only: duration.month /= 0 implies
		duration.year = 0 and duration.day = 0
	day_only: duration.day /= 0 implies
		duration.year = 0 and duration.month = 0
	days_definite: duration.day /= 0 implies duration.definite
	years_not_definite: duration.year /= 0 implies not duration.definite
	months_not_definite: duration.month /= 0 implies not duration.definite
	nodate_definite: duration.year = 0 and duration.month = 0 and
		duration.day = 0 implies duration.definite
	day_month_or_year_no_time: duration.month /= 0 or duration.year /= 0 or
		duration.day /= 0 implies duration.hour = 0 and duration.minute = 0
	year_month_day_hour_or_minute: duration.year /= 0 or duration.month /= 0 or
		duration.day /= 0 or duration.hour /= 0 or duration.minute /=0
	intraday_regular: intraday implies not irregular
	intraday_definition: intraday implies
		duration.day = 0 and duration.month = 0 and duration.year = 0
	intraday_less_than_day: intraday implies
		duration.time.seconds_count < duration.time.seconds_in_day
	invalid_name_if_not_valid: not is_valid = equal (name, invalid_name)

end -- TIME_PERIOD_TYPE
