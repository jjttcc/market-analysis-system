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

	setup_input_medium is
		local
			inp_seq: DB_INPUT_SEQUENCE
			exc: EXCEPTIONS
			global_server: expanded GLOBAL_SERVER
			mds: MAS_DB_SERVICES
		do
			mds := global_server.database_services
			mds.connect
			if not mds.fatal_error then
				if intraday then
					inp_seq := mds.intraday_stock_data (current_symbol)
				else
					inp_seq := mds.daily_stock_data (current_symbol)
				end
				if inp_seq = Void or mds.fatal_error then
					fatal_error := true
				else
					tradable_factory.set_input (inp_seq)
				end
			else
				fatal_error := true
			end
			if fatal_error then
				log_errors (<<"Error occurred while processing ",
					tradable_factory.symbol, ": ", mds.last_error>>)
			end
		end

	close_input_medium is
		local
			global_server: expanded GLOBAL_SERVER
			mds: MAS_DB_SERVICES
		do
			mds := global_server.database_services
			mds.disconnect
			if mds.fatal_error then
				fatal_error := true
			end
		end

end -- class DB_TRADABLE_LIST
