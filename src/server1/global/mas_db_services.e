indexing
	description: "MAS database services - Windows implmentation"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MAS_DB_SERVICES inherit

feature -- Access

	symbols: LIST [STRING] is
			-- All symbols available in the database
		local
			data	 : DATABASE_DATA[DATABASE]
			symbol   : STRING
			db_result: LINKED_LIST[DB_RESULT]
			db_mgr: MAS_ODBC_HANDLE
		do
			--remember to make file name a constant
			create db_info.make ("ms_dbsrvrc")
			create db_mgr
			db_mgr.login(db_info.db_name, db_info.user_name, db_info.password)
			db_mgr.connect
			if db_mgr.connected then
				db_result := db_mgr.retrieve(db_info.symbol_select)
				if db_result /= void then
					create {LINKED_LIST[STRING]} Result.make
					!!symbol.make(0)
					from
						db_result.start
					until 
						db_result.after
					loop
						data ?= db_result.item.data
						if data /= void then
							if data.item(data.count).conforms_to(symbol) then
								symbol ?= data.item(data.count)
								Result.extend(clone(symbol))
							end	
						end
						db_result.forth
					end
				end
				db_mgr.disconnect
			else
				db_mgr.raise_error
			end
		end

	market_data(symbol: STRING): LINKED_LIST[DB_RESULT] is
		-- market data for 'symbol'
		local
			db_mgr: MAS_ODBC_HANDLE
		do
			--remember to make file name a constant
			create db_info.make ("ms_dbsrvrc")
			create db_mgr
			db_mgr.login(db_info.db_name, db_info.user_name, db_info.password)
			db_mgr.connect
			if db_mgr.connected then
				db_mgr.set_argument(symbol, "symbol")
			-- db_mgr.set_argument(??, "tday")
				Result := db_mgr.retrieve(db_info.market_select)
				db_mgr.disconnect
			end
		end

 feature {NONE} -- Implementation

	db_info: MAS_DB_INFO
	
end -- class MAS_DB_SERVICES
