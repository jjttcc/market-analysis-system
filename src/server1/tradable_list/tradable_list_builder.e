indexing
	description: "Builder of the TRADABLE_LIST_HANDLER and the tradable %
		%lists that it manages"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class TRADABLE_LIST_BUILDER inherit

	FACTORY

	GLOBAL_SERVER
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (fl: LIST [MARKET_FUNCTION]) is
		require
			fl_not_void: fl /= Void
		do
			function_library := fl
		ensure
			function_library_set: function_library = fl
		end

feature -- Access

	product: TRADABLE_LIST_HANDLER

	function_library: LIST [MARKET_FUNCTION]

feature -- Basic operations

	execute is
		local
			global_server: expanded GLOBAL_SERVER
			db_list_builder: DATABASE_LIST_BUILDER
			daily_market_list: FILE_TRADABLE_LIST
		do
			retrieve_input_entity_names
			if command_line_options.use_db then
				create db_list_builder.make (input_entity_names,
					tradable_factories)
				db_list_builder.execute
				create product.make (db_list_builder.daily_list,
					db_list_builder.intraday_list)
			else
				create daily_market_list.make (input_entity_names,
					tradable_factories)
				-- !!!Make intraday list Void for now.
				create product.make (daily_market_list, Void)
			end
		end

feature {NONE} -- Implementation

	tradable_factories: LINKED_LIST [TRADABLE_FACTORY] is
		local
			i: INTEGER
			tradable_factory: TRADABLE_FACTORY
		do
			!STOCK_FACTORY!tradable_factory.make
			tradable_factory.set_no_open (
				not command_line_options.opening_price)
			if command_line_options.field_separator /= Void then
				tradable_factory.set_field_separator (
					command_line_options.field_separator)
			end
			if command_line_options.record_separator /= Void then
				tradable_factory.set_record_separator (
					command_line_options.record_separator)
			else
				-- Default to newline.
				tradable_factory.set_record_separator ("%N")
			end
			if command_line_options.strict then
				tradable_factory.set_strict_error_checking (true)
			end
			check
				flist_not_void: function_library /= Void
			end
			tradable_factory.set_indicators (function_library)
			!!Result.make
			-- Add a factory for each input entity.  Since some entities
			-- may be for different types of markets, in the future,
			-- different types of factories may be created and
			-- added to the tradable_factories list.
			from i := 1 until i = input_entity_names.count + 1 loop
				Result.extend (tradable_factory)
				i := i + 1
			end
		end

    retrieve_input_entity_names is
            -- List of all specified input data sources
		do
			if command_line_options.use_db then
				input_entity_names := command_line_options.symbol_list
			else
				input_entity_names := command_line_options.file_names
			end
		end

    input_entity_names: LIST [STRING]

invariant

	function_library_not_void: function_library /= Void

end -- class TRADABLE_LIST_BUILDER
