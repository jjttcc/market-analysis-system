indexing
	description: "Parser of command-line arguments for the MAS Control %
		%Terminal application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined"

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

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := concatenation (<<"Usage: ", command_name, "%N">>)
		end

feature -- Access -- settings

feature {NONE} -- Implementation - Hook routines

	prepare_for_argument_processing is
		do
		end

	finish_argument_processing is
		do
			initialization_complete := True
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_debug)
		end

	initialization_complete: BOOLEAN

invariant

end
