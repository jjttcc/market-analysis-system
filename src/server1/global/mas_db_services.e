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
			db_handle: MAS_ODBC_HANDLE
			data	 : DATABASE_DATA[DATABASE]
			symbol   : STRING
		do
			--remember to make file name a constant
			create db_info.make ("ms_dbsrvrc")
			create db_handle.make(db_info.db_name, db_info.trades_tables.item)
			db_handle.login(db_info.user_name, db_info.password)
			db_handle.connect
			if db_handle.connected then
				db_handle.set_current_query(db_info.symbol_select)
				db_handle.make_selection
				if db_handle.last_result /= void then
					create {LINKED_LIST[STRING]} Result.make
					!!symbol.make(0)
					from
						db_handle.last_result.start
					until 
						db_handle.last_result.after
					loop
						data ?= db_handle.last_result.item.data
						if data /= void then
							if data.item(data.count).conforms_to(symbol) then
								symbol ?= data.item(data.count)
								Result.extend(clone(symbol))
							end	
						end
						db_handle.last_result.forth
					end
				end
			else
				db_handle.raise_error
			end
		end

feature {NONE} -- Implementation

	db_info: MAS_DB_INFO

end -- class MAS_DB_SERVICES
