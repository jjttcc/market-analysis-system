indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class REQUEST_COMMAND inherit

	POLL_COMMAND
		rename
			make as pc_make_unused
		export
			{NONE} pc_make_unused
		undefine
			print
		end

	PRINTING
		export
			{NONE} all
		undefine
			print
		end

	GUI_NETWORK_PROTOCOL
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

	market_list: TRADABLE_LIST
			-- List of all markets currently in the `database'

feature -- Status setting

	set_active_medium (arg: IO_MEDIUM) is
			-- Set active_medium to `arg'.
		require
			arg_not_void: arg /= Void
		do
			active_medium := arg
		ensure
			active_medium_set: active_medium = arg and active_medium /= Void
		end

	set_market_list (arg: TRADABLE_LIST) is
			-- Set market_list to `arg'.
		require
			arg_not_void: arg /= Void
		do
			market_list := arg
		ensure
			market_list_set: market_list = arg and market_list /= Void
		end

feature {NONE}

	send_ok is
			-- Send an "OK" message ID to the client and the field
			-- separator.
		do
			print_list (<<OK.out, "%T">>)
		end

	report_error (slist: ARRAY [ANY]) is
			-- Report `s' as an error message; include Error ID at the
			-- beginning and `eom' at the end.
		do
			print_list (<<Error.out, "%T">>)
			print_list (slist)
			print (eom)
		end

	print (o: GENERAL) is
			-- Redefinition of output method inherited from GENERAL to
			-- send output to active_medium
		do
			--!!Note: If this method of sending is slow (calling print
			-- several times for one message, try caching the message here
			-- until the eom is sent.
			if o /= Void then
				active_medium.put_string (o.out)
			end
		end

end -- class REQUEST_COMMAND
