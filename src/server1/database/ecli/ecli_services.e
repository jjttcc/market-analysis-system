indexing
	description: "MAS database services - ECLI implmentation"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ECLI_SERVICES inherit

	MAS_DB_SERVICES

	GLOBAL_SERVER_FACILITIES
		rename
			database_configuration as db_info
		export
			{NONE} all
			{ANY} db_info
		end

	GLOBAL_APPLICATION
		export
			{NONE} all
		end

	EXCEPTIONS
		export
			{NONE} all
		end

	TERMINABLE
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make is
		do
			connect
			if not fatal_error then
				load_stock_splits
				register_for_termination (Current)
				disconnect
			end
		ensure
			splits_not_void_if_available:
				not fatal_error and not db_info.stock_split_query.is_empty
					implies stock_splits /= Void
			not_connected: not connected or else fatal_error
		end

feature -- Access

	stock_splits: ECLI_STOCK_SPLITS

	daily_stock_data (symbol: STRING): ECLI_INPUT_SEQUENCE is
			-- Daily data for `symbol'
		do
			create Result.make (input_statement (
				daily_stock_query (symbol), daily_stock_value_holders))
		end

	intraday_stock_data (symbol: STRING): ECLI_INPUT_SEQUENCE is
			-- Daily data for `symbol'
		do
			create Result.make (input_statement (
				intraday_stock_query (symbol), intraday_stock_value_holders))
		end

	daily_derivative_data (symbol: STRING): ECLI_INPUT_SEQUENCE is
			-- Daily data for `symbol'
		do
			create Result.make (input_statement (
				daily_derivative_query (symbol),
				daily_derivative_value_holders))
		end

	intraday_derivative_data (symbol: STRING): ECLI_INPUT_SEQUENCE is
			-- Daily data for `symbol'
		do
			create Result.make (input_statement (
				intraday_derivative_query (symbol),
				intraday_derivative_value_holders))
		end

	single_string_query_result (query: STRING): STRING is
		local
			stmt: ECLI_STATEMENT
			ecli_result: ECLI_VARCHAR
		do
			fatal_error := false
			create stmt.make (session)
			stmt.set_immediate_execution_mode
			stmt.set_sql (query)
			stmt.execute
			if not stmt.is_ok then
				last_error := concatenation (<<
					"Execution of statement:%N'",
					stmt.sql, "' failed:%N", stmt.cli_state, ", ",
					stmt.diagnostic_message>>)
				debug ("database")
					print_list (<<last_error, "%N">>)
				end
				fatal_error := true
			else
				-- Create result set 'value holders'.
				create ecli_result.make (Max_varchar_length)
				if stmt.result_column_count /= 1 then
					last_error := concatenation (<<
						"Execution of statement:%N'",
						stmt.sql, "' failed: too many columns in result - ",
						"expecting 1">>)
					debug ("database")
						print_list (<<last_error, "%N">>)
					end
					fatal_error := true
				else
					stmt.set_cursor (<<ecli_result>>)
					stmt.start
					if not stmt.off and not stmt.cursor.item (1).is_null then
						Result ?= stmt.cursor.item (1).item
					end
				end
			end
			stmt.close
		end

	stock_data: STOCK_DATA is
		once
			create {DB_STOCK_DATA} Result
		end

	derivative_data: TRADABLE_DATA is
		once
			create {DB_DERIVATIVE_DATA} Result
		end

feature -- Status report

	connected: BOOLEAN is
			-- Are we connected to the database?
		do
			fatal_error := False
			Result := session.is_connected
		end

