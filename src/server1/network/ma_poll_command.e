indexing

	description:
		"A poll command specialized for the Market Analysis server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class MA_POLL_COMMAND

inherit

	POLL_COMMAND
		rename
			make as pc_make
		export
			{NONE} pc_make
		end

feature -- Access

	factory_builder: FACTORY_BUILDER
			-- Builder of objects to be used by an interface

feature {NONE}

	interface: MAIN_APPLICATION_INTERFACE

invariant

	not_void: active_medium /= Void and factory_builder /= Void

end -- class MA_POLL_COMMAND
