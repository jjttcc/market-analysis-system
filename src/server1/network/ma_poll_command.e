note

	description:
		"A poll command specialized for the Market Analysis server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MA_POLL_COMMAND

inherit

feature -- Access

	factory_builder: GLOBAL_OBJECT_BUILDER
			-- Builder of objects to be used by an interface

feature {NONE}

	interface: MAIN_APPLICATION_INTERFACE
		deferred
		end

invariant

	factory_builder_exists: factory_builder /= Void

end
