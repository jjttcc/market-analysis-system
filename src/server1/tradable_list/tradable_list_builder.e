indexing
	description: "Builder of the TRADABLE_LIST_HANDLER and the tradable %
		%lists that it manages"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
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

	make is
		do
		end

feature -- Access

	product: TRADABLE_DISPENSER

feature -- Basic operations

	execute is
		local
			global_server: expanded GLOBAL_SERVER
			db_list_builder: DATABASE_LIST_BUILDER
			file_list_builder: FILE_LIST_BUILDER
			daily_file_based_list: FILE_TRADABLE_LIST
			ilist: TRADABLE_LIST
		do
			retrieve_input_entity_names
			if command_line_options.use_db then
				create db_list_builder.make (input_entity_names,
					tradable_factory)
				db_list_builder.execute
				create {TRADABLE_LIST_HANDLER} product.make (
					db_list_builder.daily_list, db_list_builder.intraday_list)
				ilist := db_list_builder.intraday_list
			else
				create file_list_builder.make (input_entity_names,
					tradable_factory, command_line_options.daily_extension,
					command_line_options.intraday_extension)
				file_list_builder.execute
				create {TRADABLE_LIST_HANDLER} product.make (
					file_list_builder.daily_list,
					file_list_builder.intraday_list)
				ilist := file_list_builder.intraday_list
			end
			if
				ilist /= Void and not command_line_options.intraday_caching
			then
				ilist.turn_caching_off
			end
		end

feature {NONE} -- Implementation

	tradable_factory: TRADABLE_FACTORY is
		do
			create Result.make
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

end -- class TRADABLE_LIST_BUILDER