feature -- Basic operations

	connect is
			-- Connect to the database.
		local
			error: BOOLEAN
		do
			if not error then
				fatal_error := False
				session.connect
				if session.is_connected then
					debug ("database")
						io.put_string ("Connected.%N")
					end
				else
					last_error := concatenation (<<
						"Database error - failed to connect: ",
						session.diagnostic_message>>)
					debug ("database")
						print_list (<<last_error, "%N">>)
					end
					fatal_error := true
				end
			else
				fatal_error := true
			end
		rescue
			-- Caught exception from first call to `session'.
			error := true
			retry
		end

	disconnect is
			-- Disconnect from database.
		do
			fatal_error := false
			session.disconnect
			if not session.is_connected then
				debug ("database")
					io.put_string ("Disconnected.%N")
				end
			else
				last_error := concatenation (<<
					"Database error - failed to disconnect: ",
					session.diagnostic_message>>)
				debug ("database")
					print_list (<<last_error, "%N">>)
				end
				fatal_error := true
			end
		end

feature {NONE} -- Implementation

	session: ECLI_SESSION is
			-- The ECLI database session - provides access to the database
		once
			if db_info.db_name.is_empty then
				fatal_error := true
				last_error := "Database session was not created."
				raise (Void)
			else
				create Result.make (db_info.db_name, db_info.user_name,
					db_info.password)
			end
		end

	input_statement (query: STRING; value_holders: ARRAY [ECLI_VALUE]):
				ECLI_STATEMENT is
			-- Input ECLI_STATEMENT constructed with `query' and `value_holders'
		do
			fatal_error := false
			create Result.make (session)
			-- Change execution mode to immediate (no need to prepare).
			Result.set_immediate_execution_mode
			Result.set_sql (query)
			debug ("database")
				print_list (<<"ECLI_SERVICES executing statement:%N",
					Result.sql, "%N">>)
			end
			Result.execute
			if not Result.is_ok then
				last_error := concatenation (<<
					"Database error - execution of statement%N",
					Result.sql, " failed:%N", Result.cli_state, ", ",
					Result.diagnostic_message>>)
				debug ("database")
					print_list (<<last_error, "%N">>)
				end
				fatal_error := true
			end
			Result.set_cursor (value_holders)
		end

	list_from_query (q: STRING): LIST [STRING] is
		local
			stmt: ECLI_STATEMENT
			ecli_string: ECLI_VARCHAR
			s: STRING
		do
			fatal_error := false
			create {ARRAYED_LIST [STRING]} Result.make (0)
			if not q.is_empty then
				-- definition of statement on session
				create stmt.make (session)
				-- change execution mode to immediate (no need to prepare)
				stmt.set_immediate_execution_mode
				stmt.set_sql (q)
				stmt.execute
				if not stmt.is_ok then
					last_error := concatenation (<<
						"Database error - execution of statement%N'",
						stmt.sql, "' failed:%N", stmt.cli_state, ", ",
						stmt.diagnostic_message>>)
					debug ("database")
						print_list (<<last_error, "%N">>)
					end
					fatal_error := true
				else
					-- Create result set 'value holders'.
					create ecli_string.make (20)
					check stmt.result_column_count > 0 end
					-- Define the container of value holders.
					stmt.set_cursor (<<ecli_string>>)
					-- Iterate on result-set.
					from
						stmt.start
					until
						stmt.off
					loop
						if not stmt.cursor.item (1).is_null then
							s ?= stmt.cursor.item (1).item
							Result.extend (s)
						end
						stmt.forth
					end
				end
				stmt.close
			end
		end

	daily_stock_value_holders: ARRAY [ECLI_VALUE] is
			-- Array of value holders for statement execution results for
			-- daily stock data
		local
			date: ECLI_INTEGER
			volume, open, high, low, close: ECLI_DOUBLE
		do
			create date.make
			create high.make
			create low.make
			create close.make
			create volume.make
			if command_line_options.opening_price then
				create open.make
				Result := <<date, open, high, low, close, volume>>
			else
				Result := <<date, high, low, close, volume>>
			end
		end

	intraday_stock_value_holders: ARRAY [ECLI_VALUE] is
			-- Array of value holders for statement execution results for
			-- intraday stock data
		local
			date: ECLI_INTEGER
			time: ECLI_VARCHAR
			volume, open, high, low, close: ECLI_DOUBLE
		do
			create date.make
			-- Size of "hh:mm:ss" is 8.
			create time.make (8)
			create high.make
			create low.make
			create close.make
			create volume.make
			if command_line_options.opening_price then
				create open.make
				Result := <<date, time, open, high, low, close, volume>>
			else
				Result := <<date, time, high, low, close, volume>>
			end
		end

	daily_derivative_value_holders: ARRAY [ECLI_VALUE] is
			-- Array of value holders for statement execution results for
			-- daily derivative data
		local
			date: ECLI_INTEGER
			volume, open, high, low, close, oi: ECLI_DOUBLE
		do
			create date.make
			create high.make
			create low.make
			create close.make
			create volume.make
			create oi.make
			if command_line_options.opening_price then
				create open.make
				Result := <<date, open, high, low, close, volume, oi>>
			else
				Result := <<date, high, low, close, volume, oi>>
			end
		end

	intraday_derivative_value_holders: ARRAY [ECLI_VALUE] is
			-- Array of value holders for statement execution results for
			-- intraday derivative data
		local
			date: ECLI_INTEGER
			time: ECLI_VARCHAR
			volume, open, high, low, close, oi: ECLI_DOUBLE
		do
			create date.make
			-- Size of "hh:mm:ss" is 8.
			create time.make (8)
			create high.make
			create low.make
			create close.make
			create volume.make
			create oi.make
			if command_line_options.opening_price then
				create open.make
				Result := <<date, time, open, high, low, close, volume, oi>>
			else
				Result := <<date, time, high, low, close, volume, oi>>
			end
		end

	stock_split_value_holders: ARRAY [ECLI_VALUE] is
			-- Array of value holders for statement execution results for
			-- stock split data
		local
			date: ECLI_INTEGER
			symbol: ECLI_VARCHAR
			value: ECLI_DOUBLE
		do
			create date.make
			create symbol.make (32)
			create value.make
			Result := <<date, symbol, value>>
		end

	load_stock_splits is
		require
			connected: connected
		local
			query: STRING
			stmt: ECLI_STATEMENT
		do
			query := db_info.stock_split_query
			if not query.is_empty then
				stmt := input_statement (query, stock_split_value_holders)
				create stock_splits.make (stmt)
				stmt.close
			end
		ensure
			still_connected: connected
		end

	cleanup is
		do
			if connected then disconnect end
			if session.is_valid and not session.is_closed then
				session.close
			end
		end

	Max_varchar_length: INTEGER is 254

end -- class ECLI_SERVICES
