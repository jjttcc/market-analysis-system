indexing
	description: "Implementation of STOCK_DATA using a database";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class DB_STOCK_DATA inherit

	STOCK_DATA

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	name: STRING is
		local
			db_services: MAS_DB_SERVICES
			gs: expanded GLOBAL_SERVER
			error_occurred: BOOLEAN
		do
			db_services := gs.database_services
			db_services.connect
			if db_services.fatal_error then
				error_occurred := true
			else
				Result := db_services.stock_name (symbol)
				if db_services.fatal_error then
					error_occurred := true
				else
					db_services.disconnect
					error_occurred := db_services.fatal_error
				end
			end
			if error_occurred then
				log_errors (<<"Database error:%N",
					db_services.last_error, ".%N">>)
			end
		end

	description: STRING is
		do
		end

	sector: STRING is
		do
		end

end -- class DB_STOCK_DATA
