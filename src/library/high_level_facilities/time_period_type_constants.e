note
	description: "Constants used for TIME_PERIOD_TYPEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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
