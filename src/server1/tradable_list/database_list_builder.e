indexing
	description: "Builder of DB_TRADABLE_LISTs used by MAS"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class DATABASE_LIST_BUILDER

creation

	make

feature -- Initialization

	make (symbols: LINEAR [STRING]; factory: TRADABLE_FACTORY) is
			-- Initialize symbol_list and tradable factories.  A separate
			-- tradable factory for intraday data is used for efficiency.
		require
			not_void: symbols /= Void and factory /= Void
		do
			symbol_list := symbols
			tradable_factory := factory
			intraday_tradable_factory := clone (factory)
			intraday_tradable_factory.set_intraday (true)
			tradable_factory.set_intraday (false)
		ensure
			symbols_set: symbol_list = symbols and symbol_list /= Void
			factory_set: tradable_factory = factory and
				tradable_factory /= Void and not tradable_factory.intraday
			intraday_factory_set: intraday_tradable_factory /= Void and
				intraday_tradable_factory.intraday
		end

feature -- Access

	daily_list: DB_TRADABLE_LIST

	intraday_list: DB_TRADABLE_LIST

	symbol_list: LINEAR [STRING]

	tradable_factory: TRADABLE_FACTORY

	intraday_tradable_factory: TRADABLE_FACTORY

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
			check
				not_intraday: not tradable_factory.intraday
			end
			create daily_list.make (symbol_list,
				tradable_factory)
		end

	create_intraday_list is
		do
			check
				intraday: intraday_tradable_factory.intraday
			end
			create intraday_list.make (symbol_list,
				intraday_tradable_factory)
			intraday_list.set_intraday (true)
		end

end -- class DATABASE_LIST_BUILDER
