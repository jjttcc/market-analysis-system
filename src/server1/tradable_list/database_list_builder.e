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

	make (symbols: LINEAR [STRING]; factory: TRADABLE_FACTORY) is
		require
			not_void: symbols /= Void and factory /= Void
		do
			symbol_list := symbols
			tradable_factory := factory
		ensure
			symbols_set: symbol_list = symbols and symbol_list /= Void
			factory_set: tradable_factory = factory and
				tradable_factory /= Void
		end

feature -- Access

	daily_list: DB_TRADABLE_LIST

	intraday_list: DB_TRADABLE_LIST

	symbol_list: LINEAR [STRING]

	tradable_factory: TRADABLE_FACTORY

feature -- Basic operations

	execute is
		require
			input_lists_set: symbol_list /= Void and tradable_factory /= Void
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
		end

feature {NONE} -- Implementation

	create_daily_list is
		do
			create {DB_TRADABLE_LIST} daily_list.make (symbol_list,
				tradable_factory)
		end

	create_intraday_list is
		do
			create {DB_TRADABLE_LIST} intraday_list.make (symbol_list,
				tradable_factory)
			intraday_list.set_intraday (true)
		end

end -- class DATABASE_LIST_BUILDER
