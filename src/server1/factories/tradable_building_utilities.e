indexing
	description: "Factory that manufactures TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class TRADABLE_BUILDING_UTILITIES inherit

	TRADABLE_FACTORY_CONSTANTS
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

feature {TRADABLE_FACTORY} -- Access

	new_item (symbol: STRING): TRADABLE [BASIC_MARKET_TUPLE] is
			-- A new tradable instance with symbol `symbol'
		require
			symbol_exists: symbol /= Void and then not symbol.is_empty
		deferred
		ensure
			result_exists: Result /= Void
		end

	tuple_factory: BASIC_TUPLE_FACTORY is
			-- Factory that produces tuple types that match the type
			-- of `new_item'
		deferred
		ensure
			result_exists: Result /= Void
		end

	index_vector (intraday: BOOLEAN): ARRAY [INTEGER] is
			-- Index vector for setting up value setters for a TRADABLE
		deferred
		ensure
			at_least_one: Result /= Void and then Result.count > 0
		end

end
