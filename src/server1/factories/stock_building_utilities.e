indexing
	description: "Tradable factory that manufactures STOCKs"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_FACTORY inherit

	TRADABLE_FACTORY
		redefine
			product
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

creation

	make

feature -- Access

	product: STOCK

	tuple_maker: BASIC_TUPLE_FACTORY is
		do
			create {VOLUME_TUPLE_FACTORY} Result
		end

feature {NONE} -- Implementation

	make_product is
		local
			i, last_sep_index: INTEGER
		do
			create product.make (symbol, stock_splits @ symbol, stock_data)
		end

	index_vector: ARRAY [INTEGER] is
		do
			create Result.make (1, 6)
			if no_open then
				if intraday then
					Result := << Date_index, Time_index, High_index, Low_index,
						CLose_index, Volume_index >>
				else
					Result := << Date_index, High_index, Low_index,
						CLose_index, Volume_index >>
				end
			else
				if intraday then
					Result := << Date_index, Time_index, Open_index,
						High_index, Low_index, Close_index, Volume_index >>
				else
					Result := << Date_index, Open_index, High_index, Low_index,
						Close_index, Volume_index >>
				end
			end
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

end -- STOCK_FACTORY
