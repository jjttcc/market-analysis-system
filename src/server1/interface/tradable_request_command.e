indexing
	description: "A request command that accesses tradables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class TRADABLE_REQUEST_COMMAND inherit

	REQUEST_COMMAND

feature {NONE} -- Initialization

	make (dispenser: TRADABLE_DISPENSER) is
		require
			not_void: dispenser /= Void
		do
			tradables := dispenser
		ensure
			set: tradables = dispenser and
				tradables /= Void
		end

feature -- Access

	tradables: TRADABLE_DISPENSER
			-- Dispenser of available market lists

feature -- Status setting

	set_tradables (arg: TRADABLE_DISPENSER) is
			-- Set tradables to `arg'.
		require
				arg_not_void: arg /= Void
		do
			tradables := arg
		ensure
			tradables_set: tradables = arg and
				tradables /= Void
		end

feature {NONE}

	report_server_error is
		do
			report_error (Error, <<"Server error: ",
				tradables.last_error>>)
		end

	server_error: BOOLEAN is
			-- Did an error occur in the server?
		do
			Result := tradables.error_occurred
		end

invariant

	tradables_set: tradables /= Void

end -- class TRADABLE_REQUEST_COMMAND
