note
	description: "Objects that process a target file according to a set of%
		%specifications"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

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

	description: STRING
		deferred
		end

end
