indexing
	description: "A command that responds to a GUI client data request"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class REQUEST_COMMAND inherit

	POLL_COMMAND
		undefine
			print
		end

	PRINTING
		export
			{NONE} all
		undefine
			print
		end

	GUI_SERVER_PROTOCOL
		export
			{NONE} all
		undefine
			print
		end

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

feature {NONE}

	report_error (slist: ARRAY [ANY]) is
			-- Report `s' as an error message; include `eom' at the end.
		do
			print_list (slist)
			print (eom)
		end

	print (o: GENERAL) is
			-- Redefinition of output method inherited from GENERAL to
			-- send output to active_medium
		do
			if o /= Void then
				active_medium.put_string (o.out)
			end
		end

end -- class REQUEST_COMMAND
