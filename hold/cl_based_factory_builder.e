indexing
	description:
		"Abstraction that builds the appropriate instances of factories"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class FACTORY_BUILDER inherit

	ARGUMENTS
		export {NONE}
			all
		end

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

feature -- Initialization

	make is
		do
			!ARRAYED_LIST [STRING]!input_file_names.make (argument_count)
			process_args
		ensure
			ml_not_void: market_list /= Void
		end

feature -- Access

	function_list_factory: FUNCTION_BUILDER is
			-- Builder of a list of composite functions
		once
			!!Result.make
		end

	input_file_names: LIST [STRING]
			-- List of all specified input file names

	market_list: TRADABLE_LIST
			-- Tradable list made from input file data

	event_coordinator: MARKET_EVENT_COORDINATOR
			-- Object in charge of event generation and dispatch

feature {NONE}

	usage is
		do
			print ("Usage: "); print (argument (0))
			print (" [input_file ...] [-o] [-f field_separator]%N%
				%    Where:%N        -o = data has an open field%N")
		end

	process_args is
			-- Process command-line arguments, including, for each input
			-- file name in the arguments, adding the name to the
			-- input_file_names list.  Also, make a factory list for the
			-- market_list.  For now, these will all be STOCK_FACTORYs.
		local
			i: INTEGER
			no_open: BOOLEAN
			fs: STRING
			file: PLAIN_TEXT_FILE
			tradable_factories: LINKED_LIST [TRADABLE_FACTORY]
			tradable_factory: TRADABLE_FACTORY
		do
			no_open := true
			!STOCK_FACTORY!tradable_factory.make
			check
				flist_not_void: function_library /= Void
			end
			-- (If function_library is not empty, it has been retrieved
			-- from persistent store.)
			if function_library.empty then
				-- Create the list of technical indicators,
				function_list_factory.execute
				-- and copy them into the singleton list, function_library.
				function_library.append (function_list_factory.product)
			end
			tradable_factory.set_indicators (function_library)
			!!tradable_factories.make
			from
				i := 1
			until
				i > argument_count
			loop
				if argument (i) @ 1 = '-' and argument (i).count > 1 then
					if argument (i) @ 2 = 'o' then
						no_open := false
					elseif
						argument (i) @ 2 = 'f' and argument_count > i
					then
						i := i + 1
						fs := argument (i)
					else
						usage
						die (-1) -- kludgey exit for now
					end
				else
					input_file_names.extend (argument (i))
					-- Add a factory for each file name.  Since some files
					-- may be for different types of markets, in the future,
					-- different types of factories may be created and
					-- added to the tradable_factories list.
					tradable_factories.extend (tradable_factory)
				end
				i := i + 1
			end
			if input_file_names.empty then
				if default_input_file_name /= Void then
					input_file_names.extend (default_input_file_name)
					tradable_factories.extend (tradable_factory)
				else
					raise ("No input file name specified")
				end
			end
			tradable_factory.set_no_open (no_open)
			if fs /= Void then
				tradable_factory.set_field_separator (fs)
			end
			build_components (tradable_factories)
		end

	build_components (tradable_factories: LINKED_LIST [TRADABLE_FACTORY]) is
		local
			meg_builder: MARKET_EVENT_GENERATOR_BUILDER
			dispatcher: EVENT_DISPATCHER
		do
			!VIRTUAL_TRADABLE_LIST!market_list.make (input_file_names,
														tradable_factories)
			check
				megl_not_void: market_event_generation_library /= Void
			end
			-- (If market_event_generation_library is not empty, it has
			-- been retrieved from persistent store.)
			if market_event_generation_library.empty then
				!!meg_builder
				-- Create the list of market event generators.
				-- meg_builder will copy them into the global event
				-- generation library.
				meg_builder.execute
			end
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
