indexing
	description: "Tradable factory that manufactures STOCKs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class STOCK_BUILDING_UTILITIES inherit

	TRADABLE_FACTORY_CONSTANTS
		export
			{NONE} all
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	GLOBAL_SERVER
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature {TRADABLE_FACTORY} -- Implementation

	new_item (symbol: STRING): STOCK is
			-- A new stock instance with symbol `symbol'
		do
			create Result.make (symbol, stock_splits @ symbol, stock_data)
		end

	tuple_factory: BASIC_TUPLE_FACTORY is
		do
			create {VOLUME_TUPLE_FACTORY} Result
		end

	index_vector (no_open, intraday: BOOLEAN): ARRAY [INTEGER] is
			-- Index vector for setting up value setters for a STOCK (no
			-- open interest field)
		do
			if no_open then
				if intraday then
					Result := << Date_index, Time_index, High_index,
						Low_index, CLose_index, Volume_index >>
				else
					Result := << Date_index, High_index, Low_index,
						CLose_index, Volume_index >>
				end
			else
				if intraday then
					Result := << Date_index, Time_index, Open_index,
						High_index, Low_index, Close_index, Volume_index >>
				else
					Result := << Date_index, Open_index, High_index,
						Low_index, Close_index, Volume_index >>
				end
			end
		ensure
			at_least_one: Result.count > 0
		end

	stock_splits: STOCK_SPLITS is
		local
			constants: expanded APPLICATION_CONSTANTS
		once
			-- Use stock splits from the database, if they exist; otherwise
			-- input them from the stock-split file.
			Result := db_stock_splits
			if Result = Void then
				create {STOCK_SPLIT_FILE} Result.make (
					constants.Stock_split_field_separator,
					constants.Stock_split_record_separator, stock_split_file)
			end
		end

	stock_data: STOCK_DATA is
		do
			if command_line_options.use_db then
				Result := database_services.stock_data
			end
		end

	db_stock_splits: STOCK_SPLITS is
			-- Stock splits from database
		do
			if command_line_options.use_db then
				Result := database_services.stock_splits
			end
		end

	stock_split_file: STRING is
		local
			constants: expanded APPLICATION_CONSTANTS
		once
			if stock_split_file_name = Void then
				Result := file_name_with_app_directory (
					constants.Default_stock_split_file_name)
			else
				Result := file_name_with_app_directory (stock_split_file_name)
			end
		end

end -- STOCK_BUILDING_UTILITIES
