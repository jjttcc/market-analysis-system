indexing
	description: "Abstraction for top-level application interface"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

deferred class MAIN_APPLICATION_INTERFACE inherit

	THREAD -- For the future - main interface will run in its own thread.
		export
			{NONE} all
		end

feature {NONE} -- Access

	event_coordinator: MARKET_EVENT_COORDINATOR

	factory_builder: FACTORY_BUILDER

	market_list_handler: TRADABLE_DISPENSER

	intraday_market_list: TRADABLE_LIST

	event_generator_builder: MEG_EDITING_INTERFACE

	function_builder: FUNCTION_EDITING_INTERFACE

feature -- Basic operations

	execute is
		deferred
		end

feature {NONE}

	initialize (fb: FACTORY_BUILDER) is
		require
			fb_not_void: fb /= Void
		do
			factory_builder := fb
			event_coordinator := factory_builder.event_coordinator
			market_list_handler := factory_builder.market_list_handler
			create help.make
		ensure
			fb_set: factory_builder = fb
			list_handler_set: market_list_handler =
				factory_builder.market_list_handler
			initialized: event_coordinator /= Void and
				market_list_handler /= Void and help /= Void
		end

feature {NONE}

	help: HELP

invariant

	fb_not_void: factory_builder /= Void
	market_list_handler: market_list_handler /= Void
	event_coordinator_not_void: event_coordinator /= Void
	event_generator_builder_not_void: event_generator_builder /= Void
	function_builder_not_void: function_builder /= Void

end -- class MAIN_APPLICATION_INTERFACE
