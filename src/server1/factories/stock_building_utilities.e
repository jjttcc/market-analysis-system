indexing
	description: "Utilities for manufacturing STOCKs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class STOCK_BUILDING_UTILITIES inherit

	TRADABLE_BUILDING_UTILITIES

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

	stock_splits: STOCK_SPLITS is
		local
			constants: expanded APPLICATION_CONSTANTS
			platform_objects: expanded PLATFORM_DEPENDENT_OBJECTS
		once
			-- Use stock splits from the database, if they exist; otherwise
			-- input them from the stock-split file.
			Result := db_stock_splits
			if Result = Void then
				Result := platform_objects.stock_split_file (
					constants.Stock_split_field_separator,
					constants.Stock_split_record_separator, stock_split_fname)
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

	stock_split_fname: STRING is
		local
			constants: expanded APPLICATION_CONSTANTS
		once
			if stock_split_file_name = Void then
				Result := file_name_with_app_directory (
					constants.Default_stock_split_file_name, False)
			else
				Result := file_name_with_app_directory (
					stock_split_file_name, False)
			end
		end

feature {NONE} -- Hook routine implementations

	has_open_interest: BOOLEAN is False

end
