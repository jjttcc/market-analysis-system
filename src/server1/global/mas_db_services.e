indexing
	description: "MAS database services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class MAS_DB_SERVICES inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	symbols: LIST [STRING] is
			-- All symbols available in the database
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	stock_splits: STOCK_SPLITS is
			-- All stock splits available in the database - Void if not
			-- available.
		deferred
		end

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Daily data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Intraday data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	stock_name (symbol: STRING): STRING is
			-- Name for stock whose symbol is `symbol'
		require
			connected: connected
		local
			query: STRING
		do
			fatal_error := false
			query := stock_name_query (symbol)
			if query /= Void then
				Result := single_string_query_result (query)
				if Result = Void and not fatal_error then
					Result := ""
				end
			end
		ensure
			not_void_if_ok: (not fatal_error) = (Result /= Void)
			still_connected: connected
		end

	single_string_query_result (query: STRING): STRING is
			-- 1-record, 1-column string result of executing `query'.  If
			-- the result is more than one record, the first record is
			-- returned; if 0 records or the query result is null, Result
			-- is Void.
		require
			connected: connected
			query_not_void: query /= Void
		deferred
		ensure
			void_if_error: fatal_error implies Result = Void
			still_connected: connected
		end

	stock_data: STOCK_DATA is
			-- Miscellaneous stock information from database
		deferred
		end

	last_error: STRING
			-- Description of last error that occured

feature -- Status report

	connected: BOOLEAN is
			-- Are we connected to the database?
		deferred
		end

	fatal_error: BOOLEAN
			-- Did a fatal error occur on the last operation?

feature -- Basic operations

	connect is
			-- Connect to the database.
		require
			not_connected: not connected
		deferred
		ensure
			connected: connected or fatal_error
		end

	disconnect is
			-- Disconnect from database.
		require
			connected: connected
		deferred
		ensure
			not_connected: not connected or fatal_error
		end

feature {NONE} -- Implementation

	daily_stock_query (symbol: STRING): STRING is
			-- Query for daily stock data
		local
			db_info: MAS_DB_INFO
			global_server: expanded GLOBAL_SERVER
		do
			db_info := global_server.database_configuration
			Result := concatenation (<<"select ",
				db_info.daily_stock_date_field_name, ", ",
				open_string (db_info), db_info.daily_stock_high_field_name,
				", ", db_info.daily_stock_low_field_name, ", ",
				db_info.daily_stock_close_field_name,
				", ", db_info.daily_stock_volume_field_name, " from ",
				db_info.daily_stock_table_name, " where ",
				db_info.daily_stock_symbol_field_name, " = '", symbol,
				"' ", db_info.daily_stock_query_tail>>)
		end

	intraday_stock_query (symbol: STRING): STRING is
			-- Query for intraday stock data
		local
			db_info: MAS_DB_INFO
			global_server: expanded GLOBAL_SERVER
		do
			db_info := global_server.database_configuration
			Result := concatenation (<<"select ",
				db_info.intraday_stock_date_field_name, ", ",
				db_info.intraday_stock_time_field_name, ", ",
				open_string (db_info), db_info.intraday_stock_high_field_name,
				", ", db_info.intraday_stock_low_field_name,
				", ", db_info.intraday_stock_close_field_name, ", ",
				db_info.intraday_stock_volume_field_name, " from ",
				db_info.intraday_stock_table_name,
				" where ", db_info.intraday_stock_symbol_field_name, " = '",
				symbol, "'", db_info.intraday_stock_query_tail>>)
		end

	stock_name_query (symbol: STRING): STRING is
			-- Query for stock name from symbol - Void if the user-specified
			-- query is invalid or non-existent.
		local
			global_server: expanded GLOBAL_SERVER
			q: STRING
		do
			q := global_server.database_configuration.stock_name_query
			if not q.empty then
				Result := inserted_symbol (q, symbol)
			else
				fatal_error := true
				last_error :=
					"Missing stock name query in database configuration file"
			end
		ensure
			not_void_if_ok: not fatal_error implies Result /= Void
		end

	open_string (db_info: MAS_DB_INFO): STRING is
			-- Open field string needed for query - empty if
			-- not command_line_options.opening_price
		local
			global_server: expanded GLOBAL_SERVER
		do
			if global_server.command_line_options.opening_price then
				Result := concatenation (<<db_info.daily_stock_open_field_name,
					", ">>)
			else
				Result := ""
			end
		end

	inserted_symbol (query, symbol: STRING): STRING is
			-- Result of replacing "<symbol>" with `symbol'
		local
			start_index, end_index: INTEGER
		do
			start_index := query.index_of ('<', 1)
			if start_index >= 1 then
				Result := clone (query)
				end_index := Result.index_of ('>', start_index)
				if end_index >= 1 then
					Result.replace_substring (concatenation (<<"'", symbol,
						"'">>), start_index, end_index)
				else
					fatal_error := true
					Result := Void
				end
			else
				fatal_error := true
			end
			if fatal_error then
				last_error := concatenation (<<"Invalid <symbol> specifier ",
					"in stock name query in database configuration file:%N%"",
					query, "%"">>)
			end
		ensure
			not_void_if_ok: (not fatal_error) = (Result /= Void)
		end

end -- class MAS_DB_SERVICES
