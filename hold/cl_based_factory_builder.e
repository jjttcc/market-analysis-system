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

creation

	make

feature -- Initialization

	make (default_input_fname: STRING) is
		do
			if default_input_fname /= Void then
				default_input_file_name := default_input_fname
			end
			!LINKED_LIST [STRING]!input_file_names.make
			process_args
		ensure
			default_file_name: default_input_file_name = default_input_fname
			ml_not_void: market_list /= Void
		end

feature -- Access

	function_list_factory: FUNCTION_BUILDER is
			-- Builder of a list of composite functions
		once
			!!Result.make
		end

	default_input_file_name: STRING
			-- File name to use if none are specified by the user

	input_file_names: LIST [STRING]
			-- List of all specified input file names

	market_list: TRADABLE_LIST
			-- Tradable list made from input file data

	event_coordinator: EVENT_COORDINATOR
			-- Object in charge of event generation and dispatch

	registration_builder: EVENT_REGISTRATION_BUILDER
			-- Builder that sets up event registrations and produces
			-- an event dispatcher

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
			function_list_factory.execute
			tradable_factory.set_indicators (function_list_factory.product)
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
			fa_builder: FUNCTION_ANALYZER_BUILDER
		do
			!!fa_builder.make (function_list_factory.product)
			!VIRTUAL_TRADABLE_LIST!market_list.make (input_file_names,
														tradable_factories)
			fa_builder.execute
			!!registration_builder.make (fa_builder.product)
			registration_builder.execute
			!MARKET_EVENT_COORDINATOR!event_coordinator.make (
								fa_builder.product, market_list,
								registration_builder.product)
		end

end -- FACTORY_BUILDER
