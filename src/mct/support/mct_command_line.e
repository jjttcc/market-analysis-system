note
	description: "Parser of command-line arguments for the MAS Control %
		%Terminal application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MCT_COMMAND_LINE inherit

	COMMAND_LINE

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

feature -- Access

	usage: STRING
			-- Message: how to invoke the program from the command-line
		do
			Result := concatenation (<<"Usage: ", command_name, "%N">>)
		end

feature -- Access -- settings

feature {NONE} -- Implementation - Hook routines

	prepare_for_argument_processing
		do
		end

	finish_argument_processing
		do
			initialization_complete := True
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]]
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_debug)
		end

	initialization_complete: BOOLEAN

invariant

end
