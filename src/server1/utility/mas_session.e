note
	description: "Session-specific data for MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MAS_SESSION inherit

	SESSION

creation

	make

feature {NONE} -- Initialization

	make
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

	set_last_tradable (arg: TRADABLE [BASIC_MARKET_TUPLE])
			-- Set last_tradable to `arg'.
		do
			last_tradable := arg
		ensure
			last_tradable_set: last_tradable = arg
		end

	turn_caching_on
			-- Turn caching on.
		do
			caching_on := True
		ensure
			caching_on: caching_on = True
		end

	turn_caching_off
			-- Turn caching off.
		do
			caching_on := False
		ensure
			caching_off: caching_on = False
		end

invariant

	dates_exist: start_dates /= Void and end_dates /= Void

end -- class MAS_SESSION
