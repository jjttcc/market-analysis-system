indexing
	description: "Builder of DB_TRADABLE_LISTs used by MAS"
	status: "Copyright 1998 - 2000: Jim Cochrane and others - %
		%see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class DATABASE_LIST_BUILDER

creation

	make

feature -- Initialization

	make (symbols: LINEAR [STRING];
			factories: LINEAR [TRADABLE_FACTORY]) is
		require
			not_void: symbols /= Void and factories /= Void
		do
			symbol_list := symbols
			tradable_factories := factories
		ensure
			symbols_set: symbol_list = symbols and symbol_list /= Void
			factories_set: tradable_factories = factories and
				tradable_factories /= Void
		end

feature -- Access

	daily_list: DB_TRADABLE_LIST

	intraday_list: DB_TRADABLE_LIST

	symbol_list: LINEAR [STRING]

	tradable_factories: LINEAR [TRADABLE_FACTORY]

feature -- Basic operations

	execute is
		require
			input_lists_set: symbol_list /= Void and tradable_factories /= Void
		local
			global_server: expanded GLOBAL_SERVER
			db_info: MAS_DB_INFO
		do
			db_info := global_server.database_configuration
			if not db_info.daily_stock_table_name.empty then
				create_daily_list
			end
			if not db_info.intraday_stock_table_name.empty then
				create_intraday_list
			end
		ensure
			lists_created: daily_list /= Void and intraday_list /= Void
		end

feature {NONE} -- Implementation

	create_daily_list is
		do
			create {DB_TRADABLE_LIST} daily_list.make (symbol_list,
				tradable_factories)
		end

	create_intraday_list is
		do
			create {DB_TRADABLE_LIST} intraday_list.make (symbol_list,
				tradable_factories)
			intraday_list.set_intraday (true)
		end

end -- class DATABASE_LIST_BUILDER
