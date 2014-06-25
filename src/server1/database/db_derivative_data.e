note
	description: "Implementation of DERIVATIVE_DATA using a database";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DB_DERIVATIVE_DATA inherit

	TRADABLE_DATA

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	name: STRING
		local
			db_services: MAS_DB_SERVICES
			gs: expanded GLOBAL_SERVER_FACILITIES
			error_occurred: BOOLEAN
		do
			db_services := gs.database_services
			if not db_services.connected then
				db_services.connect
			end
			if db_services.fatal_error then
				error_occurred := True
			else
				Result := db_services.derivative_name (symbol)
				if db_services.fatal_error then
					error_occurred := True
				end
				if not gs.command_line_options.keep_db_connection then
					db_services.disconnect
					error_occurred := error_occurred or db_services.fatal_error
				end
			end
			if error_occurred then
				log_errors (<<"Database error:%N",
					db_services.last_error, ".%N">>)
			end
		end

	description: STRING
		do
		end

end -- class DB_DERIVATIVE_DATA
