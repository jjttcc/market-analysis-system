indexing
	description: "MAS database services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MAS_DB_SERVICES inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access


	stock_symbols: LIST [STRING] is
			-- All stock symbols available in the database
		require
			connected: connected
		local
			gs: expanded GLOBAL_SERVER
		do
			Result := list_from_query (
				gs.database_configuration.stock_symbol_query)
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	derivative_symbols: LIST [STRING] is
			-- All derivative-instrument symbols available in the database
		require
			connected: connected
		local
			gs: expanded GLOBAL_SERVER
		do
			Result := list_from_query (
				gs.database_configuration.derivative_symbol_query)
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	stock_splits: STOCK_SPLITS is
			-- All stock splits available in the database - Void if not
			-- available.
		deferred
		end

	daily_data_for_symbol (s: STRING): DB_INPUT_SEQUENCE is
			-- Daily data for symbol `s' - stock data if `s' is a stock
			-- symbol (stock_symbols.has (s)), derivative data is `s' is
			-- a derivative-instrument symbol (derivative_symbols.has (s)).
		require
			connected: connected
		do
			if is_stock_symbol (s) then
				Result := daily_stock_data (s)
				if Result /= Void then
					check_field_count (Result, Stock, false,
						"daily stock data")
				end
			elseif is_derivative_symbol (s) then
				Result := daily_derivative_data (s)
				if Result /= Void then
					check_field_count (Result, Derivative, false,
						"daily derivative data")
				end
			end
		ensure
			not_void_if_no_error: not fatal_error and (is_stock_symbol (s) or
				is_derivative_symbol (s)) implies Result /= Void
			still_connected: connected
		end

	intraday_data_for_symbol (s: STRING): DB_INPUT_SEQUENCE is
			-- Intraday data for symbol `s' - stock data if `s' is a stock
			-- symbol (stock_symbols.has (s)), derivative data is `s' is
			-- a derivative-instrument symbol (derivative_symbols.has (s)).
		require
			connected: connected
		do
			if is_stock_symbol (s) then
				Result := intraday_stock_data (s)
				if Result /= Void then
					check_field_count (Result, Stock, true,
						"intraday stock data")
				end
			elseif is_derivative_symbol (s) then
				Result := intraday_derivative_data (s)
				if Result /= Void then
					check_field_count (Result, Derivative, true,
						"intraday derivative data")
				end
			end
		ensure
			not_void_if_no_error: not fatal_error and (is_stock_symbol (s) or
				is_derivative_symbol (s)) implies Result /= Void
			still_connected: connected
		end

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Daily stock data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Intraday stock data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	daily_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Daily derivative data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	intraday_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
			-- Intraday derivative data for `symbol'
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

	derivative_name (symbol: STRING): STRING is
			-- Name for derivative whose symbol is `symbol'
		require
			connected: connected
		local
			query: STRING
		do
			fatal_error := false
			query := derivative_name_query (symbol)
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

	derivative_data: TRADABLE_DATA is
			-- Miscellaneous derivative-instrument information from database
		deferred
		end

	last_error: STRING
			-- Description of last error that occured

	is_stock_symbol (s: STRING): BOOLEAN is
			-- Is `s' a symbol for a stock?
		local
			symbols: LIST [STRING]
		do
			if stock_symbol_table = Void then
				symbols := stock_symbols
				if symbols /= Void then
					create stock_symbol_table.make (symbols.count)
					from
						symbols.start
					until
						symbols.exhausted
					loop
						stock_symbol_table.force (Void, symbols.item)
						symbols.forth
					end
				else
					create stock_symbol_table.make (0)
				end
			end
			Result := stock_symbol_table.has (s)
		end

	is_derivative_symbol (s: STRING): BOOLEAN is
			-- Is `s' a symbol for a derivative instrument?
		local
			symbols: LIST [STRING]
		do
			if derivative_symbol_table = Void then
				symbols := derivative_symbols
				if symbols /= Void then
					create derivative_symbol_table.make (symbols.count)
					from
						symbols.start
					until
						symbols.exhausted
					loop
						derivative_symbol_table.force (Void, symbols.item)
						symbols.forth
					end
				else
					create derivative_symbol_table.make (0)
				end
			end
			Result := derivative_symbol_table.has (s)
		end

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
			if db_info.using_daily_stock_data_command then
				Result := inserted_symbol (db_info.daily_stock_data_command,
					symbol)
			else
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
		end

	intraday_stock_query (symbol: STRING): STRING is
			-- Query for intraday stock data
		local
			db_info: MAS_DB_INFO
			global_server: expanded GLOBAL_SERVER
		do
			db_info := global_server.database_configuration
			if db_info.using_intraday_stock_data_command then
				Result := inserted_symbol (db_info.intraday_stock_data_command,
					symbol)
			else
				Result := concatenation (<<"select ",
					db_info.intraday_stock_date_field_name, ", ",
					db_info.intraday_stock_time_field_name, ", ",
					open_string (db_info),
					db_info.intraday_stock_high_field_name,
					", ", db_info.intraday_stock_low_field_name,
					", ", db_info.intraday_stock_close_field_name, ", ",
					db_info.intraday_stock_volume_field_name, " from ",
					db_info.intraday_stock_table_name,
					" where ", db_info.intraday_stock_symbol_field_name, " = '",
					symbol, "'", db_info.intraday_stock_query_tail>>)
			end
		end

	daily_derivative_query (symbol: STRING): STRING is
			-- Query for daily derivative data
		local
			db_info: MAS_DB_INFO
			global_server: expanded GLOBAL_SERVER
		do
			db_info := global_server.database_configuration
			if db_info.using_daily_derivative_data_command then
				Result := inserted_symbol (
					db_info.daily_derivative_data_command, symbol)
			else
				Result := concatenation (<<"select ",
					db_info.daily_derivative_date_field_name, ", ",
					open_string (db_info),
						db_info.daily_derivative_high_field_name,
					", ", db_info.daily_derivative_low_field_name, ", ",
					db_info.daily_derivative_close_field_name,
					", ", db_info.daily_derivative_volume_field_name, ", ",
					db_info.daily_derivative_open_interest_field_name,
					" from ", db_info.daily_derivative_table_name, " where ",
					db_info.daily_derivative_symbol_field_name, " = '", symbol,
					"' ", db_info.daily_derivative_query_tail>>)
			end
		end

	intraday_derivative_query (symbol: STRING): STRING is
			-- Query for intraday derivative data
		local
			db_info: MAS_DB_INFO
			global_server: expanded GLOBAL_SERVER
		do
			db_info := global_server.database_configuration
			if db_info.using_intraday_derivative_data_command then
				Result := inserted_symbol (
					db_info.intraday_derivative_data_command, symbol)
			else
				Result := concatenation (<<"select ",
					db_info.intraday_derivative_date_field_name, ", ",
					db_info.intraday_derivative_time_field_name, ", ",
					open_string (db_info),
					db_info.intraday_derivative_high_field_name,
					", ", db_info.intraday_derivative_low_field_name,
					", ", db_info.intraday_derivative_close_field_name, ", ",
					db_info.intraday_derivative_volume_field_name, ", ",
					db_info.intraday_derivative_open_interest_field_name,
					" from ", db_info.intraday_derivative_table_name, " where ",
					db_info.intraday_derivative_symbol_field_name, " = '",
					symbol, "'", db_info.intraday_derivative_query_tail>>)
			end
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

	derivative_name_query (symbol: STRING): STRING is
			-- Query for derivative name from symbol - Void if the
			-- user-specified query is invalid or non-existent.
		local
			global_server: expanded GLOBAL_SERVER
			q: STRING
		do
			q := global_server.database_configuration.derivative_name_query
			if not q.empty then
				Result := inserted_symbol (q, symbol)
			else
				fatal_error := true
				last_error := "Missing derivative name query in %
					%database configuration file"
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

	list_from_query (q: STRING): LIST [STRING] is
			-- List of STRING from query `q' with 1-column result
		require
			not_void: q /= Void
		deferred
		ensure
			not_void: Result /= Void
			empty_if_q_empty: old q.empty implies Result.empty
		end

	check_field_count (seq: DB_INPUT_SEQUENCE; tradable_type: INTEGER;
		intraday: BOOLEAN; data_descr: STRING) is
			-- Check the field count of `seq' according to whether it is
			-- whether it is for a Stock or Derivative and whether its,
			-- data is intraday, and if the field count is wrong
			-- set fatal_error and last_error accordingly.
		require
			valid_tradable_type: tradable_type = Stock or
				tradable_type = Derivative
		local
			global_server: expanded GLOBAL_SERVER
			expected_count: INTEGER
		do
			if global_server.command_line_options.opening_price then
				expected_count := 1
			end
			inspect
				tradable_type
			when Stock then
				expected_count := expected_count + 5
			when Derivative then
				expected_count := expected_count + 6
			end
			if intraday then
				expected_count := expected_count + 1
			end
			if seq.field_count /= expected_count then
				fatal_error := true
				last_error := concatenation (<<"Database error:%NWrong number ",
					"of fields in query result for%N", data_descr,
					" - expected ", expected_count,
					", got ", seq.field_count, ".%N">>)
			end
		end

	stock_symbol_table, derivative_symbol_table: HASH_TABLE [ANY, STRING]

	Stock, Derivative: INTEGER is unique

end -- class MAS_DB_SERVICES
