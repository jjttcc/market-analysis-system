indexing
	description: "A TRADABLE_LIST for a database implementation"
	status: "Copyright 1998 - 2000: Eirik Mangseth, Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class DB_TRADABLE_LIST inherit

	TRADABLE_LIST
		redefine
			setup_input_medium
		end

create

	make

feature {NONE} -- Implementation

	query_db: DB_INPUT_SEQUENCE is
		local
			mds: MAS_DB_SERVICES
		do
			create mds
			create Result.make (mds.market_data(current_symbol))
		end

	setup_input_medium is
		local
			inp_seq: DB_INPUT_SEQUENCE
			exc: EXCEPTIONS
		do
			inp_seq := query_db	
			if inp_seq /= Void then
				tradable_factories.item.set_input (inp_seq)
			else
				create exc
				exc.raise ("Error reading from database")
			end
		end
	
end -- class DB_TRADABLE_LIST
