indexing
	description: "MAS database services - Windows ODBC implmentation"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class ODBC_SERVICES inherit

	MAS_DB_SERVICES

	GLOBAL_SERVER
		rename
			database_configuration as db_info
		export {NONE}
			all
		end

feature -- Access

	symbols: LIST [STRING] is
			-- All symbols available in the database
		local
			data	 : DATABASE_DATA [DATABASE]
			symbol   : STRING
			db_result: LINKED_LIST [DB_RESULT]
		do
			fatal_error := false
			db_result := db_mgr.retrieve (db_info.stock_symbol_query)
			if db_result /= Void then
				create {LINKED_LIST [STRING]} Result.make
				!!symbol.make (0)
				from
					db_result.start
				until 
					db_result.after
				loop
					data ?= db_result.item.data
					if data /= Void then
						if data.item (data.count).conforms_to (symbol) then
							symbol ?= data.item (data.count)
							Result.extend (clone (symbol))
						end	
					end
					db_result.forth
				end
			end
		end

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
					io.put_string ("Connected !!!%N")
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
					io.put_string ("Disconnected!!!%N")
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

end -- class ODBC_SERVICES
