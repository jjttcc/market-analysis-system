indexing
	description: "Parser of command-line arguments for the MAS Control %
		%Terminal application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MCT_COMMAND_LINE inherit

	COMMAND_LINE
		rename
			make as cl_make
		export
			{NONE} cl_make
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			cl_make
			from
				main_setup_procedures.start
			until
				main_setup_procedures.exhausted
			loop
				main_setup_procedures.item.call ([])
				main_setup_procedures.forth
			end
			initialization_complete := True
		end

feature -- Access

	usage: STRING is
			-- Message: how to invoke the program from the command-line
		do
			Result := concatenation (<<"Usage: ", command_name, "%N">>)
		end

feature -- Access -- settings

feature {NONE} -- Implementation

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]] is
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			-- No setup procedures yet.
		end

	initialization_complete: BOOLEAN

invariant

end
