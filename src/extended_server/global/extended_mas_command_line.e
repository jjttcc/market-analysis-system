note
	description: "MAS_COMMAND_LINE with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class EXTENDED_MAS_COMMAND_LINE inherit

	MAS_COMMAND_LINE
		redefine
			usage, main_setup_procedures, use_sockets
		end

creation

	make

feature -- Access

	usage: STRING
			-- Message: how to invoke the program from the command-line
		do
			Result := Precursor +
				"  -k:<portnum>         " +
				"Get data from a socKet connection on port <portnum>%N" +
				"  -report_back <hostname>^<number>%N%
				%                       Report back the %
				%startup-status at host <hostname>%N%
				%                         on port number <number>.%N"
		end

feature -- Access -- settings

	polling_timeout_milliseconds: INTEGER
			-- Polling timeout value, in milliseconds

	use_sockets: BOOLEAN

feature {NONE} -- Implementation

	set_polling_timeout_milliseconds
		do
			-- @@Hard code as 20 seconds for now - make it configurable later.
			polling_timeout_milliseconds := 20000
		end

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]]
		do
			Result := Precursor
			Result.extend (agent set_polling_timeout_milliseconds)
			Result.extend (agent set_use_sockets)
		end

invariant

end
