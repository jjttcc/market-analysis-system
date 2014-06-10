note
	description: "Constants used for TIME_PERIOD_TYPEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TIME_PERIOD_TYPE_CONSTANTS inherit

feature -- Access

	yearly_name: STRING = "yearly"
		-- Name of the yearly time period type

	quarterly_name: STRING = "quarterly"
		-- Name of the quarterly time period type

	monthly_name: STRING = "monthly"
		-- Name of the monthly time period type

	weekly_name: STRING = "weekly"
		-- Name of the weekly time period type

	daily_name: STRING = "daily"
		-- Name of the daily time period type

	hourly_name: STRING = "hourly"
		-- Name of the hourly time period type

	invalid_name: STRING = "Invalid type"
		-- Name of invalid period types

end
