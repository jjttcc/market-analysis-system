indexing
	description: "Allowed values for a 'yes/no/help' menu selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class YES_NO_HELP_VALUES inherit

feature -- Access

	yes: CHARACTER is 'y'
		-- Constant for 'yes' selection

	yes_u: CHARACTER is 'Y'
		-- Constant for 'yes' selection, uppercase

	no: CHARACTER is 'n'
		-- Constant for 'no' selection

	no_u: CHARACTER is 'N'
		-- Constant for 'no' selection, uppercase

	help: CHARACTER is 'h'
		-- Constant for 'help' selection

	help_u: CHARACTER is 'H'
		-- Constant for 'help' selection, uppercase

end
