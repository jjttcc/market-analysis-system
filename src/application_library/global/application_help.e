note
	description: "Help messages for application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class APPLICATION_HELP inherit

feature -- Access

	edit_event_generators: INTEGER = 1
	edit_indicators: INTEGER = 2

feature -- Access

	infix "@" (i: INTEGER): STRING
		deferred
		end

end -- class APPLICATION_HELP
