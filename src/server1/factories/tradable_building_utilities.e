note
	description: "Factory that manufactures TRADABLEs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
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

	new_item (symbol: STRING): TRADABLE [BASIC_MARKET_TUPLE]
			-- A new tradable instance with symbol `symbol'
		require
			symbol_exists: symbol /= Void and then not symbol.is_empty
		deferred
		ensure
			result_exists: Result /= Void
		end

	tuple_factory: BASIC_TUPLE_FACTORY
			-- Factory that produces tuple types that match the type
			-- of `new_item'
		deferred
		ensure
			result_exists: Result /= Void
		end

	index_vector (intraday: BOOLEAN): ARRAY [INTEGER]
			-- Index vector for setting up value setters for a TRADABLE
		local
			vector: ARRAYED_LIST [INTEGER]
		do
			create vector.make (0)
			if command_line_options.special_date_settings.valid then
				vector.extend (Configurable_date_index)
			else
				vector.extend (Date_index)
			end
			if intraday then
				vector.extend (Time_index)
			end
			if command_line_options.opening_price then
				vector.extend (Open_index)
			end
			if not command_line_options.no_high then
				vector.extend (High_index)
			end
			if not command_line_options.no_low then
				vector.extend (Low_index)
			end
			vector.extend (Close_index)
			if not command_line_options.no_volume then
				vector.extend (Volume_index)
			end
			if has_open_interest then
				vector.extend (OI_index)
			end
			Result := vector
		ensure
			at_least_one: Result /= Void and then Result.count > 0
			date_is_first: Result @ 1 = Date_index
			time_is_second: intraday implies Result @ 2 = Time_index
			open_interest_is_second: has_open_interest implies
				Result.item (Result.upper) = OI_index
		end

feature {NONE} -- Hook routines

	has_open_interest: BOOLEAN
			-- Does the data entity being built have an open interest field?
		deferred
		end

end
