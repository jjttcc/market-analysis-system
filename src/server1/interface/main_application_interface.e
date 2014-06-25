note
	description: "Abstraction for top-level application interface"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MAIN_APPLICATION_INTERFACE inherit

	CONNECTION_INTERFACE

feature {NONE} -- Access

	event_coordinator: MARKET_EVENT_COORDINATOR

	factory_builder: GLOBAL_OBJECT_BUILDER

	tradable_list_handler: TRADABLE_DISPENSER

	event_generator_builder: MEG_EDITING_INTERFACE

	function_builder: FUNCTION_EDITING_INTERFACE

feature {NONE}

	initialize (fb: GLOBAL_OBJECT_BUILDER)
		require
			fb_not_void: fb /= Void
		do
			factory_builder := fb
			event_coordinator := factory_builder.event_coordinator
			tradable_list_handler := factory_builder.tradable_list_handler
			create help.make
		ensure
			fb_set: factory_builder = fb
			list_handler_set: tradable_list_handler =
				factory_builder.tradable_list_handler
			initialized: event_coordinator /= Void and
				tradable_list_handler /= Void and help /= Void
		end

feature {NONE}

	help: HELP

invariant

	fb_not_void: factory_builder /= Void
	tradable_list_handler: tradable_list_handler /= Void
	event_coordinator_not_void: event_coordinator /= Void
	event_generator_builder_not_void: event_generator_builder /= Void
	function_builder_not_void: function_builder /= Void

end -- class MAIN_APPLICATION_INTERFACE
