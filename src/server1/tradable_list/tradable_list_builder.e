indexing
	description: "Builder of the TRADABLE_LIST_HANDLER and the tradable %
		%lists that it manages"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

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

	product: TRADABLE_DISPENSER

	function_library: LIST [MARKET_FUNCTION]

feature -- Basic operations

	execute is
		local
			global_server: expanded GLOBAL_SERVER
			db_list_builder: DATABASE_LIST_BUILDER
			file_list_builder: FILE_LIST_BUILDER
			daily_file_based_list: FILE_TRADABLE_LIST
		do
			retrieve_input_entity_names
			if command_line_options.use_db then
				create db_list_builder.make (input_entity_names,
					tradable_factory)
				db_list_builder.execute
				create {TRADABLE_LIST_HANDLER} product.make (
					db_list_builder.daily_list, db_list_builder.intraday_list)
			else
				create file_list_builder.make (input_entity_names,
					tradable_factory, command_line_options.daily_extension,
					command_line_options.intraday_extension)
				file_list_builder.execute
				create {TRADABLE_LIST_HANDLER} product.make (
					file_list_builder.daily_list,
					file_list_builder.intraday_list)
			end
		end

feature {NONE} -- Implementation

	tradable_factory: TRADABLE_FACTORY is
		do
			create {STOCK_FACTORY} Result.make
			Result.set_no_open (
				not command_line_options.opening_price)
			if command_line_options.field_separator /= Void then
				Result.set_field_separator (
					command_line_options.field_separator)
			end
			if command_line_options.record_separator /= Void then
				Result.set_record_separator (
					command_line_options.record_separator)
			else
				-- Default to newline.
				Result.set_record_separator ("%N")
			end
			if command_line_options.strict then
				Result.set_strict_error_checking (true)
			end
			check
				flist_not_void: function_library /= Void
			end
			Result.set_indicators (function_library)
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
