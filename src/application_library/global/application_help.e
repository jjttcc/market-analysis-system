note
	description: "Help messages for application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class APPLICATION_HELP inherit

feature -- Access

	edit_event_generators: INTEGER = 1
	edit_indicators: INTEGER = 2

feature -- Access

	infix "@" (i: INTEGER): STRING
		deferred
		end

end -- class APPLICATION_HELP
