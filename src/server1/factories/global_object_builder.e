indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FACTORY_BUILDER inherit

	EXCEPTIONS
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_SERVER
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make is
		do
			set_up
		ensure
			ml_not_void: market_list /= Void
		end

feature -- Access

    input_file_names: LIST [STRING] is
            -- List of all specified input file names
		do
			Result := command_line_options.file_names
		end

	market_list: TRADABLE_LIST
			-- Tradable list made from input file data

	event_coordinator: MARKET_EVENT_COORDINATOR
			-- Object in charge of event generation and dispatch

feature {NONE}

	set_up is
			-- Build components and set up relationships, including
			-- making a factory list for the market_list.  (For now, these
			-- will all be STOCK_FACTORYs.)
		local
			i: INTEGER
			file: PLAIN_TEXT_FILE
			tradable_factories: LINKED_LIST [TRADABLE_FACTORY]
			tradable_factory: TRADABLE_FACTORY
			hc_function_factory: HARD_CODED_FUNCTION_BUILDER
		do
			!!hc_function_factory.make
			!STOCK_FACTORY!tradable_factory.make
			tradable_factory.set_no_open (
				not command_line_options.opening_price)
			if command_line_options.field_separator /= Void then
				tradable_factory.set_field_separator (
					command_line_options.field_separator)
			end
			check
				flist_not_void: function_library /= Void
			end
			-- (If function_library is not empty, it has been retrieved
			-- from persistent store.)
			-- !!!May need to lock this section (or whatever the mechanism
			-- is) to protect `function_library' if threads are used.
			if function_library.empty then
				-- Create the list of technical indicators,
				hc_function_factory.execute
				-- and copy them into the singleton list, function_library.
				function_library.append (hc_function_factory.product)
			end
			tradable_factory.set_indicators (function_library)
			!!tradable_factories.make
			-- Add a factory for each file name.  Since some files
			-- may be for different types of markets, in the future,
			-- different types of factories may be created and
			-- added to the tradable_factories list.
			from i := 1 until i = input_file_names.count + 1 loop
				tradable_factories.extend (tradable_factory)
				i := i + 1
			end
			check
				same_count: tradable_factories.count = input_file_names.count
			end
			build_components (tradable_factories)
		end

	build_components (tradable_factories: LINKED_LIST [TRADABLE_FACTORY]) is
		local
			dispatcher: EVENT_DISPATCHER
		do
			!VIRTUAL_TRADABLE_LIST!market_list.make (input_file_names,
														tradable_factories)
			!!dispatcher.make
			register_event_registrants (dispatcher)
			!MARKET_EVENT_COORDINATOR!event_coordinator.make (
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

end -- FACTORY_BUILDER
