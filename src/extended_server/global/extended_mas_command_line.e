indexing
	description: "MAS_COMMAND_LINE with extensions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

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

feature {NONE} -- Implementation

	placeholder_setup_procedure is
		do
		end

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
		do
			Result := Precursor
			Result.extend (agent placeholder_setup_procedure)
		end

invariant

end
