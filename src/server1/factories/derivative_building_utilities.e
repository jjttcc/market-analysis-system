indexing
	description: "Tradable factory that manufactures DERIVATIVE_INSTRUMENTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class DERIVATIVE_BUILDING_UTILITIES inherit

	TRADABLE_FACTORY_CONSTANTS
		export
			{NONE} all
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

	GLOBAL_SERVER
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature {TRADABLE_FACTORY} -- Implementation

	tuple_factory: BASIC_TUPLE_FACTORY is
		do
			create {OI_TUPLE_FACTORY} Result
		end

	new_item (symbol: STRING): DERIVATIVE_INSTRUMENT is
			-- A new derivative instance with symbol `symbol'
		do
			create Result.make (symbol, derivative_data)
		end

	index_vector (no_open, intraday: BOOLEAN): ARRAY [INTEGER] is
			-- Index vector for setting up value setters for a
			-- DERIVATIVE_INSTRUMENT (with an open interest field)
		do
			if no_open then
				if intraday then
					Result := << Date_index, Time_index, High_index,
						Low_index, CLose_index, Volume_index, OI_index >>
				else
					Result := << Date_index, High_index, Low_index,
						CLose_index, Volume_index, OI_index >>
				end
			else
				if intraday then
					Result := << Date_index, Time_index, Open_index,
						High_index, Low_index, Close_index, Volume_index,
						OI_index >>
				else
					Result := << Date_index, Open_index, High_index,
						Low_index, Close_index, Volume_index, OI_index >>
				end
			end
		ensure
			at_least_one: Result.count > 0
		end

	derivative_data: TRADABLE_DATA is
		do
			if command_line_options.use_db then
				Result := database_services.derivative_data
			end
		end

end -- DERIVATIVE_BUILDING_UTILITIES
