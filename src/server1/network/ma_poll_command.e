indexing

	description:
		"A poll command specialized for a TAL application"
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

deferred class TA_POLL_COMMAND

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

end -- class TA_POLL_COMMAND
