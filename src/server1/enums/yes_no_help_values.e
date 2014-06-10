note
	description: "Allowed values for a 'yes/no/help' menu selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class YES_NO_HELP_VALUES inherit

feature -- Access

	yes: CHARACTER = 'y'
		-- Constant for 'yes' selection

	yes_u: CHARACTER = 'Y'
		-- Constant for 'yes' selection, uppercase

	no: CHARACTER = 'n'
		-- Constant for 'no' selection

	no_u: CHARACTER = 'N'
		-- Constant for 'no' selection, uppercase

	help: CHARACTER = 'h'
		-- Constant for 'help' selection

	help_u: CHARACTER = 'H'
		-- Constant for 'help' selection, uppercase

end
