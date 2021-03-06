note
	description: "A TRADABLE_LIST for a database implementation"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DB_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			close_input_medium, input_medium
		end

creation

	make

feature {NONE} -- Implementation

	input_medium: DB_INPUT_SEQUENCE

	old_remove_setup_input_medium
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			db: MAS_DB_SERVICES
		do
			db := global_server.database_services
			if not db.connected then
				db.connect
			end
			if not db.fatal_error then
				if intraday then
					input_medium :=
						db.intraday_data_for_symbol (current_symbol)
				else
					input_medium := db.daily_data_for_symbol (current_symbol)
				end
				if input_medium = Void or db.fatal_error then
					fatal_error := True
				else
					tradable_factory.set_input (input_medium)
				end
			else
				fatal_error := True
			end
			if fatal_error then
				log_errors (<<"Error occurred while processing ",
					current_symbol, ": ", db.last_error>>)
				close_input_medium
			end
		ensure then
			input_medium_closed_on_error: fatal_error and
				input_medium /= Void implies not input_medium.is_open
		end

	initialize_input_medium
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			db: MAS_DB_SERVICES
		do
			db := global_server.database_services
			if not db.connected then
				db.connect
			end
			if not db.fatal_error then
				if intraday then
					input_medium :=
						db.intraday_data_for_symbol (current_symbol)
				else
					input_medium := db.daily_data_for_symbol (current_symbol)
				end
				if input_medium = Void or db.fatal_error then
					fatal_error := True
				end
			else
				fatal_error := True
			end
			if fatal_error then
				log_errors (<<"Error occurred while processing ",
					current_symbol, ": ", db.last_error>>)
				close_input_medium
			end
		ensure then
			input_medium_closed_on_error: fatal_error and
				input_medium /= Void implies not input_medium.is_open
		end

	close_input_medium
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			db: MAS_DB_SERVICES
		do
			if input_medium /= Void then
				if input_medium.is_open then
					input_medium.close
				end
				if input_medium.error_occurred then
					log_error (input_medium.error_string)
				end
			end
			if not global_server.command_line_options.keep_db_connection then
				db := global_server.database_services
				if db.connected then
					db.disconnect
				end
				if db.fatal_error then
					fatal_error := True
					log_error (db.last_error)
				end
			end
		end

end -- class DB_TRADABLE_LIST
