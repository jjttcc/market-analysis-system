indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class REQUEST_COMMAND inherit

	COMMAND
		undefine
			print
		end

	GENERAL_UTILITIES
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

feature -- Access

	active_medium: IO_MEDIUM
			-- Medium for output

	session: SESSION
			-- Settings specific to a particular client session

feature -- Status report

	arg_mandatory: BOOLEAN is true

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

	set_session (arg: SESSION) is
			-- Set session to `arg'.
		require
			arg_not_void: arg /= Void
		do
			session := arg
		ensure
			session_set: session = arg and session /= Void
		end

feature -- Basic operations

	execute (msg: STRING) is
		deferred
		end

feature {NONE}

	send_ok is
			-- Send an "OK" message ID and the field separator to the client.
		do
			print_list (<<OK.out, "%T">>)
		end

	report_error (code: INTEGER; slist: ARRAY [ANY]) is
			-- Report `s' as an error message; include `code' ID at the
			-- beginning and `eom' at the end.
		do
			print_list (<<code.out, "%T">>)
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
