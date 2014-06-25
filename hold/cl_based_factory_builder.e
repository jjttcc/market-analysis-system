indexing
	description:
		"FACTORY_BUILDER that produces factories for a command-line-based %
		%application"
	status2: "Obsolete"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class CL_BASED_FACTORY_BUILDER inherit

	EXCEPTIONS
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

creation

	make

feature {NONE}

	do_usage (msg: STRING) is
		do
			print (msg)
		end

	build_components (tradable_factories: LINKED_LIST [TRADABLE_FACTORY]) is
		local
			meg_builder: CL_BASED_MEG_EDITOR
			dispatcher: EVENT_DISPATCHER
		do
			create {VIRTUAL_TRADABLE_LIST} market_list.make (input_file_names,
														tradable_factories)
			create dispatcher.make
			create {CL_BASED_COMMAND_EDITOR} command_builder
			register_event_registrants (dispatcher)
			create {MARKET_EVENT_COORDINATOR} event_coordinator.make (
							active_event_generators, market_list, dispatcher)
		end

	register_event_registrants (dispatcher: EVENT_DISPATCHER) is
			-- Register global `market_event_registrants' to `dispatcher'
		do
			from
				market_event_registrants.start
			until
				market_event_registrants.exhausted
			loop
				dispatcher.register (market_event_registrants.item)
				market_event_registrants.forth
			end
		ensure
			dispatcher.registrants.count = market_event_registrants.count
		end

end -- CL_BASED_FACTORY_BUILDER
