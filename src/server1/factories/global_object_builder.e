indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class FACTORY_BUILDER inherit

	EXCEPTIONS
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_SERVER_FACILITIES
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

	dispatcher: EVENT_DISPATCHER
			-- Event dispatcher used in market event analysis

feature -- Basic operations

	make_dispatcher is
			-- Create `dispatcher' with the current event registrants.
		do
			create dispatcher.make
			register_event_registrants
		ensure
			dispatcher_created: dispatcher /= Void
		end

feature {NONE}

	set_up is
			-- Build components and set up relationships.
		do
			check
				flist_not_void: function_library /= Void
			end
			-- If function_library does not contain the hard-coded functions,
			-- make them and append them to function_library.
			append_hard_coded_functions_to_library
			build_components
		end

	build_components is
		local
			list_builder: TRADABLE_LIST_BUILDER
		do
			create list_builder.make
			list_builder.execute
			market_list_handler := list_builder.product
			create {TRADABLE_LIST_EVENT_COORDINATOR} event_coordinator.make (
				market_list_handler)
		end

	register_event_registrants is
			-- Register global `market_event_registrants' to `dispatcher'
		require
			dispatcher_not_void: dispatcher /= Void
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
			lock: FILE_LOCK
			env: expanded APP_ENVIRONMENT
		do
			if
				function_library.is_empty or function_library.count < 5
			then
				-- @@@May need to lock this section (or whatever the mechanism
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
				-- Attempt to lock the `function_library' persistent file and
				-- save `function_library' to it.
				lock := file_lock (env.file_name_with_app_directory (
					indicators_file_name))
				lock.try_lock
				if lock.locked then
					function_library.save
					lock.unlock
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
