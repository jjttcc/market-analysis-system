indexing
	description: "Utilities for parsing components of the GUI client protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class GUI_PROTOCOL_UTILITIES inherit

	NETWORK_PROTOCOL
		export
			{NONE} all
		end

feature {NONE} -- Implementation

	date_from_string (s: STRING): DATE is
			-- The result of parsing a date specification received from
			-- the client
		local
			date_maker: DATE_TIME_SERVICES
			sutil: STRING_UTILITIES
			tokens: LIST [STRING]
			n: INTEGER
		do
			create date_maker
			if s.is_equal ("0") then
				create Result.make (0, 0, 0)
			elseif s.is_equal ("now") then
				create Result.make_now
				-- Set Result to 2 years in the future.
				Result.set_year (Result.year + 2)
			else
				create sutil.make (s)
				tokens := sutil.tokens (" ")
				if tokens.count = 1 then
					Result := date_maker.date_from_string (s,
						Date_field_separator)
				elseif
					tokens.i_th (1).is_equal ("now") and
					tokens.i_th (2).is_equal ("-") and
					tokens.i_th (3).is_integer and tokens.count = 4
				then
					n := -tokens.i_th (3).to_integer
					create Result.make_now
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

end -- class GUI_PROTOCOL_UTILITIES
