indexing
	description: "Abstraction for top-level application interface"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MAIN_APPLICATION_INTERFACE inherit

--	GLOBAL_APPLICATION
--		export {NONE}
--			all
--		undefine
--			print
--		end

	THREAD -- For the future - main interface will run in its own thread.
		export
			{NONE} all
		end

feature -- Access

	event_coordinator: MARKET_EVENT_COORDINATOR

	factory_builder: FACTORY_BUILDER

	market_list: TRADABLE_LIST

	input_file_names: LIST [STRING]

	event_generator_builder: MEG_EDITING_INTERFACE

	function_builder: FUNCTION_EDITING_INTERFACE

feature -- Basic operations

	execute is
		deferred
		end

feature {NONE}

	initialize is
		require
			fb_not_void: factory_builder /= Void
		do
			event_coordinator := factory_builder.event_coordinator
			market_list := factory_builder.market_list
			input_file_names := factory_builder.input_file_names
			!!help.make
		ensure
			inited: event_coordinator /= Void and market_list /= Void and
					input_file_names /= Void and help /= Void
		end

feature {NONE}

	help: HELP

invariant

	fb_not_void: factory_builder /= Void
	market_list_not_void: market_list /= Void
	input_file_names_not_void: input_file_names /= Void
	event_coordinator_not_void: event_coordinator /= Void
	event_generator_builder_not_void: event_generator_builder /= Void
	function_builder_not_void: function_builder /= Void

end -- class MAIN_APPLICATION_INTERFACE
