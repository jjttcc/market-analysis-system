indexing
	description: "MAS database services - Windows ODBC implmentation"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class ODBC_SERVICES inherit

	MAS_DB_SERVICES

	GLOBAL_SERVER
		rename
			database_configuration as db_info
		export {NONE}
			all
		end

	EXCEPTIONS
		export {NONE}
			all
		end

GLOBAL_APPLICATION
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
			load_stock_splits
register_for_termination (Current)
		ensure
			splits_not_void_if_available:
				not fatal_error and not db_info.stock_split_query.empty implies
					stock_splits /= Void
		end

feature -- Access

	stock_splits: ODBC_STOCK_SPLITS

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
			db_mgr.set_argument (symbol, "symbol")
			Result := input_sequence (daily_stock_query (symbol))
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
			db_mgr.set_argument (symbol, "symbol")
			Result := input_sequence (intraday_stock_query (symbol))
		end

	daily_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
			db_mgr.set_argument (symbol, "symbol")
			Result := input_sequence (daily_derivative_query (symbol))
		end

	intraday_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE is
		do
			db_mgr.set_argument (symbol, "symbol")
			Result := input_sequence (intraday_derivative_query (symbol))
		end

	single_string_query_result (query: STRING): STRING is
		do
			-- Stub
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
			Result := db_mgr.connected
		end

feature -- Basic operations

	connect is
			-- Connect to the database.
		do
			fatal_error := false
			db_mgr.connect
			if db_mgr.connected then
				debug ("database")
					io.put_string ("Connected.%N")
				end
			else
				last_error := "Failed to connect to database."
				debug ("database")
					print_list (<<last_error, "%N">>)
				end
				fatal_error := true
			end
		end

	disconnect is
			-- Disconnect from database.
		do
			fatal_error := false
			db_mgr.disconnect
			if not db_mgr.connected then
				debug ("database")
					io.put_string ("Disconnected.%N")
				end
			else
				last_error := "Failed to disconnect to database."
				debug ("database")
					print_list (<<last_error, "%N">>)
				end
				fatal_error := true
			end
		end

feature {NONE} -- Implementation

	db_mgr: MAS_ODBC_HANDLE is
			-- The ODBC database session - provides access to the database
		once
			if db_info.db_name.empty then
				fatal_error := true
				last_error := "Database session was not created."
				raise (Void)
			else
				create Result
				Result.login (db_info.db_name, db_info.user_name,
					db_info.password)
			end
		end

	input_sequence (query: STRING): ODBC_INPUT_SEQUENCE is
			-- Input sequence constructed with `query' and `value_holders'
		local
			result_list: LINKED_LIST [DB_RESULT]
		do
			fatal_error := false
			result_list := db_mgr.retrieve (query)
			create Result.make (result_list)
		end

	list_from_query (q: STRING): LIST [STRING] is
		local
			data	 : DATABASE_DATA [DATABASE]
			s        : STRING
			db_result: LINKED_LIST [DB_RESULT]
		do
			fatal_error := false
			db_result := db_mgr.retrieve (q)
			if db_result /= Void then
				create {ARRAYED_LIST [STRING]} Result.make (0)
				create s.make (0)
				from
					db_result.start
				until 
					db_result.after
				loop
					data ?= db_result.item.data
					if data /= Void then
						if data.item (data.count).conforms_to (s) then
							s ?= data.item (data.count)
							Result.extend (clone (s))
						end	
					end
					db_result.forth
				end
			end
		end

	load_stock_splits is
		do
			-- Stub
		end

--(Added for new connect/disconnect scheme.)
	cleanup is
		do
			if connected then disconnect end
-- Any other needed cleanup ...
		end

end -- class ODBC_SERVICES
