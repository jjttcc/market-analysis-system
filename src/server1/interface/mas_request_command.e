indexing
	description:
		"A MAS server command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MAS_REQUEST_COMMAND inherit
--!!!Remember to change file name to fit new class name.

	CLIENT_REQUEST_COMMAND
		redefine
			session, prepare_for_execution, exception_cleanup
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

	GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		end

--!!!Remove:
--	EXCEPTION_SERVICES
--		export
--			{NONE} all
--		end

feature -- Initialization

	make is
		do
			create output_buffer.make (0)
		end

feature -- Access

	active_medium: IO_MEDIUM
			-- Medium for output

	session: MAS_SESSION

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

feature -- Basic operations

--!!!Remove soon:
--	execute (msg: STRING) is
--			-- Call `do_execute' with `msg' and `send_data'.
--		local
--			timer: TIMER
--			exception_occurred: BOOLEAN
--		do
--			if exception_occurred then
--				output_buffer.clear_all
--				-- If `handle_exception' in the rescue clause didn't exit,
--				-- the exception was non-fatal.
--				report_error (Warning, <<"Error occurred ", error_context (msg),
--					".">>)
--			else
--				if output_buffer_used then
--					output_buffer.clear_all
--				end
--				do_execute (msg)
--			end
--			send_data
--		rescue
--			handle_exception ("obtaining data for GUI client")
--			exception_occurred := true
--			retry
--		end

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
			-- Report `slist' as an error message; include `code' ID at the
			-- beginning and `eom' at the end.
		do
			put (concatenation (<<code.out, "%T">>))
			put (concatenation (slist))
			put (eom)
		end

feature {NONE} -- Hook routine implementations

	warn_client (slst: ARRAY [STRING]) is
		do
			report_error (Warning, slst)
			respond_to_client
		end

	prepare_for_execution, exception_cleanup is
		do
			if output_buffer_used then
				output_buffer.clear_all
			end
		end

	respond_to_client is
			-- Send `output_buffer' to the `active_medium'.
		do
			if not output_buffer.empty then
				active_medium.put_string (output_buffer)
			end
		end

invariant

	output_buffer_not_void: output_buffer /= Void

end -- class MAS_REQUEST_COMMAND
