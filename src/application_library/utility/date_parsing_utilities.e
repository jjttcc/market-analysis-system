indexing
	description: "Utilities for parsing date settings"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class DATE_PARSING_UTILITIES inherit

feature -- Access

	Now: STRING is "now"
			-- String that specifies the current date

feature {NONE} -- Implementation

	date_from_string (s: STRING): DATE is
			-- The result of parsing a date specification received from
			-- the client
		require
			s_exists: s /= Void
		local
			date_maker: DATE_TIME_SERVICES
			sutil: expanded STRING_UTILITIES
			tokens: LIST [STRING]
			n: INTEGER
			gutil: expanded GENERAL_UTILITIES
		do
			create date_maker
			if s.is_equal ("0") then
				create Result.make (0, 0, 0)
			elseif s.is_equal (Now) then
				Result := gutil.now_date
			else
				sutil.set_target (s)
				tokens := sutil.tokens (" ")
				if tokens.count = 1 then
					Result := date_maker.date_from_string (s,
						date_field_separator)
				elseif
					tokens.i_th (1).is_equal (Now) and
					tokens.i_th (2).is_equal ("-") and
					tokens.i_th (3).is_integer and tokens.count = 4
				then
					n := -tokens.i_th (3).to_integer
					Result := gutil.now_date
					if tokens.i_th (4).substring(1, 3).is_equal("day") then
						Result.day_add (n)
					elseif
						tokens.i_th (4).substring(1, 5).is_equal("month")
					then
						Result.month_add (n)
					elseif
						tokens.i_th (4).substring(1, 4).is_equal("year")
					then
						Result.year_month_add (n, 0)
					else
						-- Invalid specification
						Result := Void
					end
				end
			end
		end

feature {NONE} -- Implementation - Hook routines

	date_field_separator: STRING is
			-- Field separator for date components (e.g., '/' in 1995/03/17)
		deferred
		end

end
