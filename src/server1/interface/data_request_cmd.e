indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class DATA_REQUEST_CMD inherit

	REQUEST_COMMAND
		rename
			make as rc_make_unused
		end

	STRING_UTILITIES
		rename
			make as su_make_unused
		export
			{NONE} all
		undefine
			print
		end

feature -- Initialization

	make (ml: TRADABLE_LIST) is
		require
			not_void: ml /= Void
		do
			market_list := ml
		ensure
			set: market_list = ml
		end

feature -- Access

	market_symbol: STRING
			-- Symbol for the selected market

	trading_period_type: TIME_PERIOD_TYPE
			-- Selected trading period type

	market_list: TRADABLE_LIST
			-- List of all markets currently in the `database'

feature -- Status setting

	set_market_list (arg: TRADABLE_LIST) is
			-- Set market_list to `arg'.
		require
			arg_not_void: arg /= Void
		do
			market_list := arg
		ensure
			market_list_set: market_list = arg and market_list /= Void
		end

invariant

	not_void: market_list /= Void

end -- class DATA_REQUEST_CMD
