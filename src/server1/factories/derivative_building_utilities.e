indexing
	description: "Tradable factory that manufactures DERIVATIVE_INSTRUMENTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class DERIVATIVE_BUILDING_UTILITIES inherit

	TRADABLE_BUILDING_UTILITIES

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

	derivative_data: TRADABLE_DATA is
		do
			if command_line_options.use_db then
				Result := database_services.derivative_data
			end
		end

feature {NONE} -- Hook routine implementations

	has_open_interest: BOOLEAN is True

end
