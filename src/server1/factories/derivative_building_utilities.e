note
	description: "Tradable factory that manufactures DERIVATIVE_INSTRUMENTs"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DERIVATIVE_BUILDING_UTILITIES inherit

	TRADABLE_BUILDING_UTILITIES

feature {TRADABLE_FACTORY} -- Implementation

	tuple_factory: BASIC_TUPLE_FACTORY
		do
			create {OI_TUPLE_FACTORY} Result
		end

	new_item (symbol: STRING): DERIVATIVE_INSTRUMENT
			-- A new derivative instance with symbol `symbol'
		do
			create Result.make (symbol, derivative_data)
		end

	derivative_data: TRADABLE_DATA
		do
			if command_line_options.use_db then
				Result := database_services.derivative_data
			end
		end

feature {NONE} -- Hook routine implementations

	has_open_interest: BOOLEAN = True

end
