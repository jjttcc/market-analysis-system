indexing
	description: "MAS_COMMAND_LINE with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class EXTENDED_MAS_COMMAND_LINE inherit

	MAS_COMMAND_LINE
		redefine
			usage, main_setup_procedures
		end

creation

	make

feature -- Access

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := Precursor +
				"  -report_back <hostname>^<number>%N%
				%                       Report back the %
				%startup-status at host <hostname>%N%
				%                         on port number <number>.%N"
		end

feature -- Access -- settings

	polling_timeout_milliseconds: INTEGER
			-- Polling timeout value, in milliseconds

feature {NONE} -- Implementation

	set_polling_timeout_milliseconds is
		do
			-- @@Hard code as 20 seconds for now - make it configurable later.
			polling_timeout_milliseconds := 20000
		end

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
		do
			Result := Precursor
			Result.extend (agent set_polling_timeout_milliseconds)
		end

invariant

end
