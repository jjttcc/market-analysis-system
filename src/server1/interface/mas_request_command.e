indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class REQUEST_COMMAND inherit

	COMMAND

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		end

	MAS_EXCEPTION
		export
			{NONE} all
		end

feature -- Initialization

	make is
		do
			create output_buffer.make (0)
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
			-- Call `do_execute' with `msg' and `send_data'.
		local
			timer: TIMER
			exception_occurred: BOOLEAN
		do
			if exception_occurred then
				output_buffer.clear_all
				-- If `handle_exception' in the rescue clause didn't exit,
				-- the exception was non-fatal.
				report_error (Warning, <<"Error occurred", error_context (msg),
					".">>)
			else
				if output_buffer_used then
					output_buffer.clear_all
				end
				do_execute (msg)
			end
			send_data
		rescue
			handle_exception ("obtaining data for GUI client")
			exception_occurred := true
			retry
		end

feature {NONE} -- Hook routines

	do_execute (msg: STRING) is
			-- produce response from `msg' and place it into `output_buffer'.
		deferred
		end

	error_context (msg: STRING): STRING is
			-- Context for the current error - redefine as appropriate.
		do
			Result := ""
		end

feature {NONE}

	output_buffer: STRING
			-- Buffer containing output to be sent to the client

	output_buffer_used: BOOLEAN is
			-- Is the `output_buffer' used?  Yes - redefine for
			-- descendants that don't use it.
		once
			Result := true
		end

	ok_string: STRING is
			-- "OK" message ID and field separator
		once
			Result := concatenation (<<OK.out, "%T">>)
		end

	put_ok is
			-- Append ok_string to `output_buffer'.
		require
			buffer_not_void: output_buffer /= Void
		do
			put (ok_string)
		ensure
			new_count: output_buffer.count = old output_buffer.count +
				OK.out.count + ("%T").count
		end

	put (s: STRING) is
			-- Append `s' to `output_buffer'.
		require
			buffer_not_void: output_buffer /= Void
		do
			output_buffer.append (s)
		ensure
			new_count: output_buffer.count = old output_buffer.count + s.count
		end

	report_error (code: INTEGER; slist: ARRAY [ANY]) is
			-- Report `s' as an error message; include `code' ID at the
			-- beginning and `eom' at the end.
		do
			put (concatenation (<<code.out, "%T">>))
			put (concatenation (slist))
			put (eom)
		end

	send_data is
			-- Redefinition of output method inherited from GENERAL to
			-- send output to active_medium
		do
			if output_buffer /= Void and not output_buffer.empty then
				active_medium.put_string (output_buffer)
			end
		end

end -- class REQUEST_COMMAND
