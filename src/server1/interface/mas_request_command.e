indexing
	description:
		"A MAS server command that responds to a client request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MAS_REQUEST_COMMAND inherit

	IO_BASED_CLIENT_REQUEST_COMMAND
		redefine
			session
		end

	GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		end

	GLOBAL_CONSTANTS
		export
			{NONE} all
		end

feature -- Access

	session: MAS_SESSION

feature -- Status report

	arg_mandatory: BOOLEAN is True

feature {NONE}

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

end
