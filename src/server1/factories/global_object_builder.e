indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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
			ml_not_void: market_list_handler /= Void
		end

feature -- Access

	market_list_handler: TRADABLE_DISPENSER
			-- Manager of all available market lists

	event_coordinator: MARKET_EVENT_COORDINATOR
			-- Object in charge of event generation and dispatch

feature {NONE}

	set_up is
			-- Build components and set up relationships.
		do
			check
				flist_not_void: function_library /= Void
			end
			-- (If function_library does not contain the hard-coded functions,
			-- make them and append them to function_library.)
			append_hard_coded_functions_to_library
			build_components
		end

	build_components is
		local
			dispatcher: EVENT_DISPATCHER
			list_builder: TRADABLE_LIST_BUILDER
		do
			create list_builder.make (function_library)
			list_builder.execute
			market_list_handler := list_builder.product
			create dispatcher.make
			register_event_registrants (dispatcher)
			create {MARKET_EVENT_COORDINATOR} event_coordinator.make (
				active_event_generators, market_list_handler, dispatcher)
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

feature {NONE} -- Administrative

	append_hard_coded_functions_to_library is
			-- If the hard-coded functions are not in the `function_library',
			-- append them to `function_library'.
		local
			hc_function_factory: HARD_CODED_FUNCTION_BUILDER
			f: MARKET_FUNCTION
		do
			if
				function_library.empty or function_library.count < 5
			then
				-- !!!May need to lock this section (or whatever the mechanism
				-- is) to protect `function_library' if threads are used.
				create hc_function_factory.make
				-- Create the list of technical indicators,
				hc_function_factory.execute
				from
					f := hc_function_factory.product.first
					function_library.start
				until
					function_library.exhausted or
					function_library.item.name.is_equal(f.name)
				loop
					function_library.forth
				end
				-- If the first function of hc_function_factory.product is
				-- not in function_library, assume no functions from
				-- hc_function_factory.product are in function_library -
				-- append them.
				if function_library.exhausted then
					function_library.append (hc_function_factory.product)
				end
			end
		end

	remove_functions (fnames: LIST [STRING]) is
			-- Delete all functions from the persistent `function_library'
			-- whose name matches an element of `fnames'
		local
			fl: LINKED_LIST [MARKET_FUNCTION]
		do
			from
				fnames.start
				fl ?= function_library
			until
				fnames.exhausted
			loop
				from
					fl.start
				until
					fl.exhausted or
					fl.item.name.is_equal(fnames.item)
				loop
					fl.forth
				end
				if fl.item.name.is_equal(fnames.item) then
					fl.remove
				end
				fnames.forth
			end
		end

	remove_hard_coded_functions is
			-- Delete all hard-coded functions from the persistent
			-- `function_library'.
		local
			l: LIST [MARKET_FUNCTION]
			fl: LINKED_LIST [MARKET_FUNCTION]
			hc_function_factory: HARD_CODED_FUNCTION_BUILDER
		do
			create hc_function_factory.make
			hc_function_factory.execute
			from
				l := hc_function_factory.product
				l.start
				fl ?= function_library
			until
				l.exhausted
			loop
				from
					fl.start
				until
					fl.exhausted or
					fl.item.name.is_equal(l.item.name)
				loop
					fl.forth
				end
				if fl.item.name.is_equal(l.item.name) then
					fl.remove
				end
				l.forth
			end
		end

end -- FACTORY_BUILDER
