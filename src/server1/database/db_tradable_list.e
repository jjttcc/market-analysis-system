indexing
	description: "A TRADABLE_LIST for a database implementation"
	author: "Eirik Mangseth"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Eirik Mangseth and Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class DB_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium, close_input_medium
		end

creation

	make

feature -- Status report

	intraday: BOOLEAN

feature -- Status setting

	set_intraday (arg: BOOLEAN) is
			-- Set intraday to `arg'.
		do
			intraday := arg
		ensure
			intraday_set: intraday = arg
		end

feature {NONE} -- Implementation

	input_sequence: DB_INPUT_SEQUENCE

	setup_input_medium is
		local
			global_server: expanded GLOBAL_SERVER
			db: MAS_DB_SERVICES
		do
			db := global_server.database_services
			if not db.connected then
				db.connect
			end
			if not db.fatal_error then
				if intraday then
					input_sequence :=
						db.intraday_data_for_symbol (current_symbol)
				else
					input_sequence := db.daily_data_for_symbol (current_symbol)
				end
				if input_sequence = Void or db.fatal_error then
					fatal_error := true
				else
					tradable_factory.set_input (input_sequence)
				end
			else
				fatal_error := true
			end
			if fatal_error then
				log_errors (<<"Error occurred while processing ",
					tradable_factory.symbol, ": ", db.last_error>>)
			end
		end

	close_input_medium is
		local
			global_server: expanded GLOBAL_SERVER
			db: MAS_DB_SERVICES
		do
			input_sequence.close
			if input_sequence.error_occurred then
				log_error (input_sequence.error_string)
			end
			if not global_server.command_line_options.keep_db_connection then
				db := global_server.database_services
				db.disconnect
				if db.fatal_error then
					fatal_error := true
					log_error (db.last_error)
				end
			end
		end

end -- class DB_TRADABLE_LIST
