indexing
	description: "Help messages for application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class APPLICATION_HELP inherit

	ARRAY [STRING]

feature -- Access

	edit_event_generators: INTEGER is 1
	edit_indicators: INTEGER is 2

end -- class APPLICATION_HELP
