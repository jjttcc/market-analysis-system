indexing
	description: "Time period types, such as daily, weekly, etc."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TIME_PERIOD_TYPE inherit

creation

	make

feature -- Initialization

	make (dur: DATE_TIME_DURATION) is
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
			-- Duration of the time period - approximate if irregular = true

feature -- Access - pre-defined names

	Yearly: STRING is "yearly"

	Monthly: STRING is "monthly"

	Weekly: STRING is "weekly"

	Daily: STRING is "daily"

	Hourly: STRING is "hourly"

feature {NONE} -- Implementation

	set_name is
			-- Set `name' according to the value of duration.
		require
			duration /= Void
		do
			!!name.make (0)
			if duration.day /= 0 then
				if duration.day = 1 then
					name.append (Daily)
				elseif duration.day = 7 then
					name.append (Weekly)
				else
					name.append (duration.day.out)
					name.append ("-day")
				end
			elseif duration.month /= 0 then
				if duration.month = 1 then
					name.append (Monthly)
				else
					name.append (duration.month.out)
					name.append ("-month")
				end
			elseif duration.year /= 0 then
				if duration.year = 1 then
					name.append (Yearly)
				else
					name.append (duration.year.out)
					name.append ("-year")
				end
			elseif duration.hour /= 0 then
				if duration.hour = 1 then
					name.append (Hourly)
				else
					name.append (duration.hour.out)
					name.append ("-hour")
				end
			elseif duration.minute /= 0 then
				name.append (duration.minute.out)
				name.append ("-minute")
			else
				name.append ("Invalid type")
			end
		end

invariant

	irregular_not_definite: irregular = not duration.definite

end -- TIME_PERIOD_TYPE
