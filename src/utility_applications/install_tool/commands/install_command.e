indexing
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2004: Jim Cochrane - %
		%License to be determined"

deferred class INSTALL_COMMAND inherit

	COMMAND

	REGULAR_EXPRESSION_UTILITIES
		export
			{NONE} all
		end

	ERROR_PUBLISHER
		export
			{ERROR_SUBSCRIBER} all
		end

feature -- Access

	description: STRING is
		deferred
		end

end
