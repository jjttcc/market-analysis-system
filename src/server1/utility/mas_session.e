indexing
	description: "Session-specific data for MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_SESSION inherit

	SESSION

creation

	make

feature {NONE} -- Initialization

	make is
		do
			create start_dates.make(1)
			create end_dates.make(1)
			caching_on := True
		ensure
			dates_not_void: start_dates /= Void and end_dates /= Void
			caching: caching_on = True
		end

feature -- Access

	--@@Need to add attribute(s) for specified function-parameter settings.

	start_dates: HASH_TABLE [DATE, STRING]
			-- Start dates - one (or 0) per time-period type

	end_dates: HASH_TABLE [DATE, STRING]
			-- End dates - one (or 0) per time-period type

	last_tradable: TRADABLE [BASIC_MARKET_TUPLE]
			-- Last tradable accessed

	caching_on: BOOLEAN
			-- Is market data being cached?

	login_date: DATE_TIME

	logoff_date: DATE_TIME

feature -- Element change

	set_last_tradable (arg: TRADABLE [BASIC_MARKET_TUPLE]) is
			-- Set last_tradable to `arg'.
		do
			last_tradable := arg
		ensure
			last_tradable_set: last_tradable = arg
		end

	turn_caching_on is
			-- Turn caching on.
		do
			caching_on := True
		ensure
			caching_on: caching_on = True
		end

	turn_caching_off is
			-- Turn caching off.
		do
			caching_on := False
		ensure
			caching_off: caching_on = False
		end

end -- class MAS_SESSION
