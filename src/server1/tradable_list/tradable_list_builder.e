indexing
	description: "Builder of the TRADABLE_LIST_HANDLER and the tradable %
		%lists that it manages"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TRADABLE_LIST_BUILDER inherit

	FACTORY

	GLOBAL_SERVER_FACILITIES
		export {NONE}
			all
		end

creation

	make

feature -- Initialization

	make (all_indicators: SEQUENCE [MARKET_FUNCTION]) is
		require
			all_indicators_exists: all_indicators /= Void
		do
			indicators := all_indicators
		ensure
			indicators = all_indicators
		end

feature -- Access

	product: TRADABLE_DISPENSER

    indicators: SEQUENCE [MARKET_FUNCTION]

feature -- Basic operations

	execute is
		local
			db_list_builder: DATABASE_LIST_BUILDER
			file_list_builder: FILE_LIST_BUILDER
			socket_list_builder: SOCKET_LIST_BUILDER
			http_list_builder: HTTP_FILE_LIST_BUILDER
			external_list_builder: EXTERNAL_LIST_BUILDER
			ilist: TRADABLE_LIST
			list_handler: TRADABLE_LIST_HANDLER
		do
			if command_line_options.use_external_data_source then
				create external_list_builder.make (tradable_factory)
				external_list_builder.execute
				create list_handler.make (external_list_builder.daily_list,
					external_list_builder.intraday_list, indicators)
				ilist := external_list_builder.intraday_list
			else
				retrieve_input_entity_names
				if command_line_options.use_db then
					create db_list_builder.make (input_entity_names,
						tradable_factory)
					db_list_builder.execute
					create list_handler.make (db_list_builder.daily_list,
						db_list_builder.intraday_list, indicators)
					ilist := db_list_builder.intraday_list
				elseif command_line_options.use_web then
					--@NOTE: May want to pass in valid file extensions
					--when/if http intraday data retrieval is added.
					create http_list_builder.make (tradable_factory, Void,
						Void)
					http_list_builder.execute
					create list_handler.make (http_list_builder.daily_list,
						http_list_builder.intraday_list, indicators)
					ilist := http_list_builder.intraday_list
				elseif command_line_options.use_sockets then
					create socket_list_builder.make (tradable_factory)
					socket_list_builder.execute
					create list_handler.make (socket_list_builder.daily_list,
						socket_list_builder.intraday_list, indicators)
					ilist := socket_list_builder.intraday_list
				else	-- Use regular files.
					create file_list_builder.make (input_entity_names,
						tradable_factory, command_line_options.daily_extension,
						command_line_options.intraday_extension)
					file_list_builder.execute
					create list_handler.make (file_list_builder.daily_list,
						file_list_builder.intraday_list, indicators)
					ilist := file_list_builder.intraday_list
				end
			end
			if
				ilist /= Void and not command_line_options.intraday_caching
			then
				ilist.turn_caching_off
			end
			product := list_handler
		end

feature {NONE} -- Implementation

	tradable_factory: TRADABLE_FACTORY is
		do
			create Result.make
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
				Result.set_strict_error_checking (True)
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

    indicators_exist: indicators /= Void

end -- class TRADABLE_LIST_BUILDER
